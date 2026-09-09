import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/recherche/emploi/emploi_filtres_recherche.dart';
import 'package:pass_emploi_app/presentation/checkbox_value_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/offre_emploi/offre_emploi_filtres_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/filtres_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/buttons/filter_button.dart';
import 'package:pass_emploi_app/widgets/errors/error_text.dart';
import 'package:pass_emploi_app/widgets/slider/distance_slider.dart';
import 'package:pass_emploi_app/widgets/tag_group.dart';

class OffreEmploiFiltresPage extends StatefulWidget {
  final bool fromAlternance;

  OffreEmploiFiltresPage(this.fromAlternance);

  static Future<bool?> show(BuildContext context, bool fromAlternance) {
    return showPassEmploiBottomSheet<bool>(
      context: context,
      builder: (context) => OffreEmploiFiltresPage(fromAlternance),
    );
  }

  @override
  State<OffreEmploiFiltresPage> createState() => _OffreEmploiFiltresPageState();
}

class _OffreEmploiFiltresPageState extends State<OffreEmploiFiltresPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Tracker(
      tracking: widget.fromAlternance ? AnalyticsScreenNames.alternanceFiltres : AnalyticsScreenNames.emploiFiltres,
      child: Theme(
        data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
        child: StoreConnector<AppState, OffreEmploiFiltresViewModel>(
          converter: (store) => OffreEmploiFiltresViewModel.create(store),
          builder: (context, viewModel) => _scaffold(viewModel),
          distinct: true,
          onWillChange: (previousVM, newVM) {
            if (previousVM?.displayState == DisplayState.LOADING && newVM.displayState == DisplayState.CONTENT) {
              Navigator.pop(context, true);
            }
          },
        ),
      ),
    );
  }

  Widget _scaffold(OffreEmploiFiltresViewModel viewModel) {
    return FiltresBottomSheet(
      title: Strings.offresEmploiFiltresTitle,
      body: _Content(viewModel: viewModel),
    );
  }
}

class _Content extends StatefulWidget {
  final OffreEmploiFiltresViewModel viewModel;

  _Content({required this.viewModel});

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  late double _currentSliderValue;
  late bool _currentDebutantOnlyFiltre;
  late List<CheckboxValueViewModel<ContratFiltre>> _currentContratFiltres;
  late List<CheckboxValueViewModel<DureeFiltre>> _currentDureeFiltres;
  late List<CheckboxValueViewModel<ContratFiltre>> _contratOptions;
  late List<CheckboxValueViewModel<DureeFiltre>> _dureeOptions;
  int _filtersKey = 0;

  @override
  void initState() {
    super.initState();
    _initFromViewModel();
  }

  void _initFromViewModel() {
    _currentSliderValue = widget.viewModel.initialDistanceValue.toDouble();
    _currentDebutantOnlyFiltre = widget.viewModel.initialDebutantOnlyFiltre ?? false;
    _contratOptions = widget.viewModel.contratFiltres;
    _dureeOptions = widget.viewModel.dureeFiltres;
    _currentContratFiltres = _contratOptions.where((element) => element.isInitiallyChecked).toList();
    _currentDureeFiltres = _dureeOptions.where((element) => element.isInitiallyChecked).toList();
  }

  void _resetFiltres() {
    setState(() {
      _currentSliderValue = EmploiFiltresRecherche.defaultDistanceValue.toDouble();
      _currentDebutantOnlyFiltre = false;
      _contratOptions = widget.viewModel.contratFiltres
          .map(
            (e) => CheckboxValueViewModel(
              label: e.label,
              value: e.value,
              helpText: e.helpText,
              isInitiallyChecked: false,
            ),
          )
          .toList();
      _dureeOptions = widget.viewModel.dureeFiltres
          .map(
            (e) => CheckboxValueViewModel(
              label: e.label,
              value: e.value,
              helpText: e.helpText,
              isInitiallyChecked: false,
            ),
          )
          .toList();
      _currentContratFiltres = [];
      _currentDureeFiltres = [];
      _filtersKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _Filters(
          key: ValueKey(_filtersKey),
          viewModel: widget.viewModel,
          initialDistanceValue: _currentSliderValue,
          debutantOnlyEnabled: _currentDebutantOnlyFiltre,
          contratOptions: _contratOptions,
          dureeOptions: _dureeOptions,
          onDistanceValueChange: (value) => _setDistanceFilterState(value),
          onDebutantOnlyValueChange: (value) => _setDebutantOnlyFilterState(value),
          onContractValueChange: (selectedOptions) => _setContractFilterState(selectedOptions),
          onDurationValueChange: (selectedOptions) => _setContractDurationState(selectedOptions),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FilterButton(
            isEnabled: _isButtonEnabled(widget.viewModel.displayState),
            onPressed: () => _onButtonClick(widget.viewModel),
            onReset: _resetFiltres,
          ),
        ),
      ],
    );
  }

  void _setDistanceFilterState(double value) {
    setState(() => _currentSliderValue = value);
  }

  void _setDebutantOnlyFilterState(bool value) {
    setState(() => _currentDebutantOnlyFiltre = value);
  }

  void _setContractFilterState(List<CheckboxValueViewModel<ContratFiltre>> selectedOptions) {
    setState(() => _currentContratFiltres = selectedOptions);
  }

  void _setContractDurationState(List<CheckboxValueViewModel<DureeFiltre>> selectedOptions) {
    setState(() => _currentDureeFiltres = selectedOptions);
  }

  bool _isButtonEnabled(DisplayState displayState) => displayState != DisplayState.LOADING;

  void _onButtonClick(OffreEmploiFiltresViewModel viewModel) {
    viewModel.updateFiltres(
      _currentSliderValue.toInt(),
      _currentDebutantOnlyFiltre,
      _currentContratFiltres,
      _currentDureeFiltres,
    );
  }
}

class _Filters extends StatelessWidget {
  final OffreEmploiFiltresViewModel viewModel;
  final double initialDistanceValue;
  final bool debutantOnlyEnabled;
  final List<CheckboxValueViewModel<ContratFiltre>> contratOptions;
  final List<CheckboxValueViewModel<DureeFiltre>> dureeOptions;
  final Function(double) onDistanceValueChange;
  final Function(bool) onDebutantOnlyValueChange;
  final Function(List<CheckboxValueViewModel<ContratFiltre>>) onContractValueChange;
  final Function(List<CheckboxValueViewModel<DureeFiltre>>) onDurationValueChange;

  const _Filters({
    super.key,
    required this.viewModel,
    required this.initialDistanceValue,
    required this.debutantOnlyEnabled,
    required this.contratOptions,
    required this.dureeOptions,
    required this.onDistanceValueChange,
    required this.onDebutantOnlyValueChange,
    required this.onContractValueChange,
    required this.onDurationValueChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (viewModel.shouldDisplayDistanceFiltre) ...[
            DistanceSlider(
              initialDistanceValue: initialDistanceValue,
              onValueChange: onDistanceValueChange,
            ),
            const SizedBox(height: DsfrSpacings.s2w),
          ],
          if (viewModel.shouldDisplayNonDistanceFiltres) ...[
            _FiltreDebutant(
              onDebutantOnlyValueChange: onDebutantOnlyValueChange,
              debutantOnlyEnabled: debutantOnlyEnabled,
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            TagGroup<ContratFiltre>(
              title: Strings.contratSectionTitle,
              options: contratOptions,
              onSelectedOptionsUpdated: (selectedOptions) {
                onContractValueChange(selectedOptions as List<CheckboxValueViewModel<ContratFiltre>>);
              },
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            TagGroup<DureeFiltre>(
              title: Strings.dureeSectionTitle,
              options: dureeOptions,
              onSelectedOptionsUpdated: (selectedOptions) {
                onDurationValueChange(selectedOptions as List<CheckboxValueViewModel<DureeFiltre>>);
              },
            ),
          ],
          if (viewModel.displayState.isFailure()) ErrorText(Strings.genericError),
          const SizedBox(height: 200),
        ],
      ),
    );
  }
}

class _FiltreDebutant extends StatefulWidget {
  final bool debutantOnlyEnabled;
  final Function(bool) onDebutantOnlyValueChange;

  const _FiltreDebutant({
    required this.onDebutantOnlyValueChange,
    required this.debutantOnlyEnabled,
  });

  @override
  State<_FiltreDebutant> createState() => _FiltreDebutantState();
}

class _FiltreDebutantState extends State<_FiltreDebutant> {
  var _debutantOnlyEnabled = false;

  @override
  void initState() {
    super.initState();
    _debutantOnlyEnabled = widget.debutantOnlyEnabled;
  }

  @override
  void didUpdateWidget(covariant _FiltreDebutant oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.debutantOnlyEnabled != widget.debutantOnlyEnabled) {
      _debutantOnlyEnabled = widget.debutantOnlyEnabled;
    }
  }

  void _onDebutantOnlyValueChange(bool value) {
    setState(() {
      _debutantOnlyEnabled = value;
      widget.onDebutantOnlyValueChange(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            Strings.experienceSectionTitle,
            style: DsfrTextStyle.bodyXlBold(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: DsfrColorDecisions.artworkDecorativeBlueFrance(context)),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DsfrSpacings.s3v,
              vertical: DsfrSpacings.s1w,
            ),
            child: Semantics(
              label: Strings.experienceSectionEnabled(_debutantOnlyEnabled),
              child: DsfrToggleSwitch(
                label: Strings.experienceSectionDescription,
                labelLocation: DsfrToggleSwitchLabelLocation.left,
                value: _debutantOnlyEnabled,
                status: _debutantOnlyEnabled ? Strings.yes : Strings.no,
                onChanged: _onDebutantOnlyValueChange,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
