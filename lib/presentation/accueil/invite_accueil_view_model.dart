import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

enum InviteAccueilMode { incomplet, partiel, complet }

class InviteAccueilViewModel extends Equatable {
  final DisplayState displayState;
  final InviteAccueilMode mode;
  final String greeting;
  final OnboardingQuestionnaireAnswers answers;
  final ActionPlan? plan;
  final String planSubtitle;
  final bool showQuestionnaireCard;
  final bool showLockedPlan;
  final bool showConseillerCta;
  final bool showModifierButton;
  final bool showExplorerTip;
  final bool showRetryGenerate;
  final VoidCallback retryLoad;
  final VoidCallback resumeOnboarding;
  final VoidCallback retryGenerate;
  final void Function(String actionId) toggleDone;
  final void Function(String actionId) deleteAction;

  const InviteAccueilViewModel({
    required this.displayState,
    required this.mode,
    required this.greeting,
    required this.answers,
    required this.plan,
    required this.planSubtitle,
    required this.showQuestionnaireCard,
    required this.showLockedPlan,
    required this.showConseillerCta,
    required this.showModifierButton,
    required this.showExplorerTip,
    required this.showRetryGenerate,
    required this.retryLoad,
    required this.resumeOnboarding,
    required this.retryGenerate,
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
    final displayState = switch (actionPlanState) {
      ActionPlanLoadingState() || ActionPlanNotInitializedState() => DisplayState.LOADING,
      ActionPlanFailureState() => mode == InviteAccueilMode.incomplet ? DisplayState.CONTENT : DisplayState.FAILURE,
      _ => DisplayState.CONTENT,
    };

    final prenom = answers.prenom?.trim().isNotEmpty == true ? answers.prenom : store.state.user()?.firstName;

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
      showQuestionnaireCard: mode != InviteAccueilMode.complet,
      showLockedPlan: mode == InviteAccueilMode.incomplet,
      showConseillerCta: mode == InviteAccueilMode.complet,
      showModifierButton: mode == InviteAccueilMode.complet,
      showExplorerTip: mode == InviteAccueilMode.incomplet,
      showRetryGenerate: actionPlanState is ActionPlanFailureState && answers.canGenerateActionPlan,
      retryLoad: () => store.dispatch(ActionPlanRequestAction()),
      resumeOnboarding: () => store.dispatch(OnboardingQuestionnaireResumeAction()),
      retryGenerate: () => store.dispatch(ActionPlanGenerateAction(answers)),
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
    showQuestionnaireCard,
    showLockedPlan,
    showConseillerCta,
    showModifierButton,
    showExplorerTip,
    showRetryGenerate,
  ];
}
