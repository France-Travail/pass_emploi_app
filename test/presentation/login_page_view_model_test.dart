import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/configuration/configuration.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_actions.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_state.dart';
import 'package:pass_emploi_app/features/too_many_requests/too_many_requests_state.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/presentation/login_page_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';

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
      expect(viewModel.withInviteButton, isFalse);
      expect(viewModel.onInviteLogin, isNull);
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
      expect(viewModel.withInviteButton, isTrue);
      expect(viewModel.onInviteLogin, isNotNull);
      expect(viewModel.withThemedAppLogo, false);
      expect(viewModel.title, "Choisis un compte");
      expect(viewModel.subtitle, isNull);
      expect(
        viewModel.description,
        "Si tu disposes de plusieurs accès, sélectionne l'organisme qui t'accompagne actuellement.",
      );
    });

    for (final flavor in [Flavor.STAGING, Flavor.PROD]) {
      test('should display invite button for CEJ in $flavor', () {
        // Given
        final store = givenState(configuration(flavor: flavor, brand: Brand.cej)).store();

        // When
        final viewModel = LoginPageViewModel.create(store);

        // Then
        expect(viewModel.withInviteButton, isTrue);
        expect(viewModel.onInviteLogin, isNotNull);
      });
    }

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

    test('generic failure description refers to the conseiller', () {
      // Given
      final store = givenState()
          .copyWith(loginState: LoginGenericFailureState('error-message', mode: LoginMode.MILO))
          .store();

      // When
      final viewModel = LoginPageViewModel.create(store);

      // Then
      expect(viewModel.genericErrorDescription, Strings.loginGenericErrorDescription);
      expect(viewModel.withTooManyRequestsMessage, isFalse);
    });

    test('generic failure description does not refer to a conseiller when an invite tried to log in', () {
      // Given
      final store = givenState()
          .copyWith(loginState: LoginGenericFailureState('error-message', mode: LoginMode.INVITE))
          .store();

      // When
      final viewModel = LoginPageViewModel.create(store);

      // Then
      expect(viewModel.technicalErrorMessage, 'error-message');
      expect(viewModel.genericErrorDescription, "Réessaie plus tard.");
    });

    test('View model displays too many requests message when connect refused the login (rate limit)', () {
      // Given
      final store = givenState().copyWith(loginState: LoginTooManyRequestsState()).store();

      // When
      final viewModel = LoginPageViewModel.create(store);

      // Then
      expect(viewModel.withLoading, isFalse);
      expect(viewModel.withTooManyRequestsMessage, isTrue);
      expect(viewModel.withWrongDeviceClockMessage, isFalse);
      expect(viewModel.technicalErrorMessage, isNull);
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
        viewModel.onInviteLogin!();

        // Then
        expect(store.dispatchedAction, isA<RequestLoginAction>());
        expect((store.dispatchedAction as RequestLoginAction).mode, LoginMode.INVITE);
      });
    }

    group('reprise compte invite', () {
      test('should display back button and hide invite button', () {
        // Given
        final store = givenState().loggedInUser(loginMode: LoginMode.INVITE).store();

        // When
        final viewModel = LoginPageViewModel.create(store, repriseCompteInvite: true);

        // Then
        expect(viewModel.withBackButton, isTrue);
        expect(viewModel.withInviteButton, isFalse);
        expect(viewModel.onInviteLogin, isNull);
      });

      test('should not display back button and display invite button on regular CEJ login', () {
        // Given
        final store = givenState().store();

        // When
        final viewModel = LoginPageViewModel.create(store);

        // Then
        expect(viewModel.withBackButton, isFalse);
        expect(viewModel.withInviteButton, isTrue);
        expect(viewModel.onInviteLogin, isNotNull);
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
        expect(viewModel.withTooManyRequestsMessage, isFalse);
        expect(viewModel.genericErrorDescription, isNot(contains('conseiller')));
      });

      test('should display too many requests message when connect refused the login (rate limit)', () {
        // Given
        final store = givenState()
            .loggedInUser(loginMode: LoginMode.INVITE)
            .copyWith(repriseCompteInviteState: RepriseCompteInviteTooManyRequestsState())
            .store();

        // When
        final viewModel = LoginPageViewModel.create(store, repriseCompteInvite: true);

        // Then
        expect(viewModel.withTooManyRequestsMessage, isTrue);
        expect(viewModel.technicalErrorMessage, isNull);
      });

      test('should display too many requests message when the API refused the reprise (429)', () {
        // Given
        final store = givenState()
            .loggedInUser(loginMode: LoginMode.INVITE)
            .copyWith(
              repriseCompteInviteState: RepriseCompteInviteFailureState('error-message'),
              tooManyRequestsState: TooManyRequestsState(retryNotBefore: DateTime.now().add(Duration(minutes: 1))),
            )
            .store();

        // When
        final viewModel = LoginPageViewModel.create(store, repriseCompteInvite: true);

        // Then
        expect(viewModel.withTooManyRequestsMessage, isTrue);
        expect(viewModel.technicalErrorMessage, isNull);
      });

      test('should display generic error once the rate limit is over', () {
        // Given
        final store = givenState()
            .loggedInUser(loginMode: LoginMode.INVITE)
            .copyWith(
              repriseCompteInviteState: RepriseCompteInviteFailureState('error-message'),
              tooManyRequestsState: TooManyRequestsState(retryNotBefore: DateTime.now().subtract(Duration(seconds: 1))),
            )
            .store();

        // When
        final viewModel = LoginPageViewModel.create(store, repriseCompteInvite: true);

        // Then
        expect(viewModel.withTooManyRequestsMessage, isFalse);
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
