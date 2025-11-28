import 'package:pass_emploi_app/features/onboarding/onboarding_actions.dart';
import 'package:pass_emploi_app/features/onboarding/onboarding_state.dart';

OnboardingState onboardingReducer(OnboardingState current, dynamic action) {
  if (action is OnboardingSuccessAction) return _updateOnboarding(current, action);
  if (action is OnboardingStartedAction) {
    return switch (action) {
      MessageOnboardingStartedAction() => current.copyWith(showMessageOnboarding: true),
      ActionOnboardingStartedAction() => current.copyWith(showActionOnboarding: true),
      OffreOnboardingStartedAction() => current.copyWith(showOffreOnboarding: true),
      EvenementOnboardingStartedAction() => current.copyWith(showEvenementOnboarding: true),
      OutilsOnboardingStartedAction() => current.copyWith(showOutilsOnboarding: true),
    };
  }
  if (action is ResetOnboardingShowcaseAction) {
    return current.copyWith(
      showMessageOnboarding: false,
      showActionOnboarding: false,
      showOffreOnboarding: false,
      showEvenementOnboarding: false,
      showOutilsOnboarding: false,
    );
  }
  return current;
}

OnboardingState _updateOnboarding(OnboardingState current, OnboardingSuccessAction action) {
  return current.copyWith(
    onboarding: action.onboarding,
    showMessageOnboarding: current.showMessageOnboarding && !action.onboarding.messageCompleted,
    showActionOnboarding: current.showActionOnboarding && !action.onboarding.actionCompleted,
    showOffreOnboarding: current.showOffreOnboarding && !action.onboarding.offreCompleted,
    showEvenementOnboarding: current.showEvenementOnboarding && !action.onboarding.evenementCompleted,
    showOutilsOnboarding: current.showOutilsOnboarding && !action.onboarding.outilsCompleted,
  );
}
