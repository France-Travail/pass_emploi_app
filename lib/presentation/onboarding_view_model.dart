import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/deep_link/deep_link_actions.dart';
import 'package:pass_emploi_app/features/onboarding/onboarding_actions.dart';
import 'package:pass_emploi_app/models/deep_link.dart';
import 'package:pass_emploi_app/models/onboarding.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

class OnboardingViewModel extends Equatable {
  final int completedSteps;
  final int totalSteps;

  final bool withMessageStep;
  final bool messageCompleted;
  final bool withPlanActionStep;
  final bool planActionCompleted;
  final bool withActionStep;
  final bool actionCompleted;
  final bool offreCompleted;
  final bool evenementCompleted;

  final String actionStepLabel;

  final void Function() onMessageOnboarding;
  final void Function() onPlanActionOnboarding;
  final void Function() onActionOnboarding;
  final void Function() onOffreOnboarding;
  final void Function() onEvenementOnboarding;
  final void Function() onSkipOnboarding;

  const OnboardingViewModel({
    required this.completedSteps,
    required this.totalSteps,
    required this.withMessageStep,
    required this.messageCompleted,
    required this.withPlanActionStep,
    required this.planActionCompleted,
    required this.withActionStep,
    required this.actionCompleted,
    required this.offreCompleted,
    required this.evenementCompleted,
    required this.actionStepLabel,
    required this.onMessageOnboarding,
    required this.onPlanActionOnboarding,
    required this.onActionOnboarding,
    required this.onOffreOnboarding,
    required this.onEvenementOnboarding,
    required this.onSkipOnboarding,
  });

  factory OnboardingViewModel.create(Store<AppState> store) {
    final onboardingState = store.state.onboardingState;

    if (onboardingState.onboarding == null) {
      return OnboardingViewModel.empty();
    }

    final onboarding = onboardingState.onboarding!;
    final visibility = store.state.onboardingStepsVisibility();

    return OnboardingViewModel(
      completedSteps: onboarding.completedSteps(visibility),
      totalSteps: onboarding.totalSteps(visibility),
      withMessageStep: visibility.withMessageStep,
      withPlanActionStep: visibility.withPlanActionStep,
      withActionStep: visibility.withActionStep,
      messageCompleted: onboarding.messageCompleted,
      planActionCompleted: onboarding.planActionCompleted,
      actionCompleted: onboarding.actionCompleted,
      offreCompleted: onboarding.offreCompleted,
      evenementCompleted: onboarding.evenementCompleted,
      actionStepLabel: _actionStepLabel(store),
      onMessageOnboarding: () {
        store.dispatch(HandleDeepLinkAction(NouveauMessageDeepLink(), DeepLinkOrigin.inAppNavigation));
        store.dispatch(MessageOnboardingStartedAction());
      },
      onPlanActionOnboarding: () {
        store.dispatch(PlanActionOnboardingStartedAction());
      },
      onActionOnboarding: () {
        store.dispatch(HandleDeepLinkAction(MonSuiviDeepLink(), DeepLinkOrigin.inAppNavigation));
        store.dispatch(ActionOnboardingStartedAction());
      },
      onOffreOnboarding: () {
        store.dispatch(HandleDeepLinkAction(RechercheDeepLink(), DeepLinkOrigin.inAppNavigation));
        store.dispatch(OffreOnboardingStartedAction());
      },
      onEvenementOnboarding: () {
        store.dispatch(HandleDeepLinkAction(EventSearchDeepLink(), DeepLinkOrigin.inAppNavigation));
        store.dispatch(EvenementOnboardingStartedAction());
      },
      onSkipOnboarding: () {
        store.dispatch(OnboardingHideAction());
      },
    );
  }

  factory OnboardingViewModel.empty() {
    return OnboardingViewModel(
      completedSteps: 0,
      totalSteps: 0,
      withMessageStep: false,
      messageCompleted: false,
      withPlanActionStep: false,
      planActionCompleted: false,
      withActionStep: false,
      actionCompleted: false,
      offreCompleted: false,
      evenementCompleted: false,
      actionStepLabel: Strings.actionOnboardingSection,
      onMessageOnboarding: () {},
      onPlanActionOnboarding: () {},
      onActionOnboarding: () {},
      onOffreOnboarding: () {},
      onEvenementOnboarding: () {},
      onSkipOnboarding: () {},
    );
  }

  @override
  List<Object?> get props => [
        completedSteps,
        totalSteps,
        withMessageStep,
        messageCompleted,
        withPlanActionStep,
        planActionCompleted,
        withActionStep,
        actionCompleted,
        offreCompleted,
        evenementCompleted,
        actionStepLabel,
      ];
}

String _actionStepLabel(Store<AppState> store) {
  return store.state.isMiloLoginMode() ? Strings.actionOnboardingSection : Strings.demarcheOnboardingSection;
}
