import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

class OnboardingQuestionnaireSuccessAction {
  final bool finished;
  final bool everFinished;
  final bool resumedFromApp;
  final OnboardingQuestionnaireAnswers answers;

  OnboardingQuestionnaireSuccessAction({
    required this.finished,
    required this.answers,
    this.everFinished = false,
    this.resumedFromApp = false,
  });
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

// A11y 5.3 : fermeture du questionnaire rouvert depuis l'app, sans déconnexion. Les réponses déjà enregistrées sont conservées.
class OnboardingQuestionnaireCloseResumedAction {}

class OnboardingQuestionnaireAnswersUpdatedAction {
  final OnboardingQuestionnaireAnswers answers;

  OnboardingQuestionnaireAnswersUpdatedAction(this.answers);
}
