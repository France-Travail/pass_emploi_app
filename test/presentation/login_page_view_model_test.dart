import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/configuration/configuration.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_actions.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_state.dart';
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
      expect(viewModel.withThemedAppLogo, true);
      expect(viewModel.title, "Bienvenue");
      expect(viewModel.subtitle, "L'app dédiée à votre accompagnement");
      expect(
        viewModel.description,
        "Utilisez votre compte France Travail pour accéder à vos messages, vos démarches, offres et rendez-vous.",
      );
    });

    test('should display organism choice when brand is CEJ', () {
      // Given
      final store = givenState().store();

      // When
      final viewModel = LoginPageViewModel.create(store);

      // Then
      expect(viewModel.withOrganismChoice, true);
      expect(viewModel.onMissionLocaleLogin, isNotNull);
      expect(viewModel.withThemedAppLogo, false);
      expect(viewModel.title, "Choisis un compte");
      expect(viewModel.subtitle, isNull);
      expect(
        viewModel.description,
        "Si tu disposes de plusieurs accès, sélectionne l'organisme qui t'accompagne actuellement.",
      );
    });

    group('hidden invite access', () {
      test('should accept only the password from remote config', () {
        // Given
        final store = givenState().withFeatureFlip(inviteAccessPassword: "remote-password!").store();
        final viewModel = LoginPageViewModel.create(store);

        // When & Then
        expect(viewModel.isInviteAccessPasswordValid("remote-password!"), isTrue);
        expect(viewModel.isInviteAccessPasswordValid(""), isFalse);
        expect(viewModel.isInviteAccessPasswordValid("remote-password"), isFalse);
        expect(viewModel.isInviteAccessPasswordValid("REMOTE-PASSWORD!"), isFalse);
      });

      test('should reject any password when remote config has none', () {
        // Given
        final viewModel = LoginPageViewModel.create(givenState().store());

        // When & Then
        expect(viewModel.isInviteAccessPasswordValid(""), isFalse);
        expect(viewModel.isInviteAccessPasswordValid("1j1s2026!"), isFalse);
      });
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

    for (final flavor in [Flavor.STAGING, Flavor.PROD]) {
      test('Invite login dispatches RequestLoginAction in $flavor', () {
        // Given
        final store = StoreSpy.withState(givenState(configuration(flavor: flavor, brand: Brand.cej)));
        final viewModel = LoginPageViewModel.create(store);

        // When
        viewModel.onInviteLogin();

        // Then
        expect(store.dispatchedAction, isA<RequestLoginAction>());
        expect((store.dispatchedAction as RequestLoginAction).mode, LoginMode.INVITE);
      });
    }

    group('reprise compte invite', () {
      test('should display back button and hide hidden invite access', () {
        // Given
        final store = givenState().loggedInUser(loginMode: LoginMode.INVITE).store();

        // When
        final viewModel = LoginPageViewModel.create(store, repriseCompteInvite: true);

        // Then
        expect(viewModel.withBackButton, isTrue);
        expect(viewModel.withHiddenInviteAccess, isFalse);
      });

      test('should not display back button and display hidden invite access on regular login', () {
        // Given
        final store = givenState().store();

        // When
        final viewModel = LoginPageViewModel.create(store);

        // Then
        expect(viewModel.withBackButton, isFalse);
        expect(viewModel.withHiddenInviteAccess, isTrue);
      });

      test('should display loading from reprise state, not from login state', () {
        // Given
        final store = givenState()
            .loggedInUser(loginMode: LoginMode.INVITE)
            .copyWith(repriseCompteInviteState: RepriseCompteInviteLoadingState())
            .store();

        // When
        final viewModel = LoginPageViewModel.create(store, repriseCompteInvite: true);

        // Then
        expect(viewModel.withLoading, isTrue);
        expect(viewModel.withWrongDeviceClockMessage, isFalse);
        expect(viewModel.technicalErrorMessage, isNull);
      });

      test('should display error message from reprise state', () {
        // Given
        final store = givenState()
            .loggedInUser(loginMode: LoginMode.INVITE)
            .copyWith(repriseCompteInviteState: RepriseCompteInviteFailureState('error-message'))
            .store();

        // When
        final viewModel = LoginPageViewModel.create(store, repriseCompteInvite: true);

        // Then
        expect(viewModel.withLoading, isFalse);
        expect(viewModel.technicalErrorMessage, 'error-message');
      });

      test('should display wrong device clock message from reprise state', () {
        // Given
        final store = givenState()
            .loggedInUser(loginMode: LoginMode.INVITE)
            .copyWith(repriseCompteInviteState: RepriseCompteInviteWrongDeviceClockState())
            .store();

        // When
        final viewModel = LoginPageViewModel.create(store, repriseCompteInvite: true);

        // Then
        expect(viewModel.withWrongDeviceClockMessage, isTrue);
      });

      test('France Travail login dispatches RepriseCompteInviteRequestAction', () {
        // Given
        final store = StoreSpy.withState(givenState(configuration(flavor: Flavor.PROD, brand: Brand.cej)));
        final viewModel = LoginPageViewModel.create(store, repriseCompteInvite: true);

        // When
        viewModel.onFranceTravailLogin();

        // Then
        expect(store.dispatchedAction, isA<RepriseCompteInviteRequestAction>());
        expect((store.dispatchedAction as RepriseCompteInviteRequestAction).mode, LoginMode.POLE_EMPLOI);
      });

      test('Mission Locale login dispatches RepriseCompteInviteRequestAction', () {
        // Given
        final store = StoreSpy.withState(givenState(configuration(flavor: Flavor.PROD, brand: Brand.cej)));
        final viewModel = LoginPageViewModel.create(store, repriseCompteInvite: true);

        // When
        viewModel.onMissionLocaleLogin!.call();

        // Then
        expect(store.dispatchedAction, isA<RepriseCompteInviteRequestAction>());
        expect((store.dispatchedAction as RepriseCompteInviteRequestAction).mode, LoginMode.MILO);
      });
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
