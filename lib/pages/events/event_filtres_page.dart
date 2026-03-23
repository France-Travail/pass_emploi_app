import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/presentation/checkbox_value_view_model.dart';
import 'package:pass_emploi_app/presentation/events/event_filters_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/buttons/filter_button.dart';
import 'package:pass_emploi_app/widgets/buttons/secondary_button.dart';
import 'package:pass_emploi_app/widgets/checkbox_group.dart';

class EventFiltresPage extends StatefulWidget {
  static Future<bool?> show(BuildContext context) {
    return showPassEmploiBottomSheet<bool>(
      context: context,
      builder: (context) => EventFiltresPage(),
    );
  }

  @override
  State<EventFiltresPage> createState() => _EventFiltresPageState();
}

class _EventFiltresPageState extends State<EventFiltresPage> {
  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.eventFiltres,
      child: StoreConnector<AppState, EventFiltersViewModel>(
        converter: (store) => EventFiltersViewModel.create(store),
        builder: (context, viewModel) => _scaffold(viewModel),
        distinct: true,
      ),
    );
  }

  Widget _scaffold(EventFiltersViewModel viewModel) {
    return BottomSheetWrapper(
      title: Strings.eventListFiltres,
      body: _Content(viewModel: viewModel),
    );
  }
}

class _Content extends StatefulWidget {
  final EventFiltersViewModel viewModel;

  _Content({required this.viewModel});

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  List<CheckboxValueViewModel<String>>? _currentAntenneFiltres;

  @override
  void initState() {
    super.initState();
    _currentAntenneFiltres = widget.viewModel.antenneFiltres.where((element) => element.isInitiallyChecked).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Filters(
          viewModel: widget.viewModel,
          onAntenneValueChange: (selectedOptions) => _setAntenneFilterState(selectedOptions),
        ),
        SizedBox(height: Margins.spacing_m),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilterButton(
                isEnabled: _isButtonEnabled(),
                onPressed: () => _onButtonClick(context, widget.viewModel),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: SecondaryButton(
                isEnabled: _currentAntenneFiltres?.isNotEmpty == true,
                label: Strings.eventListFiltresEffacer,
                onPressed: () => _clearFilters(context),
              ),
            ),
            SizedBox(height: Margins.spacing_m),
          ],
        ),
      ],
    );
  }

  void _setAntenneFilterState(List<CheckboxValueViewModel<String>> selectedOptions) {
    setState(() => _currentAntenneFiltres = selectedOptions);
  }

  void _clearFilters(BuildContext context) {
    setState(() => _currentAntenneFiltres = []);
    widget.viewModel.clearFiltres();
    Navigator.pop(context, true);
  }

  bool _isButtonEnabled() => true;

  void _onButtonClick(BuildContext context, EventFiltersViewModel viewModel) {
    final selectedAntennes = _currentAntenneFiltres?.map((e) => e.value).toList() ?? [];
    viewModel.updateFiltres(selectedAntennes);
    Navigator.pop(context, true);
  }
}

class _Filters extends StatefulWidget {
  final EventFiltersViewModel viewModel;
  final Function(List<CheckboxValueViewModel<String>>) onAntenneValueChange;

  _Filters({
    required this.viewModel,
    required this.onAntenneValueChange,
  });

  @override
  State<_Filters> createState() => _FiltersState();
}

class _FiltersState extends State<_Filters> {
  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.antenneFiltres.isEmpty) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: Margins.spacing_xl),
            Text(
              "Aucune antenne disponible pour le filtrage",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: Margins.spacing_l),
          CheckBoxGroup<String>(
            title: Strings.eventListFiltresAntenne,
            options: widget.viewModel.antenneFiltres,
            onSelectedOptionsUpdated: (selectedOptions) {
              widget.onAntenneValueChange(selectedOptions as List<CheckboxValueViewModel<String>>);
            },
          ),
        ],
      ),
    );
  }
}
