import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';

OnboardingQuestionnaireState onboardingQuestionnaireReducer(OnboardingQuestionnaireState current, dynamic action) {
  if (action is OnboardingQuestionnaireSuccessAction) {
    return OnboardingQuestionnaireSuccessState(
      finished: action.finished,
      everFinished: action.everFinished,
      answers: action.answers,
    );
  }
  if (action is OnboardingQuestionnaireAnswersUpdatedAction) {
    final finished = current is OnboardingQuestionnaireSuccessState ? current.finished : false;
    final everFinished = current is OnboardingQuestionnaireSuccessState ? current.everFinished : false;
    return OnboardingQuestionnaireSuccessState(finished: finished, everFinished: everFinished, answers: action.answers);
  }
  return current;
}
