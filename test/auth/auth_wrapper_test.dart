import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/auth/auth_refresh_token_request.dart';
import 'package:pass_emploi_app/auth/auth_token_request.dart';
import 'package:pass_emploi_app/auth/auth_wrapper.dart';
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
