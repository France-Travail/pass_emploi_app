import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_tracking.dart';
import 'package:pass_emploi_app/pages/accueil/invite/invite_action_plan_empty_state.dart';
import 'package:pass_emploi_app/pages/accueil/invite/invite_action_plan_section.dart';
import 'package:pass_emploi_app/pages/accueil/invite/invite_discovery_tile.dart';
import 'package:pass_emploi_app/pages/accueil/invite/onboarding_questionnaire_progress_card.dart';
import 'package:pass_emploi_app/presentation/accueil/invite_accueil_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_tracker.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/action_plan_feedback_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/notifications_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

class InviteAccueilBody extends StatefulWidget {
  @override
  State<InviteAccueilBody> createState() => _InviteAccueilBodyState();
}

class _InviteAccueilBodyState extends State<InviteAccueilBody> {
  bool _notificationsBottomSheetShown = false;
  String? _lastPlanDisplayAction;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: StoreConnector<AppState, InviteAccueilViewModel>(
        onInit: (store) => store.dispatch(ActionPlanRequestAction()),
        converter: InviteAccueilViewModel.create,
        onInitialBuild: _onViewModel,
        onDidChange: (_, viewModel) => _onViewModel(viewModel),
        distinct: true,
        builder: (context, viewModel) {
          return CustomScrollView(
            slivers: [
              PrimarySliverAppbar(title: viewModel.greeting, withNewNotifications: false),
              SliverToBoxAdapter(child: _Content(viewModel: viewModel)),
            ],
          );
        },
      ),
    );
  }

  void _onViewModel(InviteAccueilViewModel viewModel) {
    _handleNotificationsBottomSheet(viewModel);
    _trackPlanDisplay(viewModel);
  }

  // Sent once per display state (not on every rebuild, nor when the plan reloads with the same state).
  void _trackPlanDisplay(InviteAccueilViewModel viewModel) {
    final event = viewModel.planDisplayEvent;
    if (event == null || event.action == _lastPlanDisplayAction) return;
    _lastPlanDisplayAction = event.action;
    event.send();
  }

  void _handleNotificationsBottomSheet(InviteAccueilViewModel viewModel) {
    if (!viewModel.shouldShowAllowNotifications || _notificationsBottomSheetShown) return;
    _notificationsBottomSheetShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      NotificationsBottomSheet.show(context);
    });
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.viewModel});

  final InviteAccueilViewModel viewModel;

  Future<void> _onModifierPressed(BuildContext context) async {
    const ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanModifierAction).send();
    final shouldResume = await ActionPlanFeedbackBottomSheet.show(context);
    if (!context.mounted || shouldResume != true) return;
    viewModel.resumeOnboarding(OnboardingQuestionnaireEntryPoint.accueilModifier);
  }

  @override
  Widget build(BuildContext context) {
    if (viewModel.displayState == DisplayState.LOADING) {
      return Padding(
        padding: const EdgeInsets.all(Margins.spacing_xl),
        child: Center(child: CircularProgressIndicator(semanticsLabel: Strings.inviteAccueilPlanLoadingA11y)),
      );
    }

    final questionnaireDescription = viewModel.mode == InviteAccueilMode.incomplet
        ? Strings.inviteAccueilQuestionnaireDescriptionIncomplet
        : Strings.inviteAccueilQuestionnaireDescription;

    return Padding(
      padding: const EdgeInsets.all(Margins.spacing_base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (viewModel.showDiscoveryTile) ...[
            InviteDiscoveryTile(
              progressPercent: viewModel.discoveryProgressPercent,
              isCompleted: viewModel.discoveryCompleted,
              onHide: viewModel.hideDiscovery,
            ),
            const SizedBox(height: Margins.spacing_s),
          ],
          if (viewModel.showQuestionnaireCard && viewModel.mode == InviteAccueilMode.incomplet) ...[
            OnboardingQuestionnaireProgressCard(
              answers: viewModel.answers,
              onResume: () => viewModel.resumeOnboarding(OnboardingQuestionnaireEntryPoint.accueilIncomplet),
              description: questionnaireDescription,
            ),
            const SizedBox(height: Margins.spacing_s),
          ],
          if (viewModel.showPlanSection) ...[
            Semantics(
              header: true,
              child: Text(
                Strings.inviteAccueilPlanTitle,
                style: DsfrTextStyle.headline3(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ),
            if (!viewModel.showPlanEmptyState) ...[
              const SizedBox(height: Margins.spacing_base),
              Text(
                viewModel.planSubtitle,
                style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ],
            const SizedBox(height: Margins.spacing_base),
            if (viewModel.showPlanEmptyState)
              InviteActionPlanEmptyState(
                kind: viewModel.planEmptyKind!,
                showRetry: viewModel.showRetryGenerate,
                showModifier: viewModel.showModifierButton,
                onRetry: () {
                  const ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanRetryAction).send();
                  viewModel.retryGenerate();
                },
                onModifier: () {
                  const ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanEmptyModifierAction).send();
                  viewModel.resumeOnboarding(OnboardingQuestionnaireEntryPoint.planVideModifier);
                },
              )
            else
              InviteActionPlanSection(
                plan: viewModel.plan,
                onToggleDone: viewModel.toggleDone,
                onDelete: viewModel.deleteAction,
                onObjectiveExpanded: viewModel.onPlanActionExpanded,
              ),
          ],
          if (viewModel.showQuestionnaireCard && viewModel.mode == InviteAccueilMode.partiel) ...[
            const SizedBox(height: Margins.spacing_base),
            OnboardingQuestionnaireProgressCard(
              answers: viewModel.answers,
              onResume: () => viewModel.resumeOnboarding(OnboardingQuestionnaireEntryPoint.accueilPartiel),
              description: questionnaireDescription,
            ),
          ],
          if (viewModel.showModifierButton && !viewModel.showPlanEmptyState) ...[
            const SizedBox(height: Margins.spacing_base),
            DsfrButton(
              label: Strings.inviteAccueilModifier,
              icon: DsfrIcons.designEditLine,
              variant: DsfrButtonVariant.secondary,
              size: DsfrComponentSize.lg,
              onPressed: () => _onModifierPressed(context),
            ),
          ],
          if (viewModel.showExplorerTip) ...[
            const SizedBox(height: Margins.spacing_s),
            DecoratedBox(
              decoration: BoxDecoration(
                color: DsfrColorDecisions.backgroundDefaultGrey(context),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: DsfrColorDecisions.artworkDecorativeBlueFrance(context)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Margins.spacing_base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.inviteAccueilExplorerTipTitle,
                      style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                    ),
                    Text(
                      Strings.inviteAccueilExplorerTipBody,
                      style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textTitleGrey(context)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (viewModel.showConseillerCta) ...[
            const SizedBox(height: Margins.spacing_base),
            Semantics(
              button: true,
              child: Material(
                color: DsfrColorDecisions.artworkDecorativeBlueFrance(context),
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  onTap: () {
                    // Not implemented yet
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(Margins.spacing_base),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/dsfr/avatar.webp',
                          width: 54,
                          height: 54,
                          excludeFromSemantics: true,
                        ),
                        const SizedBox(width: Margins.spacing_base),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Strings.inviteAccueilConseillerTitle,
                                style: DsfrTextStyle.bodyMdBold(
                                  color: DsfrColorDecisions.textTitleBlueFrance(context),
                                ),
                              ),
                              Text(
                                Strings.inviteAccueilConseillerBody,
                                style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
                              ),
                            ],
                          ),
                        ),
                        Icon(DsfrIcons.systemArrowRightSLine, color: DsfrColorDecisions.textTitleBlueFrance(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: Margins.spacing_xl),
        ],
      ),
    );
  }
}
