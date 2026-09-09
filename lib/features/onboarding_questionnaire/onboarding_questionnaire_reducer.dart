import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';

OnboardingQuestionnaireState onboardingQuestionnaireReducer(OnboardingQuestionnaireState current, dynamic action) {
  if (action is OnboardingQuestionnaireSuccessAction) {
    return OnboardingQuestionnaireSuccessState(finished: action.finished, answers: action.answers);
  }
  if (action is OnboardingQuestionnaireAnswersUpdatedAction) {
    final finished = current is OnboardingQuestionnaireSuccessState ? current.finished : false;
    return OnboardingQuestionnaireSuccessState(finished: finished, answers: action.answers);
  }
  return current;
}
