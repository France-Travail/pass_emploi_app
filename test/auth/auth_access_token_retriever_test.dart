import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/auth/auth_access_token_retriever.dart';
import 'package:pass_emploi_app/auth/auth_id_token.dart';
import 'package:pass_emploi_app/auth/authenticator.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/models/login_mode.dart';

import '../doubles/mocks.dart';
import '../doubles/spies.dart';
import '../dsl/app_state_dsl.dart';

void main() {
  late MockAuthenticator authenticator;
  late MockRemoteConfigRepository remoteConfig;
  late FlutterSecureStorageSpy storage;
  late AuthAccessTokenRetriever tokenRetriever;

  setUp(() {
    authenticator = MockAuthenticator();
    remoteConfig = MockRemoteConfigRepository();
    storage = FlutterSecureStorageSpy(delay: Duration.zero);
    tokenRetriever = AuthAccessTokenRetriever(authenticator, remoteConfig, storage);
  });

  test("Throws an exception when id token is null", () async {
    // Given
    when(() => authenticator.idToken()).thenAnswer((_) async => null);
    // When-Then
    expect(() async => await tokenRetriever.accessToken(), throwsException);
  });

  test("Returns access token when id token is valid", () async {
    // Given
    when(() => authenticator.accessToken()).thenAnswer((_) async => "Access token");
    when(() => authenticator.idToken()).thenAnswer((_) async => validIdToken());
    // When-Then
    expect(await tokenRetriever.accessToken(), "Access token");
  });

  test("Returns access token when id token is invalid but refresh token is SUCCESSFUL", () async {
    // Given
    when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
    when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.SUCCESSFUL);
    when(() => authenticator.accessToken()).thenAnswer((_) async => "Access token");

    // When-Then
    expect(await tokenRetriever.accessToken(), "Access token");
  });

  test("Throws WITHOUT logout on a SINGLE GENERIC_ERROR (hoquet transitoire toléré)", () async {
    // Given : un seul échec ambigu (5xx, réponse incomplète) -> pas de déco
    final store = StoreSpy();
    when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
    when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.GENERIC_ERROR);
    when(() => remoteConfig.maxRefreshFailuresBeforeLogout()).thenReturn(3);
    tokenRetriever.setStore(store);

    // When-Then
    expect(() async => await tokenRetriever.accessToken(), throwsException);
    expect(store.dispatchedAction, isNot(isA<RequestLogoutAction>()));
  });

  test("Logout après N GENERIC_ERROR consécutifs", () async {
    // Given
    final store = StoreSpy();
    when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
    when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.GENERIC_ERROR);
    when(() => remoteConfig.maxRefreshFailuresBeforeLogout()).thenReturn(2);
    tokenRetriever.setStore(store);

    // When : 1er échec -> compteur=1, pas de logout
    try {
      await tokenRetriever.accessToken();
    } catch (_) {}
    expect(store.dispatchedAction, isNot(isA<RequestLogoutAction>()));

    // 2e échec -> compteur=2 -> logout
    try {
      await tokenRetriever.accessToken();
    } catch (_) {}
    expect(store.dispatchedAction, isA<RequestLogoutAction>());
  });

  test("Le compteur SURVIT au kill de l'app (persistance via storage)", () async {
    // Given
    final store = StoreSpy();
    when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
    when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.GENERIC_ERROR);
    when(() => remoteConfig.maxRefreshFailuresBeforeLogout()).thenReturn(2);

    // Session 1 : 1 échec -> compteur=1 (persisté), pas de logout
    final retriever1 = AuthAccessTokenRetriever(authenticator, remoteConfig, storage)..setStore(store);
    try {
      await retriever1.accessToken();
    } catch (_) {}
    expect(store.dispatchedAction, isNot(isA<RequestLogoutAction>()));

    // Kill + relance : NOUVELLE instance, MÊME storage -> le compteur reprend à 1
    final retriever2 = AuthAccessTokenRetriever(authenticator, remoteConfig, storage)..setStore(store);
    try {
      await retriever2.accessToken();
    } catch (_) {}

    // Then : 2e échec global -> compteur=2 -> logout (le kill n'a PAS remis à zéro)
    expect(store.dispatchedAction, isA<RequestLogoutAction>());
  });

  test("Un refresh réussi remet le compteur à zéro", () async {
    // Given
    final store = StoreSpy();
    when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
    when(() => authenticator.accessToken()).thenAnswer((_) async => "Access token");
    when(() => remoteConfig.maxRefreshFailuresBeforeLogout()).thenReturn(2);
    tokenRetriever.setStore(store);

    // When : GENERIC (1), puis SUCCESS (reset), puis GENERIC (1) -> jamais 2 d'affilée
    when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.GENERIC_ERROR);
    try {
      await tokenRetriever.accessToken();
    } catch (_) {}
    when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.SUCCESSFUL);
    await tokenRetriever.accessToken();
    when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.GENERIC_ERROR);
    try {
      await tokenRetriever.accessToken();
    } catch (_) {}

    // Then : le succès a remis le compteur à zéro -> pas de logout
    expect(store.dispatchedAction, isNot(isA<RequestLogoutAction>()));
  });

  test("Logout user and throw when id token is invalid and refresh token returns USER_NOT_LOGGED_IN", () async {
    // Given
    final store = StoreSpy();
    when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
    when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.USER_NOT_LOGGED_IN);
    tokenRetriever.setStore(store);

    // When
    Object? thrown;
    try {
      await tokenRetriever.accessToken();
    } catch (e) {
      thrown = e;
    }

    // Then
    expect(thrown, isException);
    expect(store.dispatchedAction, isA<RequestLogoutAction>());
  });

  test("Throws WITHOUT logout when id token is invalid and refresh token returns NETWORK_UNREACHABLE", () async {
    // Given : hors-ligne transitoire, on garde la session
    final store = StoreSpy();
    when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
    when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.NETWORK_UNREACHABLE);
    tokenRetriever.setStore(store);

    // When-Then
    expect(() async => await tokenRetriever.accessToken(), throwsException);
    expect(store.dispatchedAction, isNot(isA<RequestLogoutAction>()));
  });

  test("Throws an exception when id token is invalid and refresh token returns EXPIRED_REFRESH_TOKEN", () async {
    // Given
    final store = StoreSpy();
    when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
    when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.EXPIRED_REFRESH_TOKEN);
    tokenRetriever.setStore(store);

    // When-Then
    expect(() async => await tokenRetriever.accessToken(), throwsException);
  });

  test("Logout user when id token is invalid and refresh token returns EXPIRED_REFRESH_TOKEN", () async {
    // Given
    final store = StoreSpy();
    when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
    when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.EXPIRED_REFRESH_TOKEN);
    tokenRetriever.setStore(store);

    // When
    try {
      await tokenRetriever.accessToken();
    } catch (_) {}

    // Then
    expect(store.dispatchedAction, isA<RequestLogoutAction>());
  });

  test("Un invité n'est pas déconnecté après N GENERIC_ERROR consécutifs", () async {
    // Given
    final store = StoreSpy.withState(givenState().loggedInUser(loginMode: LoginMode.INVITE));
    when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
    when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.GENERIC_ERROR);
    when(() => remoteConfig.maxRefreshFailuresBeforeLogout()).thenReturn(2);
    tokenRetriever.setStore(store);

    // When
    for (var i = 0; i < 3; i++) {
      try {
        await tokenRetriever.accessToken();
      } catch (_) {}
    }

    // Then : les échecs restent suivis, mais sans déconnexion
    expect(store.dispatchedActions.whereType<TokenRefreshGenericErrorAction>(), hasLength(3));
    expect(store.dispatchedActions.whereType<RequestLogoutAction>(), isEmpty);
  });

  group("Refresh refusé temporairement par connect (rate limit)", () {
    late DateTime now;
    late StoreSpy store;

    Future<void> withFakeClock(Future<void> Function() body) => withClock(Clock(() => now), body);

    Future<Object?> accessTokenError() async {
      try {
        await tokenRetriever.accessToken();
        return null;
      } catch (e) {
        return e;
      }
    }

    setUp(() {
      now = DateTime(2026, 11, 20, 10);
      store = StoreSpy();
      tokenRetriever.setStore(store);
      when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
      when(() => authenticator.accessToken()).thenAnswer((_) async => "Access token");
      when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.TEMPORARILY_REFUSED);
    });

    test("lève une TokenRefreshTemporarilyRefusedException sans déconnecter", () async {
      await withFakeClock(() async {
        // When
        final error = await accessTokenError();

        // Then
        expect(error, isA<TokenRefreshTemporarilyRefusedException>());
        expect(store.dispatchedActions.whereType<TokenRefreshTemporarilyRefusedAction>(), hasLength(1));
        expect(store.dispatchedActions.whereType<RequestLogoutAction>(), isEmpty);
        expect(store.dispatchedActions.whereType<TokenRefreshGenericErrorAction>(), isEmpty);
      });
    });

    test("ne retente pas de refresh pendant la pause", () async {
      await withFakeClock(() async {
        // Given
        await accessTokenError();

        // When
        now = now.add(Duration(seconds: 59));
        final error = await accessTokenError();

        // Then
        expect(error, isA<TokenRefreshTemporarilyRefusedException>());
        verify(() => authenticator.refreshStoredSession()).called(1);
      });
    });

    test("retente le refresh une fois la pause terminée", () async {
      await withFakeClock(() async {
        // Given
        final error = await accessTokenError() as TokenRefreshTemporarilyRefusedException;
        when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.SUCCESSFUL);

        // When
        now = error.retryNotBefore;
        final accessToken = await tokenRetriever.accessToken();

        // Then
        expect(accessToken, "Access token");
        verify(() => authenticator.refreshStoredSession()).called(2);
      });
    });

    for (final loginMode in [LoginMode.MILO, LoginMode.INVITE]) {
      test("refusé pendant toute la fenêtre de limite : ${loginMode.name} n'est pas déconnecté", () async {
        await withFakeClock(() async {
          // Given
          store = StoreSpy.withState(givenState().loggedInUser(loginMode: loginMode));
          tokenRetriever.setStore(store);
          when(() => remoteConfig.maxRefreshFailuresBeforeLogout()).thenReturn(2);

          // When : des requêtes toutes les 10 s pendant 30 min, toutes refusées
          final end = now.add(Duration(minutes: 30));
          while (now.isBefore(end)) {
            await accessTokenError();
            now = now.add(Duration(seconds: 10));
          }

          // Then
          expect(store.dispatchedActions.whereType<RequestLogoutAction>(), isEmpty);
          // pauses de 1, 2, 4 puis 5 min (+ délai aléatoire) : quelques tentatives seulement
          final attempts = verify(() => authenticator.refreshStoredSession()).callCount;
          expect(attempts, inInclusiveRange(5, 9));
        });
      });
    }

    test("un refresh réussi termine la pause", () async {
      await withFakeClock(() async {
        // Given : une 1re pause, puis un succès
        final firstRefusal = await accessTokenError() as TokenRefreshTemporarilyRefusedException;
        now = firstRefusal.retryNotBefore;
        when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.SUCCESSFUL);
        await tokenRetriever.accessToken();

        // When : nouveau refus
        when(() => authenticator.refreshStoredSession()).thenAnswer((_) async => RefreshTokenStatus.TEMPORARILY_REFUSED);
        final secondRefusal = await accessTokenError() as TokenRefreshTemporarilyRefusedException;

        // Then : la pause repart de la durée initiale (60 s + au plus 25 %)
        expect(secondRefusal.retryNotBefore.difference(now), lessThanOrEqualTo(Duration(seconds: 75)));
      });
    });
  });

  group("Appels en parallèle", () {
    setUp(() {
      when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
      when(() => authenticator.accessToken()).thenAnswer((_) async => "Access token");
      tokenRetriever.setStore(StoreSpy());
    });

    void givenRefreshReturns(RefreshTokenStatus status) {
      when(() => authenticator.refreshStoredSession()).thenAnswer((_) async {
        await Future<void>.delayed(Duration(milliseconds: 10));
        return status;
      });
    }

    Future<List<Object?>> fiveParallelCalls() {
      return Future.wait(
        List.generate(5, (_) => tokenRetriever.accessToken().then<Object?>((token) => token, onError: (Object e) => e)),
      );
    }

    test("partagent un seul refresh réussi", () async {
      // Given
      givenRefreshReturns(RefreshTokenStatus.SUCCESSFUL);

      // When
      final results = await fiveParallelCalls();

      // Then
      expect(results, everyElement("Access token"));
      verify(() => authenticator.refreshStoredSession()).called(1);
    });

    test("partagent un seul refresh refusé temporairement", () async {
      // Given
      givenRefreshReturns(RefreshTokenStatus.TEMPORARILY_REFUSED);

      // When
      final results = await fiveParallelCalls();

      // Then
      expect(results, everyElement(isA<TokenRefreshTemporarilyRefusedException>()));
      verify(() => authenticator.refreshStoredSession()).called(1);
    });

    test("ne comptent qu'un échec quand le refresh échoue en GENERIC_ERROR", () async {
      // Given
      final store = StoreSpy();
      tokenRetriever.setStore(store);
      givenRefreshReturns(RefreshTokenStatus.GENERIC_ERROR);

      // When
      await fiveParallelCalls();

      // Then
      verify(() => authenticator.refreshStoredSession()).called(1);
      expect(store.dispatchedActions.whereType<TokenRefreshGenericErrorAction>().single.consecutiveFailures, 1);
    });
  });
}

AuthIdToken validIdToken() => AuthIdToken(
      userId: "id",
      firstName: "F",
      lastName: "L",
      email: "email",
      issuedAt: (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      expiresAt: (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 1000,
      structure: 'MILO',
    );

AuthIdToken invalidIdToken() => AuthIdToken(
      userId: "id",
      firstName: "F",
      lastName: "L",
      email: "email@email.com",
      issuedAt: 0,
      expiresAt: 0,
      structure: 'MILO',
    );
