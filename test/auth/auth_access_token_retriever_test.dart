import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/auth/auth_access_token_retriever.dart';
import 'package:pass_emploi_app/auth/auth_id_token.dart';
import 'package:pass_emploi_app/auth/authenticator.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:synchronized/synchronized.dart';

import '../doubles/mocks.dart';
import '../doubles/spies.dart';

void main() {
  late MockAuthenticator authenticator;
  late MockRemoteConfigRepository remoteConfig;
  late FlutterSecureStorageSpy storage;
  late AuthAccessTokenRetriever tokenRetriever;

  setUp(() {
    authenticator = MockAuthenticator();
    remoteConfig = MockRemoteConfigRepository();
    storage = FlutterSecureStorageSpy(delay: Duration.zero);
    tokenRetriever = AuthAccessTokenRetriever(authenticator, remoteConfig, storage, Lock());
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
    when(() => authenticator.performRefreshToken()).thenAnswer((_) async => RefreshTokenStatus.SUCCESSFUL);
    when(() => authenticator.accessToken()).thenAnswer((_) async => "Access token");

    // When-Then
    expect(await tokenRetriever.accessToken(), "Access token");
  });

  test("Throws WITHOUT logout on a SINGLE GENERIC_ERROR (hoquet transitoire toléré)", () async {
    // Given : un seul échec ambigu (5xx, réponse incomplète) -> pas de déco
    final store = StoreSpy();
    when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
    when(() => authenticator.performRefreshToken()).thenAnswer((_) async => RefreshTokenStatus.GENERIC_ERROR);
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
    when(() => authenticator.performRefreshToken()).thenAnswer((_) async => RefreshTokenStatus.GENERIC_ERROR);
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
    when(() => authenticator.performRefreshToken()).thenAnswer((_) async => RefreshTokenStatus.GENERIC_ERROR);
    when(() => remoteConfig.maxRefreshFailuresBeforeLogout()).thenReturn(2);

    // Session 1 : 1 échec -> compteur=1 (persisté), pas de logout
    final retriever1 = AuthAccessTokenRetriever(authenticator, remoteConfig, storage, Lock())..setStore(store);
    try {
      await retriever1.accessToken();
    } catch (_) {}
    expect(store.dispatchedAction, isNot(isA<RequestLogoutAction>()));

    // Kill + relance : NOUVELLE instance, MÊME storage -> le compteur reprend à 1
    final retriever2 = AuthAccessTokenRetriever(authenticator, remoteConfig, storage, Lock())..setStore(store);
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
    when(() => authenticator.performRefreshToken()).thenAnswer((_) async => RefreshTokenStatus.GENERIC_ERROR);
    try {
      await tokenRetriever.accessToken();
    } catch (_) {}
    when(() => authenticator.performRefreshToken()).thenAnswer((_) async => RefreshTokenStatus.SUCCESSFUL);
    await tokenRetriever.accessToken();
    when(() => authenticator.performRefreshToken()).thenAnswer((_) async => RefreshTokenStatus.GENERIC_ERROR);
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
    when(() => authenticator.performRefreshToken()).thenAnswer((_) async => RefreshTokenStatus.USER_NOT_LOGGED_IN);
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
    when(() => authenticator.performRefreshToken()).thenAnswer((_) async => RefreshTokenStatus.NETWORK_UNREACHABLE);
    tokenRetriever.setStore(store);

    // When-Then
    expect(() async => await tokenRetriever.accessToken(), throwsException);
    expect(store.dispatchedAction, isNot(isA<RequestLogoutAction>()));
  });

  test("Throws an exception when id token is invalid and refresh token returns EXPIRED_REFRESH_TOKEN", () async {
    // Given
    final store = StoreSpy();
    when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
    when(() => authenticator.performRefreshToken()).thenAnswer((_) async => RefreshTokenStatus.EXPIRED_REFRESH_TOKEN);
    tokenRetriever.setStore(store);

    // When-Then
    expect(() async => await tokenRetriever.accessToken(), throwsException);
  });

  test("Logout user when id token is invalid and refresh token returns EXPIRED_REFRESH_TOKEN", () async {
    // Given
    final store = StoreSpy();
    when(() => authenticator.idToken()).thenAnswer((_) async => invalidIdToken());
    when(() => authenticator.performRefreshToken()).thenAnswer((_) async => RefreshTokenStatus.EXPIRED_REFRESH_TOKEN);
    tokenRetriever.setStore(store);

    // When
    try {
      await tokenRetriever.accessToken();
    } catch (_) {}

    // Then
    expect(store.dispatchedAction, isA<RequestLogoutAction>());
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
