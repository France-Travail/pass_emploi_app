import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/features/onboarding/onboarding_actions.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/onboarding.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

enum InviteAccueilMode { incomplet, partiel, complet }

enum InvitePlanEmptyKind { failure, empty }

class InviteAccueilViewModel extends Equatable {
  final DisplayState displayState;
  final InviteAccueilMode mode;
  final String greeting;
  final OnboardingQuestionnaireAnswers answers;
  final ActionPlan? plan;
  final String planSubtitle;
  final bool showDiscoveryTile;
  final int discoveryProgressPercent;
  final bool discoveryCompleted;
  final bool showQuestionnaireCard;
  final bool showPlanSection;
  final bool showPlanEmptyState;
  final InvitePlanEmptyKind? planEmptyKind;
  final bool showConseillerCta;
  final bool showModifierButton;
  final bool showExplorerTip;
  final bool showRetryGenerate;
  final bool shouldShowAllowNotifications;
  final VoidCallback retryLoad;
  final VoidCallback resumeOnboarding;
  final VoidCallback retryGenerate;
  final VoidCallback hideDiscovery;
  final void Function(String actionId) toggleDone;
  final void Function(String actionId) deleteAction;

  const InviteAccueilViewModel({
    required this.displayState,
    required this.mode,
    required this.greeting,
    required this.answers,
    required this.plan,
    required this.planSubtitle,
    required this.showDiscoveryTile,
    required this.discoveryProgressPercent,
    required this.discoveryCompleted,
    required this.showQuestionnaireCard,
    required this.showPlanSection,
    required this.showPlanEmptyState,
    required this.planEmptyKind,
    required this.showConseillerCta,
    required this.showModifierButton,
    required this.showExplorerTip,
    required this.showRetryGenerate,
    required this.shouldShowAllowNotifications,
    required this.retryLoad,
    required this.resumeOnboarding,
    required this.retryGenerate,
    required this.hideDiscovery,
    required this.toggleDone,
    required this.deleteAction,
  });

  factory InviteAccueilViewModel.create(Store<AppState> store) {
    final inviteState = store.state.onboardingQuestionnaireState;
    final actionPlanState = store.state.actionPlanState;
    final answers = inviteState is OnboardingQuestionnaireSuccessState
        ? inviteState.answers
        : const OnboardingQuestionnaireAnswers();
    final mode = switch (answers.completeness) {
      OnboardingQuestionnaireCompleteness.incomplet => InviteAccueilMode.incomplet,
      OnboardingQuestionnaireCompleteness.partiel => InviteAccueilMode.partiel,
      OnboardingQuestionnaireCompleteness.complet => InviteAccueilMode.complet,
    };

    final plan = actionPlanState is ActionPlanSuccessState ? actionPlanState.plan : null;
    final showPlanSection = mode != InviteAccueilMode.incomplet;
    final displayState = !showPlanSection
        ? DisplayState.CONTENT
        : switch (actionPlanState) {
            ActionPlanLoadingState() || ActionPlanNotInitializedState() => DisplayState.LOADING,
            _ => DisplayState.CONTENT,
          };

    final isFailure = actionPlanState is ActionPlanFailureState;
    final hasNoObjectives = plan == null || plan.objectives.isEmpty;
    final showPlanEmptyState = showPlanSection && (isFailure || hasNoObjectives);
    final planEmptyKind = !showPlanEmptyState
        ? null
        : isFailure
        ? InvitePlanEmptyKind.failure
        : InvitePlanEmptyKind.empty;

    final prenom = answers.prenom?.trim().isNotEmpty == true ? answers.prenom : store.state.user()?.firstName;

    final onboarding = store.state.onboardingState.onboarding;
    final showDiscoveryTile = onboarding?.showOnboarding ?? false;
    final accompagnement = store.state.accompagnement();
    final completedSteps = onboarding != null ? onboarding.completedSteps(accompagnement) : 0;
    final totalSteps = onboarding != null ? onboarding.totalSteps(accompagnement) : 1;
    final discoveryProgressPercent = totalSteps == 0 ? 0 : (100 * completedSteps) ~/ totalSteps;
    final discoveryCompleted = onboarding?.isCompleted(accompagnement) ?? false;

    return InviteAccueilViewModel(
      displayState: displayState,
      mode: mode,
      greeting: Strings.inviteAccueilGreeting(prenom),
      answers: answers,
      plan: plan,
      planSubtitle: switch (mode) {
        InviteAccueilMode.incomplet => Strings.inviteAccueilPlanSubtitleIncomplet,
        InviteAccueilMode.partiel => Strings.inviteAccueilPlanSubtitlePartiel,
        InviteAccueilMode.complet => Strings.inviteAccueilPlanSubtitleComplet,
      },
      showDiscoveryTile: showDiscoveryTile,
      discoveryProgressPercent: discoveryProgressPercent,
      discoveryCompleted: discoveryCompleted,
      showQuestionnaireCard: mode != InviteAccueilMode.complet,
      showPlanSection: showPlanSection,
      showPlanEmptyState: showPlanEmptyState,
      planEmptyKind: planEmptyKind,
      showConseillerCta: mode == InviteAccueilMode.complet,
      // Un seul CTA dans l'empty state : Modifier si plan vide, Réessayer si échec.
      showModifierButton: mode == InviteAccueilMode.complet && planEmptyKind != InvitePlanEmptyKind.failure,
      showExplorerTip: mode == InviteAccueilMode.incomplet,
      showRetryGenerate:
          showPlanEmptyState && planEmptyKind == InvitePlanEmptyKind.failure && answers.canGenerateActionPlan,
      shouldShowAllowNotifications: onboarding?.showNotificationsOnboarding ?? false,
      retryLoad: () => store.dispatch(ActionPlanRequestAction()),
      resumeOnboarding: () => store.dispatch(OnboardingQuestionnaireResumeAction()),
      retryGenerate: () => store.dispatch(ActionPlanGenerateAction(answers)),
      hideDiscovery: () => store.dispatch(OnboardingHideAction()),
      toggleDone: (id) => store.dispatch(ActionPlanToggleDoneAction(id)),
      deleteAction: (id) => store.dispatch(ActionPlanDeleteAction(id)),
    );
  }

  @override
  List<Object?> get props => [
    displayState,
    mode,
    greeting,
    answers,
    plan,
    planSubtitle,
    showDiscoveryTile,
    discoveryProgressPercent,
    discoveryCompleted,
    showQuestionnaireCard,
    showPlanSection,
    showPlanEmptyState,
    planEmptyKind,
    showConseillerCta,
    showModifierButton,
    showExplorerTip,
    showRetryGenerate,
    shouldShowAllowNotifications,
  ];
}
