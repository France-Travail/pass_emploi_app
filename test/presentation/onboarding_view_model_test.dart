import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/onboarding.dart';
import 'package:pass_emploi_app/presentation/onboarding_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';

import '../dsl/app_state_dsl.dart';

void main() {
  test('milo user without plan action should see message and agenda steps', () {
    final store = givenState()
        .loggedInMiloUser()
        .withOnboardingSuccessState(Onboarding())
        .store();

    final viewModel = OnboardingViewModel.create(store);

    expect(viewModel.withMessageStep, isTrue);
    expect(viewModel.withPlanActionStep, isFalse);
    expect(viewModel.withActionStep, isTrue);
    expect(viewModel.actionStepLabel, Strings.actionOnboardingSection);
    expect(viewModel.totalSteps, 5);
    expect(viewModel.completedSteps, 1);
  });

  test('milo user with plan action should see plan action step before agenda step', () {
    final store = givenState()
        .loggedInMiloUser()
        .withPlanActionFonctionnalite()
        .withOnboardingSuccessState(Onboarding())
        .store();

    final viewModel = OnboardingViewModel.create(store);

    expect(viewModel.withMessageStep, isTrue);
    expect(viewModel.withPlanActionStep, isTrue);
    expect(viewModel.withActionStep, isTrue);
    expect(viewModel.totalSteps, 6);
  });

  test('invite user should see plan action step but neither chat nor agenda steps', () {
    final store = givenState()
        .loggedInUser(loginMode: LoginMode.INVITE)
        .withOnboardingSuccessState(Onboarding())
        .store();

    final viewModel = OnboardingViewModel.create(store);

    expect(viewModel.withMessageStep, isFalse);
    expect(viewModel.withPlanActionStep, isTrue);
    expect(viewModel.withActionStep, isFalse);
    expect(viewModel.totalSteps, 4);
  });

  test('ft espace candidat should hide chat and agenda steps', () {
    final store = givenState()
        .loggedInUser(loginMode: LoginMode.POLE_EMPLOI, accompagnement: Accompagnement.ftEspaceCandidat)
        .withOnboardingSuccessState(Onboarding())
        .store();

    final viewModel = OnboardingViewModel.create(store);

    expect(viewModel.withMessageStep, isFalse);
    expect(viewModel.withPlanActionStep, isFalse);
    expect(viewModel.withActionStep, isFalse);
    expect(viewModel.totalSteps, 3);
  });

  test('ft demandeur d emploi should hide chat step but keep agenda step', () {
    final store = givenState()
        .loggedInUser(loginMode: LoginMode.POLE_EMPLOI, accompagnement: Accompagnement.ftDemandeurDEmploi)
        .withOnboardingSuccessState(Onboarding())
        .store();

    final viewModel = OnboardingViewModel.create(store);

    expect(viewModel.withMessageStep, isFalse);
    expect(viewModel.withPlanActionStep, isFalse);
    expect(viewModel.withActionStep, isTrue);
    expect(viewModel.actionStepLabel, Strings.demarcheOnboardingSection);
    expect(viewModel.totalSteps, 4);
  });

  test('avenir pro should hide agenda action step', () {
    final store = givenState()
        .loggedInUser(accompagnement: Accompagnement.avenirPro)
        .withOnboardingSuccessState(Onboarding())
        .store();

    final viewModel = OnboardingViewModel.create(store);

    expect(viewModel.withMessageStep, isTrue);
    expect(viewModel.withPlanActionStep, isFalse);
    expect(viewModel.withActionStep, isFalse);
    expect(viewModel.totalSteps, 4);
  });

  test('avenir pro with plan action should show plan action step but not agenda step', () {
    final store = givenState()
        .loggedInUser(accompagnement: Accompagnement.avenirPro)
        .withPlanActionFonctionnalite()
        .withOnboardingSuccessState(Onboarding())
        .store();

    final viewModel = OnboardingViewModel.create(store);

    expect(viewModel.withPlanActionStep, isTrue);
    expect(viewModel.withActionStep, isFalse);
    expect(viewModel.totalSteps, 5);
  });
}
