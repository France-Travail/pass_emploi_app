import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/ignore_tracking_context_provider.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_actions.dart';
import 'package:pass_emploi_app/features/location/search_location_actions.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/presentation/autocomplete/location_displayable_extension.dart';
import 'package:pass_emploi_app/presentation/autocomplete/location_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/autocomplete_suggestions_group.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/debounce_text_form_field.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/full_screen_text_form_field_scaffold.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/multiline_app_bar.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/read_only_text_form_field.dart';

const _heroTag = 'location';

class LocationAutocomplete extends StatefulWidget {
  final String title;
  final String? hint;
  final Function(Location? location) onLocationSelected;
  final bool villesOnly;
  final Location? initialValue;

  const LocationAutocomplete({
    required this.title,
    this.hint,
    required this.onLocationSelected,
    this.villesOnly = false,
    this.initialValue,
  });

  @override
  State<LocationAutocomplete> createState() => _LocationAutocompleteState();
}

class _LocationAutocompleteState extends State<LocationAutocomplete> {
  Location? _selectedLocation;

  @override
  void initState() {
    _selectedLocation = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ReadOnlyTextFormField(
      title: widget.title,
      hint: widget.hint,
      a11ySuppressionLabel: Strings.a11YLocationSuppressionLabel,
      heroTag: _heroTag,
      textFormFieldKey: Key(_selectedLocation.toString()),
      withDeleteButton: _selectedLocation != null,
      onTextTap: () => Navigator.push(
        IgnoreTrackingContext.of(context).nonTrackingContext,
        _LocationAutocompletePage.materialPageRoute(
          title: widget.title,
          hint: widget.hint,
          villesOnly: widget.villesOnly,
          selectedLocation: _selectedLocation,
        ),
      ).then((location) => _updateLocation(location)),
      onDeleteTap: () => _updateLocation(null),
      initialValue: _selectedLocation?.displayableLabel(),
    );
  }

  void _updateLocation(Location? location) {
    setState(() => _selectedLocation = location);
    StoreProvider.of<AppState>(context).dispatch(CriteresRecherchePersistWriteLocationAction(location));
    widget.onLocationSelected(location);
  }
}

class _LocationAutocompletePage extends StatefulWidget {
  final String title;
  final String? hint;
  final bool villesOnly;
  final Location? selectedLocation;

  _LocationAutocompletePage({
    required this.title,
    required this.hint,
    required this.villesOnly,
    this.selectedLocation,
  });

  static MaterialPageRoute<Location?> materialPageRoute({
    required String title,
    required String? hint,
    required bool villesOnly,
    required Location? selectedLocation,
  }) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => _LocationAutocompletePage(
        title: title,
        hint: hint,
        villesOnly: villesOnly,
        selectedLocation: selectedLocation,
      ),
    );
  }

  @override
  State<_LocationAutocompletePage> createState() => _LocationAutocompletePageState();
}

class _LocationAutocompletePageState extends State<_LocationAutocompletePage> {
  bool emptyInput = true;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, LocationViewModel>(
      converter: (store) => LocationViewModel.create(store, villesOnly: widget.villesOnly),
      onInitialBuild: _onInitialBuild,
      onDispose: (store) => store.dispatch(SearchLocationResetAction()),
      builder: _builder,
      distinct: true,
    );
  }

  void _onInitialBuild(LocationViewModel viewModel) {
    viewModel.onInputLocation(widget.selectedLocation?.libelle);
  }

  Widget _builder(BuildContext context, LocationViewModel viewModel) {
    final autocompleteItems = viewModel.getAutocompleteItems(emptyInput);
    return FullScreenTextFormFieldScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MultilineAppBar(
            onCloseButtonPressed: () => Navigator.pop(context, widget.selectedLocation),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, DsfrSpacings.s2w, DsfrSpacings.s2w, 0),
            child: Semantics(
              label:
                  '${widget.title} ${widget.villesOnly ? //
                        Strings.a11YLocationWithoutDepartmentExplanationLabel : //
                        Strings.a11YLocationWithDepartmentsExplanationLabel}',
              child: DebounceTextFormField(
                heroTag: _heroTag,
                label: widget.title,
                hintText: widget.hint,
                initialValue: widget.selectedLocation?.displayableLabel(),
                onChanged: (text) {
                  if (text.isEmpty != emptyInput) setState(() => emptyInput = text.isEmpty);
                  viewModel.onInputLocation(text);
                },
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                DsfrSpacings.s2w,
                DsfrSpacings.s1w,
                DsfrSpacings.s2w,
                DsfrSpacings.s3w,
              ),
              children: _buildSuggestionGroups(context, autocompleteItems),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSuggestionGroups(BuildContext context, List<LocationItem> items) {
    final groups = <Widget>[];
    String? currentTitle;
    IconData? currentIcon;
    final currentChildren = <Widget>[];

    void flushGroup() {
      if (currentChildren.isEmpty) return;
      groups.add(
        AutocompleteSuggestionsGroup(
          title: currentTitle,
          titleIcon: currentIcon,
          children: List.of(currentChildren),
        ),
      );
      currentChildren.clear();
      currentTitle = null;
      currentIcon = null;
    }

    for (final item in items) {
      if (item is LocationTitleItem) {
        flushGroup();
        currentTitle = item.title;
        currentIcon = DsfrIcons.systemTimeLine;
      } else if (item is LocationSuggestionItem) {
        final code = item.location.displayableCode();
        currentChildren.add(
          AutocompleteSuggestionTile(
            text: item.location.libelle,
            secondaryText: code.isEmpty ? null : code,
            onTap: () => Navigator.pop(context, item.location),
          ),
        );
      }
    }
    flushGroup();
    return groups;
  }
}
