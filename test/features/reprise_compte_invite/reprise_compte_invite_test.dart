import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/auth/auth_id_token.dart';
import 'package:pass_emploi_app/auth/authenticator.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_actions.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_state.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

void main() {
  group('RepriseCompteInvite', () {
    final sut = StoreSut();
    late MockAuthenticator authenticator;
    late MockRepriseCompteInviteRepository repository;

    setUpAll(() {
      registerFallbackValue(LogoutReason.userLogout);
      registerFallbackValue(AuthenticationMode.SIMILO);
    });

    setUp(() {
      authenticator = MockAuthenticator();
      repository = MockRepriseCompteInviteRepository();
      when(() => authenticator.refreshToken()).thenAnswer((_) async => 'refresh-token-invite');
      when(
        () => authenticator.accessTokenFromRefreshToken('refresh-token-invite'),
      ).thenAnswer((_) async => 'jeton-invite');
    });

    void givenInviteStore({MockActionPlanRepository? actionPlanRepository}) {
      sut.givenStore =
          givenState() //
              .loggedInUser(loginMode: LoginMode.INVITE)
              .store((f) {
                f.authenticator = authenticator;
                f.repriseCompteInviteRepository = repository;
                if (actionPlanRepository != null) {
                  f.actionPlanRepository = actionPlanRepository;
                }
              });
    }

    group('when requesting with MILO', () {
      sut.whenDispatchingAction(() => RepriseCompteInviteRequestAction(LoginMode.MILO));

      test(
        'should log in the MILO account then attach the guest account to it with a guest token obtained after login',
        () async {
          // Given
          when(
            () => authenticator.login(AuthenticationMode.SIMILO),
          ).thenAnswer((_) async => SuccessAuthenticatorResponse());
          when(() => authenticator.idToken()).thenAnswer((_) async => _miloIdToken());
          when(() => authenticator.isLoggedIn()).thenAnswer((_) async => true);
          when(
            () => repository.reprendre(
              userId: any(named: 'userId'),
              jetonInvite: any(named: 'jetonInvite'),
              plan: any(named: 'plan'),
            ),
          ).thenAnswer((_) async => true);
          givenInviteStore();

          // Then
          await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeLoggedInAsMiloUser()]);
          await untilCalled(() => repository.reprendre(
                userId: any(named: 'userId'),
                jetonInvite: any(named: 'jetonInvite'),
                plan: any(named: 'plan'),
              ));
          await pumpEventQueue();
          verify(() => repository.reprendre(
                userId: 'id-jeune',
                jetonInvite: 'jeton-invite',
                plan: any(named: 'plan'),
              )).called(1);
          verifyInOrder([
            () => authenticator.refreshToken(),
            () => authenticator.login(AuthenticationMode.SIMILO),
            () => authenticator.accessTokenFromRefreshToken('refresh-token-invite'),
          ]);
          verifyNever(() => authenticator.logout(any(), any()));
        },
      );

      test('should still log in the MILO account when attaching the guest account fails', () async {
        // Given
        when(
          () => authenticator.login(AuthenticationMode.SIMILO),
        ).thenAnswer((_) async => SuccessAuthenticatorResponse());
        when(() => authenticator.idToken()).thenAnswer((_) async => _miloIdToken());
        when(() => authenticator.isLoggedIn()).thenAnswer((_) async => true);
        when(
          () => repository.reprendre(
            userId: any(named: 'userId'),
            jetonInvite: any(named: 'jetonInvite'),
            plan: any(named: 'plan'),
          ),
        ).thenAnswer((_) async => false);
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeLoggedInAsMiloUser()]);
      });

      test('should still log in the MILO account without attaching when no guest token can be obtained', () async {
        // Given
        when(
          () => authenticator.login(AuthenticationMode.SIMILO),
        ).thenAnswer((_) async => SuccessAuthenticatorResponse());
        when(() => authenticator.idToken()).thenAnswer((_) async => _miloIdToken());
        when(() => authenticator.isLoggedIn()).thenAnswer((_) async => true);
        when(() => authenticator.accessTokenFromRefreshToken(any())).thenAnswer((_) async => null);
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeLoggedInAsMiloUser()]);
        verifyNever(
          () => repository.reprendre(
            userId: any(named: 'userId'),
            jetonInvite: any(named: 'jetonInvite'),
            plan: any(named: 'plan'),
          ),
        );
      });

      test('should stay logged in as guest without attaching when login is cancelled', () async {
        // Given
        when(
          () => authenticator.login(AuthenticationMode.SIMILO),
        ).thenAnswer((_) async => CancelledAuthenticatorResponse());
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeResetWhileStayingGuest()]);
        await pumpEventQueue();
        verifyNever(() => authenticator.accessTokenFromRefreshToken(any()));
        verifyNever(
          () => repository.reprendre(
            userId: any(named: 'userId'),
            jetonInvite: any(named: 'jetonInvite'),
            plan: any(named: 'plan'),
          ),
        );
      });

      test('should fail with message when login fails', () async {
        // Given
        when(
          () => authenticator.login(AuthenticationMode.SIMILO),
        ).thenAnswer((_) async => FailureAuthenticatorResponse('error-message'));
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldFailWithMessage('error-message')]);
        await pumpEventQueue();
        verifyNever(
          () => repository.reprendre(
            userId: any(named: 'userId'),
            jetonInvite: any(named: 'jetonInvite'),
            plan: any(named: 'plan'),
          ),
        );
      });

      test('should fail because of wrong clock when device clock is wrong', () async {
        // Given
        when(
          () => authenticator.login(AuthenticationMode.SIMILO),
        ).thenAnswer((_) async => WrongDeviceClockAuthenticatorResponse());
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
          () => authenticator.login(AuthenticationMode.POLE_EMPLOI),
        ).thenAnswer((_) async => CancelledAuthenticatorResponse());
        givenInviteStore();

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeReset()]);
        await untilCalled(() => authenticator.login(AuthenticationMode.POLE_EMPLOI));
        verify(() => authenticator.login(AuthenticationMode.POLE_EMPLOI)).called(1);
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

      test('should send the local plan to the API when all actions have idSolution', () async {
        // Given
        final actionPlanRepository = MockActionPlanRepository();
        final localPlan = ActionPlan(
          id: 'plan-1',
          greeting: 'Bonjour',
          objectives: [
            ActionPlanObjective(
              id: 'objective-1',
              title: 'Trouver un emploi',
              theme: 'emploi',
              actions: [
                const ActionPlanAction(
                  id: 'action-1',
                  label: 'Faire un CV',
                  kind: ActionPlanActionKind.advice,
                  done: true,
                  idSolution: 'solution-123',
                ),
              ],
            ),
          ],
        );
        when(() => actionPlanRepository.getStoredPlan()).thenAnswer((_) async => localPlan);
        when(
          () => authenticator.login(AuthenticationMode.SIMILO),
        ).thenAnswer((_) async => SuccessAuthenticatorResponse());
        when(() => authenticator.idToken()).thenAnswer((_) async => _miloIdToken());
        when(() => authenticator.isLoggedIn()).thenAnswer((_) async => true);
        when(
          () => repository.reprendre(
            userId: any(named: 'userId'),
            jetonInvite: any(named: 'jetonInvite'),
            plan: any(named: 'plan'),
          ),
        ).thenAnswer((_) async => true);
        givenInviteStore(actionPlanRepository: actionPlanRepository);

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeLoggedInAsMiloUser()]);
        await untilCalled(() => repository.reprendre(
              userId: any(named: 'userId'),
              jetonInvite: any(named: 'jetonInvite'),
              plan: any(named: 'plan'),
            ));
        await pumpEventQueue();
        final captured = verify(
          () => repository.reprendre(
            userId: 'id-jeune',
            jetonInvite: 'jeton-invite',
            plan: captureAny(named: 'plan'),
          ),
        ).captured.single as Map<String, dynamic>;
        expect(captured['id'], 'plan-1');
        expect(captured['objectives'], hasLength(1));
        expect(captured['objectives'][0]['id'], 'objective-1');
        expect(captured['objectives'][0]['actions'][0]['idSolution'], 'solution-123');
      });

      test('should not send the plan when an action is missing idSolution', () async {
        // Given
        final actionPlanRepository = MockActionPlanRepository();
        final localPlan = ActionPlan(
          id: 'plan-1',
          greeting: 'Bonjour',
          objectives: [
            ActionPlanObjective(
              id: 'objective-1',
              title: 'Trouver un emploi',
              theme: 'emploi',
              actions: [
                const ActionPlanAction(
                  id: 'action-1',
                  label: 'Faire un CV',
                  kind: ActionPlanActionKind.advice,
                  done: true,
                ),
              ],
            ),
          ],
        );
        when(() => actionPlanRepository.getStoredPlan()).thenAnswer((_) async => localPlan);
        when(
          () => authenticator.login(AuthenticationMode.SIMILO),
        ).thenAnswer((_) async => SuccessAuthenticatorResponse());
        when(() => authenticator.idToken()).thenAnswer((_) async => _miloIdToken());
        when(() => authenticator.isLoggedIn()).thenAnswer((_) async => true);
        when(
          () => repository.reprendre(
            userId: any(named: 'userId'),
            jetonInvite: any(named: 'jetonInvite'),
            plan: any(named: 'plan'),
          ),
        ).thenAnswer((_) async => true);
        givenInviteStore(actionPlanRepository: actionPlanRepository);

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeLoggedInAsMiloUser()]);
        await pumpEventQueue();
        verify(() => repository.reprendre(
              userId: 'id-jeune',
              jetonInvite: 'jeton-invite',
              plan: null,
            )).called(1);
      });

      test('should not send the plan when there is no local plan', () async {
        // Given
        final actionPlanRepository = MockActionPlanRepository();
        when(() => actionPlanRepository.getStoredPlan()).thenAnswer((_) async => null);
        when(
          () => authenticator.login(AuthenticationMode.SIMILO),
        ).thenAnswer((_) async => SuccessAuthenticatorResponse());
        when(() => authenticator.idToken()).thenAnswer((_) async => _miloIdToken());
        when(() => authenticator.isLoggedIn()).thenAnswer((_) async => true);
        when(
          () => repository.reprendre(
            userId: any(named: 'userId'),
            jetonInvite: any(named: 'jetonInvite'),
            plan: any(named: 'plan'),
          ),
        ).thenAnswer((_) async => true);
        givenInviteStore(actionPlanRepository: actionPlanRepository);

        // Then
        await sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldBeLoggedInAsMiloUser()]);
        await pumpEventQueue();
        verify(() => repository.reprendre(
              userId: 'id-jeune',
              jetonInvite: 'jeton-invite',
              plan: null,
            )).called(1);
      });
    });
  });
}

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
