import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/configuration/configuration.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/presentation/login_page_view_model.dart';

import '../doubles/fixtures.dart';
import '../doubles/spies.dart';
import '../dsl/app_state_dsl.dart';

void main() {
  group('LoginPageViewModel', () {
    test('should not display organism choice when brand is pass emploi', () {
      // Given
      final store = givenPassEmploiState().store();

      // When
      final viewModel = LoginPageViewModel.create(store);

      // Then
      expect(viewModel.withOrganismChoice, false);
      expect(viewModel.onMissionLocaleLogin, isNull);
    });

    test('should display organism choice when brand is CEJ', () {
      // Given
      final store = givenState().store();

      // When
      final viewModel = LoginPageViewModel.create(store);

      // Then
      expect(viewModel.withOrganismChoice, true);
      expect(viewModel.onMissionLocaleLogin, isNotNull);
    });

    test('should display invite button only in staging', () {
      // Given
      final stagingStore = givenState(configuration(flavor: Flavor.STAGING)).store();
      final prodStore = givenState(configuration(flavor: Flavor.PROD)).store();

      // When
      final stagingVm = LoginPageViewModel.create(stagingStore);
      final prodVm = LoginPageViewModel.create(prodStore);

      // Then
      expect(stagingVm.withInviteButton, true);
      expect(stagingVm.onInviteLogin, isNotNull);
      expect(prodVm.withInviteButton, false);
      expect(prodVm.onInviteLogin, isNull);
    });

    test('View model displays loading when login state is loading', () {
      // Given
      final store = givenState().copyWith(loginState: LoginLoadingState()).store();

      // When
      final viewModel = LoginPageViewModel.create(store);

      // Then
      expect(viewModel.withLoading, isTrue);
      expect(viewModel.withWrongDeviceClockMessage, isFalse);
      expect(viewModel.technicalErrorMessage, isNull);
    });

    test('View model displays error message when login state is generic failure', () {
      // Given
      final store = givenState().copyWith(loginState: LoginGenericFailureState('error-message')).store();

      // When
      final viewModel = LoginPageViewModel.create(store);

      // Then
      expect(viewModel.withLoading, isFalse);
      expect(viewModel.withWrongDeviceClockMessage, isFalse);
      expect(viewModel.technicalErrorMessage, 'error-message');
    });

    test('View model displays specific message when login state is wrong device clock failure', () {
      // Given
      final store = givenState().copyWith(loginState: LoginWrongDeviceClockState()).store();

      // When
      final viewModel = LoginPageViewModel.create(store);

      // Then
      expect(viewModel.withLoading, isFalse);
      expect(viewModel.withWrongDeviceClockMessage, isTrue);
      expect(viewModel.technicalErrorMessage, isNull);
    });

    test('View model displays content when login state is not logged in', () {
      // Given
      final store = givenState().copyWith(loginState: UserNotLoggedInState()).store();

      // When
      final viewModel = LoginPageViewModel.create(store);

      // Then
      expect(viewModel.withLoading, isFalse);
      expect(viewModel.withWrongDeviceClockMessage, isFalse);
      expect(viewModel.technicalErrorMessage, isNull);
    });

    test('France Travail login dispatches RequestLoginAction', () {
      // Given
      final store = StoreSpy.withState(givenState(configuration(flavor: Flavor.PROD, brand: Brand.cej)));
      final viewModel = LoginPageViewModel.create(store);

      // When
      viewModel.onFranceTravailLogin();

      // Then
      expect(store.dispatchedAction, isA<RequestLoginAction>());
      expect((store.dispatchedAction as RequestLoginAction).mode, LoginMode.POLE_EMPLOI);
    });

    test('Mission Locale login dispatches RequestLoginAction', () {
      // Given
      final store = StoreSpy.withState(givenState(configuration(flavor: Flavor.PROD, brand: Brand.cej)));
      final viewModel = LoginPageViewModel.create(store);

      // When
      viewModel.onMissionLocaleLogin!.call();

      // Then
      expect(store.dispatchedAction, isA<RequestLoginAction>());
      expect((store.dispatchedAction as RequestLoginAction).mode, LoginMode.MILO);
    });

    test('Invite login dispatches RequestLoginAction in staging', () {
      // Given
      final store = StoreSpy.withState(givenState(configuration(flavor: Flavor.STAGING, brand: Brand.cej)));
      final viewModel = LoginPageViewModel.create(store);

      // When
      viewModel.onInviteLogin!.call();

      // Then
      expect(store.dispatchedAction, isA<RequestLoginAction>());
      expect((store.dispatchedAction as RequestLoginAction).mode, LoginMode.INVITE);
    });

    group('accessibility level', () {
      test('should display accessibility partially conform when brand is cej', () {
        // Given
        final store = givenState().store();

        // When
        final viewModel = LoginPageViewModel.create(store);

        // Then
        expect(viewModel.accessibilityLevelLabel, "Accessibilité : partiellement conforme");
      });

      test('should display accessibility not conform when brand is pass emploi', () {
        // Given
        final store = givenPassEmploiState().store();

        // When
        final viewModel = LoginPageViewModel.create(store);

        // Then
        expect(viewModel.accessibilityLevelLabel, "Accessibilité : non conforme");
      });
    });
  });
}
