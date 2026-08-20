import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/models/evenement_emploi/evenement_emploi_modalite.dart';
import 'package:pass_emploi_app/models/evenement_emploi/evenement_emploi_type.dart';
import 'package:pass_emploi_app/presentation/checkbox_value_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/evenement_emploi/evenement_emploi_filtres_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';
import 'package:pass_emploi_app/widgets/buttons/filter_button.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/errors/error_text.dart';
import 'package:pass_emploi_app/widgets/radio_list_tile.dart';
import 'package:pass_emploi_app/widgets/tag_group.dart';

class EvenementEmploiFiltresPage extends StatefulWidget {
  static Future<bool?> show(BuildContext context) {
    return showDsfrBottomSheet<bool>(
      context: context,
      name: AnalyticsScreenNames.evenementEmploiFiltres,
      builder: (context) => EvenementEmploiFiltresPage(),
    );
  }

  @override
  State<EvenementEmploiFiltresPage> createState() => _EvenementEmploiFiltresPageState();
}

class _EvenementEmploiFiltresPageState extends State<EvenementEmploiFiltresPage> {
  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.evenementEmploiFiltres,
      child: StoreConnector<AppState, EvenementEmploiFiltresViewModel>(
        converter: (store) => EvenementEmploiFiltresViewModel.create(store),
        builder: (context, viewModel) => _Content(viewModel: viewModel),
        distinct: true,
        onWillChange: (previousVM, newVM) {
          if (previousVM?.displayState == DisplayState.LOADING && newVM.displayState == DisplayState.CONTENT) {
            Navigator.pop(context, true);
          }
        },
      ),
    );
  }
}

class _Content extends StatefulWidget {
  final EvenementEmploiFiltresViewModel viewModel;

  _Content({required this.viewModel});

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  EvenementEmploiType? _currentTypeValue;
  late List<CheckboxValueViewModel<EvenementEmploiModalite>> _modaliteOptions;
  List<CheckboxValueViewModel<EvenementEmploiModalite>>? _currentModaliteFiltres;
  DateTime? _currentDateDebut;
  DateTime? _currentDateFin;
  int _filtersKey = 0;

  @override
  void initState() {
    super.initState();
    _initFromViewModel();
  }

  void _initFromViewModel() {
    _currentTypeValue = widget.viewModel.initialTypeValue;
    _modaliteOptions = widget.viewModel.modalitesFiltres;
    _currentModaliteFiltres = _modaliteOptions.where((element) => element.isInitiallyChecked).toList();
    _currentDateDebut = widget.viewModel.initialDateDebut;
    _currentDateFin = widget.viewModel.initialDateFin;
  }

  void _resetFiltres() {
    setState(() {
      _currentTypeValue = null;
      _modaliteOptions = widget.viewModel.modalitesFiltres
          .map(
            (e) => CheckboxValueViewModel(
              label: e.label,
              value: e.value,
              helpText: e.helpText,
              isInitiallyChecked: false,
            ),
          )
          .toList();
      _currentModaliteFiltres = [];
      _currentDateDebut = null;
      _currentDateFin = null;
      _filtersKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DsfrBottomSheet(
      actions: FilterButton(
        isEnabled: _isButtonEnabled(widget.viewModel.displayState),
        onPressed: () => _onButtonClick(widget.viewModel),
        onReset: _resetFiltres,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              Strings.evenementEmploiFiltres,
              style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s4w),
          _Filters(
            key: ValueKey(_filtersKey),
            viewModel: widget.viewModel,
            initialTypeValue: _currentTypeValue,
            modaliteOptions: _modaliteOptions,
            currentDateDebut: _currentDateDebut,
            currentDateFin: _currentDateFin,
            onTypeValueChange: (type) => _setTypeFiltreState(type),
            onModalitesValueChange: (selectedOptions) => _setModalitesFiltreState(selectedOptions),
            onDateDebutValueChange: (dateTime) => _setDateDebutFiltreState(dateTime),
            onDateFinValueChange: (dateTime) => _setDateFinFiltreState(dateTime),
          ),
        ],
      ),
    );
  }

  void _setTypeFiltreState(EvenementEmploiType? type) {
    setState(() => _currentTypeValue = type);
  }

  void _setModalitesFiltreState(List<CheckboxValueViewModel<EvenementEmploiModalite>> selectedOptions) {
    setState(() => _currentModaliteFiltres = selectedOptions);
  }

  void _setDateDebutFiltreState(DateTime dateTime) {
    setState(() {
      _currentDateDebut = dateTime;
      if (_currentDateFin?.isBefore(dateTime) == true) _currentDateFin = null;
    });
  }

  void _setDateFinFiltreState(DateTime dateTime) {
    setState(() {
      _currentDateFin = dateTime;
    });
  }

  bool _isButtonEnabled(DisplayState displayState) => displayState != DisplayState.LOADING;

  void _onButtonClick(EvenementEmploiFiltresViewModel viewModel) {
    viewModel.updateFiltres(_currentTypeValue, _currentModaliteFiltres, _currentDateDebut, _currentDateFin);
  }
}

class _Filters extends StatelessWidget {
  final EvenementEmploiFiltresViewModel viewModel;
  final EvenementEmploiType? initialTypeValue;
  final List<CheckboxValueViewModel<EvenementEmploiModalite>> modaliteOptions;
  final DateTime? currentDateDebut;
  final DateTime? currentDateFin;
  final Function(EvenementEmploiType?) onTypeValueChange;
  final Function(List<CheckboxValueViewModel<EvenementEmploiModalite>>) onModalitesValueChange;
  final Function(DateTime) onDateDebutValueChange;
  final Function(DateTime) onDateFinValueChange;

  const _Filters({
    super.key,
    required this.viewModel,
    required this.initialTypeValue,
    required this.modaliteOptions,
    required this.currentDateDebut,
    required this.currentDateFin,
    required this.onTypeValueChange,
    required this.onModalitesValueChange,
    required this.onDateDebutValueChange,
    required this.onDateFinValueChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TypeFiltre(
          initialTypeValue: initialTypeValue,
          onValueChange: onTypeValueChange,
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        TagGroup<EvenementEmploiModalite>(
          title: Strings.evenementEmploiFiltresModalites,
          options: modaliteOptions,
          onSelectedOptionsUpdated: (selectedOptions) {
            onModalitesValueChange(selectedOptions as List<CheckboxValueViewModel<EvenementEmploiModalite>>);
          },
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        _DateFiltres(
          onDateDebutValueChange: onDateDebutValueChange,
          onDateFinValueChange: onDateFinValueChange,
          initialDateDebut: currentDateDebut,
          initialDateFin: currentDateFin,
        ),
        if (viewModel.displayState.isFailure()) ErrorText(Strings.genericError),
      ],
    );
  }
}

class _TypeFiltre extends StatefulWidget {
  final Function(EvenementEmploiType?) onValueChange;
  final EvenementEmploiType? initialTypeValue;

  _TypeFiltre({required this.onValueChange, required this.initialTypeValue});

  @override
  State<_TypeFiltre> createState() => _TypeFiltreState();
}

class _TypeFiltreState extends State<_TypeFiltre> {
  EvenementEmploiType? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialTypeValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            Strings.evenementEmploiFiltresType,
            style: DsfrTextStyle.bodyXlBold(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [null, ...EvenementEmploiType.values]
              .map(
                (type) => CustomRadioGroup<EvenementEmploiType?>(
                  title: type?.label ?? Strings.evenementEmploiTypeAll,
                  value: type,
                  groupValue: _currentValue,
                  onChanged: (value) {
                    widget.onValueChange(value);
                    setState(() => _currentValue = value);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _DateFiltres extends StatefulWidget {
  final Function(DateTime) onDateDebutValueChange;
  final Function(DateTime) onDateFinValueChange;
  final DateTime? initialDateDebut;
  final DateTime? initialDateFin;

  const _DateFiltres({
    required this.onDateDebutValueChange,
    required this.onDateFinValueChange,
    required this.initialDateDebut,
    required this.initialDateFin,
  });

  @override
  State<_DateFiltres> createState() => _DateFiltresState();
}

class _DateFiltresState extends State<_DateFiltres> {
  late final TextEditingController _dateDebutController;
  late final TextEditingController _dateFinController;

  @override
  void initState() {
    super.initState();
    _dateDebutController = TextEditingController(text: _dateText(widget.initialDateDebut));
    _dateFinController = TextEditingController(text: _dateFinDisplayText());
  }

  @override
  void didUpdateWidget(covariant _DateFiltres oldWidget) {
    super.didUpdateWidget(oldWidget);
    final debutText = _dateText(widget.initialDateDebut);
    if (_dateDebutController.text != debutText) {
      _dateDebutController.text = debutText;
    }
    final finText = _dateFinDisplayText();
    if (_dateFinController.text != finText) {
      _dateFinController.text = finText;
    }
  }

  @override
  void dispose() {
    _dateDebutController.dispose();
    _dateFinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (DateTime? initialDateFin, DateTime? firstDateFin, bool _) = _dateFinParams();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            Strings.evenementEmploiFiltresDate,
            style: DsfrTextStyle.bodyXlBold(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrDateInput(
          label: Strings.evenementEmploiFiltresDateDebut,
          controller: _dateDebutController,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
          initialDate: widget.initialDateDebut ?? DateTime.now(),
          locale: const Locale('fr', 'FR'),
          onChanged: widget.onDateDebutValueChange,
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrDateInput(
          label: Strings.evenementEmploiFiltresDateFin,
          controller: _dateFinController,
          firstDate: firstDateFin ?? DateTime.now(),
          lastDate: DateTime(2101),
          initialDate: initialDateFin ?? firstDateFin ?? DateTime.now(),
          locale: const Locale('fr', 'FR'),
          onChanged: widget.onDateFinValueChange,
        ),
      ],
    );
  }

  String _dateFinDisplayText() {
    final (DateTime? initialDateFin, _, bool showInitialDateFin) = _dateFinParams();
    if (!showInitialDateFin) return '';
    return _dateText(initialDateFin);
  }

  String _dateText(DateTime? date) => date?.toDay() ?? '';

  (DateTime? intialDate, DateTime? firstDate, bool showInitialDate) _dateFinParams() {
    if (widget.initialDateFin != null) return (widget.initialDateFin, DateTime.now(), true);
    if (widget.initialDateDebut != null) return (widget.initialDateDebut, widget.initialDateDebut, false);
    return (null, DateTime.now(), true);
  }
}
