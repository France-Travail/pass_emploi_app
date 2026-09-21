import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

class OnboardingQuestionnaireSuccessAction {
  final bool finished;
  final bool everFinished;
  final OnboardingQuestionnaireAnswers answers;

  OnboardingQuestionnaireSuccessAction({required this.finished, required this.answers, this.everFinished = false});
}

class OnboardingQuestionnaireRequestAction {}

class OnboardingQuestionnaireCompleteAction {
  final OnboardingQuestionnaireAnswers answers;

  OnboardingQuestionnaireCompleteAction(this.answers);
}

class OnboardingQuestionnaireFinishAction {
  final OnboardingQuestionnaireAnswers answers;

  OnboardingQuestionnaireFinishAction(this.answers);
}

class OnboardingQuestionnaireResumeAction {}

class OnboardingQuestionnaireAnswersUpdatedAction {
  final OnboardingQuestionnaireAnswers answers;

  OnboardingQuestionnaireAnswersUpdatedAction(this.answers);
}
