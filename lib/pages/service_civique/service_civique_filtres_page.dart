import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/models/service_civique/domain.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/service_civique/service_civique_filtres_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/filtres_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/buttons/filter_button.dart';
import 'package:pass_emploi_app/widgets/date_pickers/date_picker.dart';
import 'package:pass_emploi_app/widgets/radio_list_tile.dart';
import 'package:pass_emploi_app/widgets/slider/distance_slider.dart';
import 'package:pass_emploi_app/widgets/toggles/date_toggle.dart';

class ServiceCiviqueFiltresPage extends StatefulWidget {
  static Future<bool?> show(BuildContext context) {
    return showPassEmploiBottomSheet<bool>(
      context: context,
      builder: (context) => ServiceCiviqueFiltresPage(),
    );
  }

  @override
  State<ServiceCiviqueFiltresPage> createState() => _ServiceCiviqueFiltresPageState();
}

class _ServiceCiviqueFiltresPageState extends State<ServiceCiviqueFiltresPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Tracker(
      tracking: AnalyticsScreenNames.serviceCiviqueFiltres,
      child: Theme(
        data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
        child: StoreConnector<AppState, ServiceCiviqueFiltresViewModel>(
          converter: (store) => ServiceCiviqueFiltresViewModel.create(store),
          builder: (context, viewModel) => _scaffold(context, viewModel),
          distinct: true,
        ),
      ),
    );
  }

  Widget _scaffold(BuildContext context, ServiceCiviqueFiltresViewModel viewModel) {
    return FiltresBottomSheet(
      title: Strings.serviceCiviqueFiltresTitle,
      body: _Content(viewModel: viewModel),
    );
  }
}

class _Content extends StatefulWidget {
  final ServiceCiviqueFiltresViewModel viewModel;

  _Content({required this.viewModel});

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  late double _currentSliderValue;
  DateTime? _currentStartDate;
  late Domaine _currentDomainValue;
  int _filtersKey = 0;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.viewModel.initialDistanceValue.toDouble();
    _currentStartDate = widget.viewModel.initialStartDateValue;
    _currentDomainValue = widget.viewModel.initialDomainValue;
  }

  void _resetFiltres() {
    setState(() {
      _currentSliderValue = defaultDistanceValueOnServiceCiviqueFiltre.toDouble();
      _currentStartDate = null;
      _currentDomainValue = Domaine.all;
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
          initialStartDateValue: _currentStartDate,
          initialDomainValue: _currentDomainValue,
          onDistanceValueChange: (distance) => _setDistanceFilterState(distance),
          onStartDateValueChange: (date, isActive) => _setStartDateFilterState(date, isActive),
          onDomainValueChange: (domain) => _setDomainFilterState(domain),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FilterButton(
            isEnabled: _isButtonEnabled(widget.viewModel),
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

  void _setStartDateFilterState(DateTime? date, bool isActive) {
    setState(() => _currentStartDate = isActive ? date : null);
  }

  void _setDomainFilterState(Domaine domain) {
    setState(() => _currentDomainValue = domain);
  }

  bool _isButtonEnabled(ServiceCiviqueFiltresViewModel viewModel) => viewModel.displayState != DisplayState.LOADING;

  void _onButtonClick(ServiceCiviqueFiltresViewModel viewModel) {
    viewModel.updateFiltres(
      _currentSliderValue.toInt(),
      _currentDomainValue,
      _currentStartDate,
    );
    Navigator.pop(context, true);
  }
}

class _Filters extends StatefulWidget {
  final ServiceCiviqueFiltresViewModel viewModel;
  final double initialDistanceValue;
  final DateTime? initialStartDateValue;
  final Domaine initialDomainValue;
  final Function(double) onDistanceValueChange;
  final Function(DateTime?, bool) onStartDateValueChange;
  final Function(Domaine) onDomainValueChange;

  _Filters({
    super.key,
    required this.viewModel,
    required this.initialDistanceValue,
    required this.initialStartDateValue,
    required this.initialDomainValue,
    required this.onDistanceValueChange,
    required this.onStartDateValueChange,
    required this.onDomainValueChange,
  });

  @override
  State<_Filters> createState() => _FiltersState();
}

class _FiltersState extends State<_Filters> {
  bool _isActiveDate = false;
  DateTime? _currentStartDate;
  late Domaine _currentDomainValue;

  @override
  void initState() {
    super.initState();
    _currentStartDate = widget.initialStartDateValue ?? DateTime.now();
    _isActiveDate = widget.initialStartDateValue != null;
    _currentDomainValue = widget.initialDomainValue;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.viewModel.shouldDisplayDistanceFiltre) ...[
            DistanceSlider(
              initialDistanceValue: widget.initialDistanceValue,
              onValueChange: (value) => widget.onDistanceValueChange(value),
            ),
            const SizedBox(height: DsfrSpacings.s2w),
          ],
          _StartDateFilters(
            initialDateValue: _isActiveDate ? _currentStartDate : null,
            onIsActiveChange: _onIsActiveChange,
            onDateChange: _onDateChange,
            isActiveDate: _isActiveDate,
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          _DomainFilters(
            currentDomainValue: _currentDomainValue,
            onValueChange: (value) => widget.onDomainValueChange(value),
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  void _onIsActiveChange(bool isActive) {
    setState(() {
      _isActiveDate = isActive;
    });
    widget.onStartDateValueChange(_currentStartDate, isActive);
  }

  void _onDateChange(DateTime date) {
    setState(() {
      _currentStartDate = date;
    });
    widget.onStartDateValueChange(date, _isActiveDate);
  }
}

class _StartDateFilters extends StatelessWidget {
  final Function(bool) onIsActiveChange;
  final Function(DateTime) onDateChange;
  final DateTime? initialDateValue;
  final bool isActiveDate;

  _StartDateFilters({
    required this.onIsActiveChange,
    required this.onDateChange,
    required this.initialDateValue,
    required this.isActiveDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.startDateFiltreTitle,
          style: DsfrTextStyle.bodyXlBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DateToggle(
          onIsActiveChange: onIsActiveChange,
          isActiveDate: isActiveDate,
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DatePicker(
          onDateSelected: onDateChange,
          initialDateValue: initialDateValue,
          isActiveDate: isActiveDate,
        ),
      ],
    );
  }
}

class _DomainFilters extends StatelessWidget {
  final Function(Domaine) onValueChange;
  final Domaine currentDomainValue;

  _DomainFilters({required this.onValueChange, required this.currentDomainValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.domainFiltreTitle,
          style: DsfrTextStyle.bodyXlBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        _DomainList(
          onValueChange: onValueChange,
          initialDomainValue: currentDomainValue,
        ),
      ],
    );
  }
}

class _DomainList extends StatefulWidget {
  final Function(Domaine) onValueChange;
  final Domaine initialDomainValue;

  _DomainList({required this.onValueChange, required this.initialDomainValue});

  @override
  State<_DomainList> createState() => _DomainListState();
}

class _DomainListState extends State<_DomainList> {
  Domaine? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialDomainValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: Domaine.values
          .map(
            (domain) => CustomRadioGroup<Domaine>(
              title: domain.titre,
              value: domain,
              groupValue: _currentValue,
              onChanged: (value) {
                widget.onValueChange(value!);
                setState(() => _currentValue = value);
              },
            ),
          )
          .toList(),
    );
  }
}
