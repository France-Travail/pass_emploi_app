import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/diagoriente_preferences_metier/diagoriente_preferences_metier_actions.dart';
import 'package:pass_emploi_app/presentation/mots_cles_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/autocomplete_suggestions_group.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/debounce_text_form_field.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/full_screen_text_form_field_scaffold.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/utils/multiline_app_bar.dart';

class KeywordTextFormFieldPage extends StatelessWidget {
  final String title;
  final String? hint;
  final String? selectedKeyword;
  final String heroTag;

  KeywordTextFormFieldPage({required this.title, this.hint, this.selectedKeyword, required this.heroTag});

  static MaterialPageRoute<String?> materialPageRoute({
    required String title,
    required String? hint,
    required String? selectedKeyword,
    required final String heroTag,
  }) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) =>
          KeywordTextFormFieldPage(title: title, hint: hint, selectedKeyword: selectedKeyword, heroTag: heroTag),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenTextFormFieldScaffold(
      body: StoreConnector<AppState, MotsClesViewModel>(
        onInit: (store) => store.dispatch(DiagorientePreferencesMetierRequestAction()),
        onInitialBuild: _onInitialBuild,
        converter: (store) => MotsClesViewModel.create(store),
        builder: (context, viewModel) {
          return _Body(
            viewModel: viewModel,
            title: title,
            hint: hint,
            selectedKeyword: selectedKeyword,
            heroTag: heroTag,
          );
        },
        distinct: true,
      ),
    );
  }

  void _onInitialBuild(MotsClesViewModel viewModel) {
    if (viewModel.containsDiagorienteFavoris) {
      PassEmploiMatomoTracker.instance.trackEvent(
        eventCategory: AnalyticsEventNames.autocompleteMotCleDiagorienteMetiersFavorisEventCategory,
        action: AnalyticsEventNames.autocompleteMotCleDiagorienteMetiersFavorisDisplayAction,
      );
    }
  }
}

class _Body extends StatefulWidget {
  final MotsClesViewModel viewModel;
  final String title;
  final String? hint;
  final String? selectedKeyword;
  final String heroTag;

  const _Body({
    required this.viewModel,
    required this.title,
    this.hint,
    required this.selectedKeyword,
    required this.heroTag,
  });

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  bool emptyInput = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MultilineAppBar(
          onCloseButtonPressed: () => Navigator.pop(context, widget.selectedKeyword),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, DsfrSpacings.s2w, DsfrSpacings.s2w, 0),
          child: Semantics(
            label: '${widget.title} ${Strings.a11YKeywordExplanationLabel}',
            child: DebounceTextFormField(
              heroTag: widget.heroTag,
              label: widget.title,
              hintText: widget.hint,
              initialValue: widget.selectedKeyword,
              onChanged: (text) {
                if (text.isEmpty != emptyInput) setState(() => emptyInput = text.isEmpty);
              },
              onFieldSubmitted: (keyword) => Navigator.pop(context, keyword),
            ),
          ),
        ),
        if (emptyInput)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, DsfrSpacings.s1w, DsfrSpacings.s2w, DsfrSpacings.s3w),
              children: _buildSuggestionGroups(context),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildSuggestionGroups(BuildContext context) {
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
    }

    for (final item in widget.viewModel.motsCles) {
      if (item is MotsClesTitleItem) {
        flushGroup();
        currentTitle = item.title;
        currentIcon = _iconForTitle(item.title);
      } else if (item is MotsClesSuggestionItem) {
        currentChildren.add(
          AutocompleteSuggestionTile(
            text: item.text,
            onTap: () {
              if (item.source == MotCleSource.diagorienteMetiersFavoris) {
                PassEmploiMatomoTracker.instance.trackEvent(
                  eventCategory: AnalyticsEventNames.autocompleteMotCleDiagorienteMetiersFavorisEventCategory,
                  action: AnalyticsEventNames.autocompleteMotCleDiagorienteMetiersFavorisClickAction,
                );
              }
              Navigator.pop(context, item.text);
            },
          ),
        );
      }
    }
    flushGroup();
    return groups;
  }

  IconData? _iconForTitle(String title) {
    if (title == Strings.vosPreferencesMetiers) return DsfrIcons.weatherFlashlightLine;
    return DsfrIcons.systemTimeLine;
  }
}
