import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/auth/auth_refresh_token_request.dart';
import 'package:pass_emploi_app/auth/auth_token_request.dart';
import 'package:pass_emploi_app/auth/auth_wrapper.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:synchronized/synchronized.dart';

class _MockFlutterAppAuth extends Mock implements FlutterAppAuth {}

void main() {
  late _MockFlutterAppAuth appAuth;
  late AuthWrapper authWrapper;

  setUp(() {
    appAuth = _MockFlutterAppAuth();
    authWrapper = AuthWrapper(appAuth, Lock());
    registerFallbackValue(TokenRequest('clientId', 'redirectUrl', issuer: 'https://example.com'));
    registerFallbackValue(AuthorizationTokenRequest('clientId', 'redirectUrl', issuer: 'https://example.com'));
  });

  group('login — isDeviceClockWrong detection', () {
    test('throws AuthWrapperWrongDeviceClockException on iOS iat validation error ("600 seconds", code -15)', () {
      when(() => appAuth.authorizeAndExchangeCode(any())).thenThrow(
        PlatformException(
          code: 'authorize_and_exchange_code_failed',
          message: 'Failed to authorize: Issued at time is more than 600 seconds before or after the current time',
          details: {
            'code': -15,
            'user_did_cancel': false,
            'type': 'org.openid.appauth.general',
            'error_debug_description':
                'Error Domain=org.openid.appauth.general Code=-15 "Issued at time is more than 600 seconds before or after the current time"',
          },
        ),
      );
      expect(
        () => authWrapper.login(_loginRequest()),
        throwsA(isA<AuthWrapperWrongDeviceClockException>()),
      );
    });

    test('throws AuthWrapperWrongDeviceClockException on Android iat validation error ("10 minutes")', () {
      when(() => appAuth.authorizeAndExchangeCode(any())).thenThrow(
        PlatformException(
          code: 'authorize_and_exchange_code_failed',
          message: 'Failed to authorize',
          details: 'Issued at time is more than 10 minutes before or after the current time',
        ),
      );
      expect(
        () => authWrapper.login(_loginRequest()),
        throwsA(isA<AuthWrapperWrongDeviceClockException>()),
      );
    });

    test('throws UserCanceledLoginException when user cancels flow (not misdetected as wrong clock)', () {
      when(() => appAuth.authorizeAndExchangeCode(any())).thenThrow(
        PlatformException(
          code: 'authorize_and_exchange_code_failed',
          message: 'Failed to authorize: User cancelled flow',
          details: {'user_did_cancel': true},
        ),
      );
      expect(
        () => authWrapper.login(_loginRequest()),
        throwsA(isA<UserCanceledLoginException>()),
      );
    });

    test('throws AuthWrapperCalledCancelException on other code exchange failure (not misdetected as wrong clock)', () {
      when(() => appAuth.authorizeAndExchangeCode(any())).thenThrow(
        PlatformException(
          code: 'authorize_and_exchange_code_failed',
          message: 'Failed to authorize',
          details: {'code': -6, 'user_did_cancel': false},
        ),
      );
      expect(
        () => authWrapper.login(_loginRequest()),
        throwsA(isA<AuthWrapperCalledCancelException>()),
      );
    });
  });

  group('refreshToken — isRefreshTokenExpired detection', () {
    test('throws AuthWrapperRefreshTokenExpiredException on invalid_grant via FlutterAppAuthPlatformErrorDetails', () {
      when(() => appAuth.token(any())).thenThrow(
        PlatformException(
          code: 'token_failed',
          details: FlutterAppAuthPlatformErrorDetails(error: 'invalid_grant', errorDescription: 'Token is not active'),
        ),
      );
      expect(
        () => authWrapper.refreshToken(_refreshTokenRequest()),
        throwsA(isA<AuthWrapperRefreshTokenExpiredException>()),
      );
    });

    test('throws AuthWrapperRefreshTokenExpiredException on invalid_grant via Map — cas iOS', () {
      when(() => appAuth.token(any())).thenThrow(
        PlatformException(
          code: 'token_failed',
          details: {'error': 'invalid_grant', 'error_description': 'Token is not active'},
        ),
      );
      expect(
        () => authWrapper.refreshToken(_refreshTokenRequest()),
        throwsA(isA<AuthWrapperRefreshTokenExpiredException>()),
      );
    });

    test('throws AuthWrapperRefreshTokenException (not expired) on token_failed with other error', () {
      when(() => appAuth.token(any())).thenThrow(
        PlatformException(
          code: 'token_failed',
          details: {'error': 'access_denied'},
        ),
      );
      expect(
        () => authWrapper.refreshToken(_refreshTokenRequest()),
        throwsA(isA<AuthWrapperRefreshTokenException>()),
      );
    });

    test('throws AuthWrapperRefreshTokenException (not expired) on token_failed with no details', () {
      when(() => appAuth.token(any())).thenThrow(
        PlatformException(code: 'token_failed'),
      );
      expect(
        () => authWrapper.refreshToken(_refreshTokenRequest()),
        throwsA(isA<AuthWrapperRefreshTokenException>()),
      );
    });
  });

  group('refreshToken — refus temporaire et réseau', () {
    late _MockCrashlytics crashlytics;

    setUp(() {
      registerFallbackValue(StackTrace.empty);
      crashlytics = _MockCrashlytics();
      authWrapper = AuthWrapper(appAuth, Lock(), crashlytics);
    });

    // Payloads observés dans les sources d'AppAuth : connect répond au rate limit par
    // 429 {"statusCode":429,"message":"Trop de requêtes, réessayez dans quelques instants."}
    test('429 sur iOS : refus temporaire, non remonté dans Crashlytics', () async {
      when(() => appAuth.token(any())).thenThrow(
        _appAuthException(
          type: 'org.openid.appauth.general',
          code: '-6',
          domain: 'org.openid.appauth.remote-http',
          errorDebugDescription: "Non-200 HTTP response (429) making token request to 'https://connect/token'.",
        ),
      );
      await expectLater(
        authWrapper.refreshToken(_refreshTokenRequest()),
        throwsA(isA<AuthWrapperRefreshTemporarilyRefusedException>()),
      );
      verifyNever(() => crashlytics.recordNonNetworkException(any(), any()));
    });

    test('429 sur Android (statut HTTP perdu, corps sans token_type) : refus temporaire', () {
      when(() => appAuth.token(any())).thenThrow(
        _appAuthException(
          type: '0',
          code: '5',
          rootCauseDebugDescription: 'org.json.JSONException: field "token_type" not found in json object',
          legacyDetails: 'field "token_type" not found in json object',
        ),
      );
      expect(
        () => authWrapper.refreshToken(_refreshTokenRequest()),
        throwsA(isA<AuthWrapperRefreshTemporarilyRefusedException>()),
      );
    });

    test('erreur OAuth autre que invalid_grant : erreur générique, pas un refus temporaire', () {
      when(() => appAuth.token(any())).thenThrow(
        _appAuthException(type: '2', code: '2', error: 'invalid_client'),
      );
      expect(
        () => authWrapper.refreshToken(_refreshTokenRequest()),
        throwsA(isA<Object>().having((e) => e.runtimeType, 'runtimeType', AuthWrapperRefreshTokenException)),
      );
    });

    test('invalid_grant via platformErrorDetails : refresh token expiré', () {
      when(() => appAuth.token(any())).thenThrow(
        _appAuthException(type: '2', code: '2', error: 'invalid_grant', legacyDetails: 'Token is not active'),
      );
      expect(
        () => authWrapper.refreshToken(_refreshTokenRequest()),
        throwsA(isA<AuthWrapperRefreshTokenExpiredException>()),
      );
    });

    test('coupure réseau pendant l\'appel au token endpoint sur iOS : erreur réseau', () {
      when(() => appAuth.token(any())).thenThrow(
        _appAuthException(type: 'org.openid.appauth.general', code: '-5'),
      );
      expect(
        () => authWrapper.refreshToken(_refreshTokenRequest()),
        throwsA(isA<AuthWrapperNetworkException>()),
      );
    });

    test('coupure réseau pendant l\'appel au token endpoint sur Android : erreur réseau', () {
      when(() => appAuth.token(any())).thenThrow(
        _appAuthException(type: '0', code: '3', legacyDetails: 'timeout'),
      );
      expect(
        () => authWrapper.refreshToken(_refreshTokenRequest()),
        throwsA(isA<AuthWrapperNetworkException>()),
      );
    });
  });
}

class _MockCrashlytics extends Mock implements Crashlytics {}

FlutterAppAuthPlatformException _appAuthException({
  required String type,
  required String code,
  String? error,
  String? domain,
  String? rootCauseDebugDescription,
  String? errorDebugDescription,
  dynamic legacyDetails,
}) {
  return FlutterAppAuthPlatformException(
    code: 'token_failed',
    legacyDetails: legacyDetails,
    platformErrorDetails: FlutterAppAuthPlatformErrorDetails(
      type: type,
      code: code,
      error: error,
      domain: domain,
      rootCauseDebugDescription: rootCauseDebugDescription,
      errorDebugDescription: errorDebugDescription,
    ),
  );
}

AuthRefreshTokenRequest _refreshTokenRequest() {
  return AuthRefreshTokenRequest('clientId', 'fr.fabrique.social.gouv.passemploi://login-callback', 'issuer', 'refreshToken', 'secret');
}

AuthTokenRequest _loginRequest() {
  return AuthTokenRequest(
    'clientId',
    'fr.fabrique.social.gouv.passemploi://login-callback',
    'issuer',
    ['openid', 'email', 'profile', 'offline_access'],
    'secret',
    null,
  );
}
