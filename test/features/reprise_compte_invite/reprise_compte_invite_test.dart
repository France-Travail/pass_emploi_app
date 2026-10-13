import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/auth/auth_id_token.dart';
import 'package:pass_emploi_app/auth/auth_token_response.dart';
import 'package:pass_emploi_app/auth/authenticator.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_actions.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_state.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

void main() {
  group('RepriseCompteInvite', () {
    final sut = StoreSut();
    late MockAuthenticator authenticator;
    late MockRepriseCompteInviteRepository repository;
    late MockActionPlanRepository actionPlanRepository;
    late MockOnboardingQuestionnaireRepository onboardingQuestionnaireRepository;
    late MockTutorialRepository tutorialRepository;

    setUpAll(() {
      registerFallbackValue(LogoutReason.userLogout);
      registerFallbackValue(AuthenticationMode.SIMILO);
      registerFallbackValue(_tokensMilo);
    });

    setUp(() {
      authenticator = MockAuthenticator();
      repository = MockRepriseCompteInviteRepository();
      actionPlanRepository = MockActionPlanRepository();
      onboardingQuestionnaireRepository = MockOnboardingQuestionnaireRepository();
      tutorialRepository = MockTutorialRepository();
      when(() => tutorialRepository.setTutorialRead()).thenAnswer((_) async {});
      when(() => tutorialRepository.setPlanActionTutorialRead()).thenAnswer((_) async {});
      when(() => tutorialRepository.shouldShowTutorial()).thenAnswer((_) async => false);
      when(() => tutorialRepository.shouldShowPlanActionTutorial()).thenAnswer((_) async => false);
      when(() => authenticator.saveTokens(any())).thenAnswer((_) async {});
      when(() => authenticator.idToken()).thenAnswer((_) async => _miloIdToken());
      when(() => authenticator.isLoggedIn()).thenAnswer((_) async => true);
      when(() => actionPlanRepository.getStoredPlan()).thenAnswer((_) async => null);
    });

    void givenInviteStore() {
      sut.givenStore =
          givenState() //
              .copyWith(
                loginState: LoginSuccessState(mockUser(id: 'id-invite', loginMode: LoginMode.INVITE)),
              )
              .withoutFonctionnalites()
              .store((f) {
                f.authenticator = authenticator;
                f.repriseCompteInviteRepository = repository;
                f.actionPlanRepository = actionPlanRepository;
                f.onboardingQuestionnaireRepository = onboardingQuestionnaireRepository;
                f.tutorialRepository = tutorialRepository;
              });
    }

    void givenMiloLogin(AuthenticatorResponse response) {
      when(() => authenticator.loginWithoutSaving(AuthenticationMode.SIMILO)).thenAnswer((_) async => response);
    }

    void givenReprise({required bool succeeds}) {
      when(
        () => repository.reprendre(
          idInvite: any(named: 'idInvite'),
          jetonConnecte: any(named: 'jetonConnecte'),
          plan: any(named: 'plan'),
        ),
      ).thenAnswer((_) async => succeeds);
    }

    void verifyNeverReprendre() {
      verifyNever(
        () => repository.reprendre(
          idInvite: any(named: 'idInvite'),
          jetonConnecte: any(named: 'jetonConnecte'),
          plan: any(named: 'plan'),
        ),
      );
    }

    group('when requesting with MILO', () {
      sut.whenDispatchingAction(() => RepriseCompteInviteRequestAction(LoginMode.MILO));

      test('should attach the guest account, then save the MILO tokens and log in the MILO account', () async {
        // Given
        givenMiloLogin(SuccessAuthenticatorResponse(tokens: _tokensMilo));
        givenReprise(succeeds: true);
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeLoggedInAsMiloUser()]);
        await untilCalled(() => authenticator.saveTokens(any()));
        verifyInOrder([
          () => authenticator.loginWithoutSaving(AuthenticationMode.SIMILO),
          () => repository.reprendre(
            idInvite: 'id-invite',
            jetonConnecte: 'access-token-milo',
            plan: null,
          ),
          () => authenticator.saveTokens(_tokensMilo),
        ]);
      });

      test('should forget the guest local data so that the MILO account data is displayed', () async {
        // Given
        givenMiloLogin(SuccessAuthenticatorResponse(tokens: _tokensMilo));
        givenReprise(succeeds: true);
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeLoggedInAsMiloUser()]);
        await untilCalled(() => actionPlanRepository.clear());
        verify(() => onboardingQuestionnaireRepository.clear()).called(1);
        verify(() => actionPlanRepository.clear()).called(1);
      });

      test('should not show tutorials to the MILO account, already discovered as guest', () async {
        // Given
        givenMiloLogin(SuccessAuthenticatorResponse(tokens: _tokensMilo));
        givenReprise(succeeds: true);
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeLoggedInAsMiloUser()]);
        await untilCalled(() => tutorialRepository.setPlanActionTutorialRead());
        verify(() => tutorialRepository.setTutorialRead()).called(1);
        verify(() => tutorialRepository.setPlanActionTutorialRead()).called(1);
      });

      test('should keep the guest local data when attaching the guest account fails', () async {
        // Given
        givenMiloLogin(SuccessAuthenticatorResponse(tokens: _tokensMilo));
        givenReprise(succeeds: false);
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldFailWhileStayingGuest()]);
        await pumpEventQueue();
        verifyNever(() => onboardingQuestionnaireRepository.clear());
        verifyNever(() => actionPlanRepository.clear());
        verifyNever(() => tutorialRepository.setPlanActionTutorialRead());
      });

      test('should stay guest without saving the MILO tokens when attaching the guest account fails', () async {
        // Given
        givenMiloLogin(SuccessAuthenticatorResponse(tokens: _tokensMilo));
        givenReprise(succeeds: false);
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldFailWhileStayingGuest()]);
        await pumpEventQueue();
        verifyNever(() => authenticator.saveTokens(any()));
      });

      test('should stay logged in as guest without attaching when login is cancelled', () async {
        // Given
        givenMiloLogin(CancelledAuthenticatorResponse());
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeResetWhileStayingGuest()]);
        await pumpEventQueue();
        verifyNeverReprendre();
      });

      test('should fail with message when login fails', () async {
        // Given
        givenMiloLogin(FailureAuthenticatorResponse('error-message'));
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldFailWithMessage('error-message')]);
        await pumpEventQueue();
        verifyNeverReprendre();
      });

      test('should fail because of wrong clock when device clock is wrong', () async {
        // Given
        givenMiloLogin(WrongDeviceClockAuthenticatorResponse());
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldFailBecauseOfWrongClock()]);
      });
    });

    group('when requesting with POLE_EMPLOI', () {
      sut.whenDispatchingAction(() => RepriseCompteInviteRequestAction(LoginMode.POLE_EMPLOI));

      test('should log in with France Travail authentication mode', () async {
        // Given
        when(
          () => authenticator.loginWithoutSaving(AuthenticationMode.POLE_EMPLOI),
        ).thenAnswer((_) async => CancelledAuthenticatorResponse());
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeReset()]);
        await untilCalled(() => authenticator.loginWithoutSaving(AuthenticationMode.POLE_EMPLOI));
        verify(() => authenticator.loginWithoutSaving(AuthenticationMode.POLE_EMPLOI)).called(1);
      });
    });

    group('when user is not a guest', () {
      sut.whenDispatchingAction(() => RepriseCompteInviteRequestAction(LoginMode.MILO));

      test('should do nothing', () async {
        // Given
        sut.givenStore =
            givenState() //
                .loggedInUser(loginMode: LoginMode.MILO)
                .store((f) {
                  f.authenticator = authenticator;
                  f.repriseCompteInviteRepository = repository;
                });

        // Then
        await sut.thenExpectNever(_shouldLoad());
      });
    });

    group('when guest has a local action plan', () {
      sut.whenDispatchingAction(() => RepriseCompteInviteRequestAction(LoginMode.MILO));

      test('should send the local plan described with its idSolution', () async {
        // Given
        final localPlan = _planWith(
          const ActionPlanAction(
            id: 'action-1',
            label: 'Faire un CV',
            kind: ActionPlanActionKind.advice,
            done: true,
            idSolution: 'solution-123',
          ),
        );
        when(() => actionPlanRepository.getStoredPlan()).thenAnswer((_) async => localPlan);
        givenMiloLogin(SuccessAuthenticatorResponse(tokens: _tokensMilo));
        givenReprise(succeeds: true);
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeLoggedInAsMiloUser()]);
        await untilCalled(() => authenticator.saveTokens(any()));
        verify(
          () => repository.reprendre(
            idInvite: 'id-invite',
            jetonConnecte: 'access-token-milo',
            plan: localPlan.toApiReprise(),
          ),
        ).called(1);
      });

      test('should not send a plan stored before idSolution existed', () async {
        // Given
        when(() => actionPlanRepository.getStoredPlan()).thenAnswer(
          (_) async => _planWith(const ActionPlanAction(id: 'action-1', label: 'A', kind: ActionPlanActionKind.advice)),
        );
        givenMiloLogin(SuccessAuthenticatorResponse(tokens: _tokensMilo));
        givenReprise(succeeds: true);
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeLoggedInAsMiloUser()]);
        await untilCalled(() => authenticator.saveTokens(any()));
        verify(
          () => repository.reprendre(
            idInvite: 'id-invite',
            jetonConnecte: 'access-token-milo',
            plan: null,
          ),
        ).called(1);
      });
    });
  });
}

final _tokensMilo = AuthTokenResponse(
  idToken: _unsignedJwt({
    'userId': 'id-jeune',
    'given_name': 'F',
    'family_name': 'L',
    'iat': 90000000,
    'exp': 100000000,
    'userStructure': 'MILO',
  }),
  accessToken: 'access-token-milo',
  refreshToken: 'refresh-token-milo',
);

String _unsignedJwt(Map<String, dynamic> payload) {
  String encode(Map<String, dynamic> json) => base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${encode({'alg': 'none'})}.${encode(payload)}.';
}

ActionPlan _planWith(ActionPlanAction action) => ActionPlan(
  id: 'plan-1',
  greeting: 'Bonjour',
  objectives: [
    ActionPlanObjective(id: 'objective-1', title: 'Trouver un emploi', theme: 'emploi', actions: [action]),
  ],
);

AuthIdToken _miloIdToken() => AuthIdToken(
  userId: 'id-jeune',
  firstName: 'F',
  lastName: 'L',
  email: 'first.last@mail.fr',
  issuedAt: 90000000,
  expiresAt: 100000000,
  structure: 'MILO',
);

Matcher _shouldLoad() => StateIs<RepriseCompteInviteLoadingState>((state) => state.repriseCompteInviteState);

Matcher _shouldBeReset() => StateIs<RepriseCompteInviteNotInitializedState>((state) => state.repriseCompteInviteState);

Matcher _shouldFailBecauseOfWrongClock() {
  return StateIs<RepriseCompteInviteWrongDeviceClockState>((state) => state.repriseCompteInviteState);
}

Matcher _shouldFailWithMessage(String message) {
  return StateIs<RepriseCompteInviteFailureState>(
    (state) => state.repriseCompteInviteState,
    (state) => expect(state.message, message),
  );
}

Matcher _shouldFailWhileStayingGuest() {
  return StateMatch(
    (state) => state.repriseCompteInviteState is RepriseCompteInviteFailureState,
    (state) => expect(state.isInviteLoginMode(), isTrue),
  );
}

Matcher _shouldBeLoggedInAsMiloUser() {
  return StateIs<LoginSuccessState>(
    (state) => state.loginState,
    (state) {
      expect(state.user.id, 'id-jeune');
      expect(state.user.loginMode, LoginMode.MILO);
    },
  );
}

Matcher _shouldBeResetWhileStayingGuest() {
  return StateMatch(
    (state) => state.repriseCompteInviteState is RepriseCompteInviteNotInitializedState,
    (state) => expect(state.isInviteLoginMode(), isTrue),
  );
}
