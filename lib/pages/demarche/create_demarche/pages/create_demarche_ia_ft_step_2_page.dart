import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/demarche/create/create_demarche_actions.dart';
import 'package:pass_emploi_app/features/ia_ft_suggestions/ia_ft_suggestions_actions.dart';
import 'package:pass_emploi_app/models/demarche_ia_suggestion.dart';
import 'package:pass_emploi_app/presentation/create_demarche_ia_ft_step_2_view_model.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_change_notifier.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';

class CreateDemarcheIaFtStep2Page extends StatelessWidget {
  const CreateDemarcheIaFtStep2Page(this.formViewModel);
  final CreateDemarcheFormChangeNotifier formViewModel;

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.createDemarcheIaFtSuggestions,
      child: StoreConnector<AppState, CreateDemarcheIaFtStep2ViewModel>(
        converter: (store) => CreateDemarcheIaFtStep2ViewModel.create(store),
        onInit: (store) => store.dispatch(
          IaFtSuggestionsRequestAction(
            query: formViewModel.iaFtStep2ViewModel.description,
          ),
        ),
        builder: (context, viewModel) => _Body(formViewModel: formViewModel, viewModel: viewModel),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.formViewModel, required this.viewModel});
  final CreateDemarcheFormChangeNotifier formViewModel;
  final CreateDemarcheIaFtStep2ViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return switch (viewModel.loadDisplayState) {
      DisplayState.CONTENT => _Content(viewModel, formViewModel),
      DisplayState.FAILURE => _Failure(formViewModel),
      _ => const _Loading(),
    };
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: Column(
          children: [
            ExcludeSemantics(
              child: SvgPicture.asset(
                Drawables.illustrationSystem,
                height: 240,
              ),
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            Text(
              Strings.iaFtSuggestionsLoading,
              style: DsfrTextStyle.bodyXlBold(
                color: DsfrColorDecisions.textTitleGrey(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            Text(
              Strings.iaFtSuggestionsLoadingWait,
              style: DsfrTextStyle.bodyXlBold(
                color: DsfrColorDecisions.textTitleGrey(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DsfrSpacings.s4w),
            ExcludeSemantics(
              child: CircularProgressIndicator(
                color: DsfrColorDecisions.backgroundActionHighBlueFrance(
                  context,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure(this.viewModel);
  final CreateDemarcheFormChangeNotifier viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DsfrSpacings.s2w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SvgPicture.asset(
              Drawables.illustrationWarning,
              width: 160,
              height: 160,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(height: DsfrSpacings.s3w),
          Text(
            Strings.iaFtSuggestionsFailure,
            style: DsfrTextStyle.bodyMdBold(
              color: DsfrColorDecisions.textTitleGrey(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DsfrSpacings.s3w),
          SizedBox(
            width: double.infinity,
            child: DsfrButton(
              label: Strings.back,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.md,
              onPressed: () => viewModel.onNavigateBackward(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.viewModel);
  final CreateDemarcheFormChangeNotifier viewModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SvgPicture.asset(
                Drawables.illustrationWarning,
                width: 160,
                height: 160,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: DsfrSpacings.s3w),
            Text(
              Strings.iaFtSuggestionsEmpty,
              style: DsfrTextStyle.bodyMdBold(
                color: DsfrColorDecisions.textTitleGrey(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DsfrSpacings.s3w),
            SizedBox(
              width: double.infinity,
              child: DsfrButton(
                label: Strings.back,
                variant: DsfrButtonVariant.primary,
                size: DsfrComponentSize.md,
                onPressed: () => viewModel.onNavigateBackward(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content(this.viewModel, this.formViewModel);
  final CreateDemarcheIaFtStep2ViewModel viewModel;
  final CreateDemarcheFormChangeNotifier formViewModel;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  late final DemarcheIaSuggestionsChangeNotifier notifier;

  @override
  void initState() {
    super.initState();
    notifier = DemarcheIaSuggestionsChangeNotifier(
      suggestions: widget.viewModel.suggestions,
      onSubmit: (actions) => widget.formViewModel.submitDemarcheIaFt(actions),
    );
    notifier.addListener(_onNotifierChanged);
  }

  @override
  void dispose() {
    notifier.removeListener(_onNotifierChanged);
    notifier.dispose();
    super.dispose();
  }

  void _onNotifierChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = notifier.suggestions;
    if (suggestions.isEmpty) {
      return _Empty(widget.formViewModel);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(DsfrSpacings.s2w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (notifier.error != null) ...[
                AutoFocusA11y(
                  child: Semantics(
                    liveRegion: true,
                    child: DsfrAlert(
                      type: DsfrAlertType.error,
                      description: DsfrAlertDescriptionText(notifier.error!),
                    ),
                  ),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
              ],
              Semantics(
                header: true,
                child: Text(
                  Strings.iaFtSuggestionsContent(suggestions.length),
                  style: DsfrTextStyle.bodyMdBold(
                    color: DsfrColorDecisions.textTitleGrey(context),
                  ),
                ),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suggestions.length,
                separatorBuilder: (context, index) => const SizedBox(height: DsfrSpacings.s2w),
                itemBuilder: (context, index) => _DemarcheIaCard(
                  showError: notifier.error != null && notifier.getDate(suggestions[index].id) == null,
                  suggestion: suggestions[index],
                  date: notifier.getDate(suggestions[index].id),
                  onDateChanged: (id, date) => notifier.updateDate(id, date),
                  onDelete: (id) {
                    notifier.deleteSuggestion(id);
                    PassEmploiMatomoTracker.instance.trackEvent(
                      eventCategory: AnalyticsEventNames.createDemarcheEventCategory,
                      action: AnalyticsEventNames.createDemarcheIaSuggestionsListDeleted,
                      eventValue: 1,
                    );
                  },
                ),
              ),
              const SizedBox(height: DsfrSpacings.s8w),
              const SizedBox(height: DsfrSpacings.s8w),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ColoredBox(
            color: DsfrColorDecisions.backgroundDefaultGrey(context),
            child: Padding(
              padding: EdgeInsets.only(
                top: DsfrSpacings.s2w,
                left: DsfrSpacings.s2w,
                right: DsfrSpacings.s2w,
                bottom: MediaQuery.of(context).padding.bottom + DsfrSpacings.s2w,
              ),
              child: _SubmitButton(notifier),
            ),
          ),
        ),
      ],
    );
  }
}

class _DemarcheIaCard extends StatefulWidget {
  const _DemarcheIaCard({
    required this.showError,
    required this.suggestion,
    required this.date,
    required this.onDateChanged,
    required this.onDelete,
  });

  final bool showError;
  final DemarcheIaSuggestion suggestion;
  final DateTime? date;
  final void Function(String id, DateTime? date) onDateChanged;
  final void Function(String id) onDelete;

  @override
  State<_DemarcheIaCard> createState() => _DemarcheIaCardState();
}

class _DemarcheIaCardState extends State<_DemarcheIaCard> {
  late final TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.date?.toDay() ?? '');
  }

  @override
  void didUpdateWidget(covariant _DemarcheIaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextDateText = widget.date?.toDay() ?? '';
    if (_dateController.text != nextDateText) {
      _dateController.text = nextDateText;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryLabel = widget.suggestion.label ?? Strings.otherDemarche;
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DsfrColorDecisions.backgroundDefaultGrey(context),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          border: Border.all(
            color: DsfrColorDecisions.borderDefaultGrey(context),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DsfrSpacings.s2w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: DsfrBadge(
                      label: categoryLabel,
                      type: DsfrBadgeType.information,
                      size: DsfrComponentSize.sm,
                    ),
                  ),
                  DsfrButton(
                    icon: DsfrIcons.systemCloseLine,
                    iconSemanticLabel:
                        "${Strings.suppressionLabel} ${widget.suggestion.sousTitre ?? widget.suggestion.titre ?? ""}",
                    variant: DsfrButtonVariant.tertiaryWithoutBorder,
                    size: DsfrComponentSize.sm,
                    onPressed: () => widget.onDelete(widget.suggestion.id),
                  ),
                ],
              ),
              const SizedBox(height: DsfrSpacings.s1w),
              Text(
                widget.suggestion.titre ?? '',
                style: DsfrTextStyle.bodyMdBold(
                  color: DsfrColorDecisions.textTitleGrey(context),
                ),
              ),
              if (widget.suggestion.sousTitre != null && widget.suggestion.sousTitre!.isNotEmpty) ...[
                const SizedBox(height: DsfrSpacings.s1v),
                Text(
                  widget.suggestion.sousTitre!,
                  style: DsfrTextStyle.bodySm(
                    color: DsfrColorDecisions.textDefaultGrey(context),
                  ),
                ),
              ],
              const SizedBox(height: DsfrSpacings.s2w),
              DsfrDateInput(
                label: Strings.thematiquesDemarcheDateShort,
                controller: _dateController,
                firstDate: DateTime(2020),
                lastDate: DateTime(2101),
                initialDate: widget.date ?? DateTime.now(),
                locale: const Locale('fr', 'FR'),
                composantState: widget.showError
                    ? DsfrComponentState.error(
                        errorMessage: Strings.dateMandatory,
                      )
                    : const DsfrComponentState.none(),
                onChanged: (date) => widget.onDateChanged(widget.suggestion.id, date),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton(this.notifier);
  final DemarcheIaSuggestionsChangeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DsfrButton(
        label: Strings.iaFtSuggestionsSubmit,
        variant: DsfrButtonVariant.primary,
        size: DsfrComponentSize.md,
        onPressed: () => notifier.submit(),
      ),
    );
  }
}

class DemarcheIaSuggestionsChangeNotifier extends ChangeNotifier {
  DemarcheIaSuggestionsChangeNotifier({
    required List<DemarcheIaSuggestion> suggestions,
    required this.onSubmit,
  }) : _suggestions = List.from(suggestions),
       _dates = {for (var s in suggestions) s.id: null};

  final void Function(List<CreateDemarcheRequestAction>) onSubmit;
  final List<DemarcheIaSuggestion> _suggestions;
  final Map<String, DateTime?> _dates;
  String? error;

  List<DemarcheIaSuggestion> get suggestions => List.unmodifiable(_suggestions);

  DateTime? getDate(String id) => _dates[id];

  void updateDate(String id, DateTime? date) {
    if (_dates.containsKey(id)) {
      _dates[id] = date;
      error = null;
      notifyListeners();
    }
  }

  void deleteSuggestion(String id) {
    _suggestions.removeWhere((s) => s.id == id);
    _dates.remove(id);
    error = null;
    notifyListeners();
  }

  void submit() {
    int count = 0;
    for (var suggestion in _suggestions) {
      if (getDate(suggestion.id) == null) {
        count++;
      }
    }
    if (count > 0) {
      error = Strings.iaFtSuggestionsError(count);
      notifyListeners();
      return;
    }

    final List<CreateDemarcheRequestAction> actions = [];
    for (var suggestion in _suggestions) {
      actions.add(
        CreateDemarcheRequestAction(
          codeQuoi: suggestion.codeQuoi,
          codePourquoi: suggestion.codePourquoi,
          description: suggestion.sousTitre,
          codeComment: null,
          dateEcheance: getDate(suggestion.id)!,
          estDuplicata: false,
        ),
      );
    }
    onSubmit(actions);
  }
}
