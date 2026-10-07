import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_repository.dart';

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

class ActionPlanFeedbackAction {
  final String objectiveId;

  ActionPlanFeedbackAction(this.objectiveId);
}

class ActionPlanDeclareAction {
  final String actionId;
  final DateTime date;
  final String? commentaire;

  ActionPlanDeclareAction(this.actionId, this.date, this.commentaire);
}

class ActionPlanDeclarationResetAction {}

class ActionPlanDeclarationLoadingAction {
  final String actionId;

  ActionPlanDeclarationLoadingAction(this.actionId);
}

class ActionPlanDeclarationSuccessAction {
  final String actionId;

  ActionPlanDeclarationSuccessAction(this.actionId);
}

class ActionPlanDeclarationFailureAction {
  final String actionId;
  final ActionPlanDeclarationFailureReason reason;

  ActionPlanDeclarationFailureAction(this.actionId, this.reason);
}
