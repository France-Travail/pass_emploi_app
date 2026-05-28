import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/auth/auth_refresh_token_request.dart';
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
