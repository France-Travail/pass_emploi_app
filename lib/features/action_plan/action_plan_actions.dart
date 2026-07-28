import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

class ActionPlanRequestAction {}

class ActionPlanGenerateAction {
  final OnboardingQuestionnaireAnswers answers;

  ActionPlanGenerateAction(this.answers);
}

class ActionPlanLoadingAction {}

class ActionPlanSuccessAction {
  final ActionPlan plan;

  ActionPlanSuccessAction(this.plan);
}

class ActionPlanEmptyAction {}

class ActionPlanFailureAction {}

class ActionPlanToggleDoneAction {
  final String actionId;

  ActionPlanToggleDoneAction(this.actionId);
}

class ActionPlanDeleteAction {
  final String actionId;

  ActionPlanDeleteAction(this.actionId);
}
