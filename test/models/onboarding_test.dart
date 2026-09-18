import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/onboarding.dart';

void main() {
  const allSteps = OnboardingStepsVisibility(
    withMessageStep: true,
    withPlanActionStep: true,
    withActionStep: true,
  );
  const withoutPlanAction = OnboardingStepsVisibility(
    withMessageStep: true,
    withPlanActionStep: false,
    withActionStep: true,
  );
  const withoutAction = OnboardingStepsVisibility(
    withMessageStep: true,
    withPlanActionStep: false,
    withActionStep: false,
  );
  const inviteSteps = OnboardingStepsVisibility(
    withMessageStep: false,
    withPlanActionStep: true,
    withActionStep: false,
  );

  test('isCompleted should return true if all required steps are completed', () {
    final onboarding = Onboarding(
      messageCompleted: true,
      planActionCompleted: true,
      actionCompleted: true,
      offreCompleted: true,
      evenementCompleted: true,
    );

    expect(onboarding.isCompleted(allSteps), isTrue);
  });

  test('isCompleted should return false if any required step is not completed', () {
    final onboarding = Onboarding(
      messageCompleted: true,
      planActionCompleted: true,
      actionCompleted: true,
      offreCompleted: true,
      evenementCompleted: false,
    );

    expect(onboarding.isCompleted(allSteps), isFalse);
  });

  test('isCompleted should ignore action when it is not required', () {
    final onboarding = Onboarding(
      messageCompleted: true,
      actionCompleted: false,
      offreCompleted: true,
      evenementCompleted: true,
    );

    expect(onboarding.isCompleted(withoutAction), isTrue);
  });

  test('isCompleted should ignore message and action when they are not required', () {
    final onboarding = Onboarding(
      planActionCompleted: true,
      offreCompleted: true,
      evenementCompleted: true,
    );

    expect(onboarding.isCompleted(inviteSteps), isTrue);
  });

  test('isCompleted should return false if plan action step is required but not completed', () {
    final onboarding = Onboarding(
      messageCompleted: true,
      actionCompleted: true,
      offreCompleted: true,
      evenementCompleted: true,
    );

    expect(onboarding.isCompleted(allSteps), isFalse);
  });

  test('totalSteps should count only visible steps', () {
    expect(Onboarding().totalSteps(withoutPlanAction), 5);
    expect(Onboarding().totalSteps(allSteps), 6);
    expect(Onboarding().totalSteps(withoutAction), 4);
    expect(Onboarding().totalSteps(inviteSteps), 4);
  });

  test('completedSteps should include the install step', () {
    expect(Onboarding().completedSteps(withoutPlanAction), 1);
    expect(
      Onboarding(planActionCompleted: true, offreCompleted: true).completedSteps(inviteSteps),
      3,
    );
  });
}
