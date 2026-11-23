import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:pass_emploi_app/auth/auth_refresh_token_request.dart';
import 'package:pass_emploi_app/auth/auth_token_request.dart';
import 'package:pass_emploi_app/auth/auth_token_response.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:synchronized/synchronized.dart';

class AuthWrapper {
  final FlutterAppAuth _appAuth;
  final Lock _lock;
  final Crashlytics? _crashlytics;

  AuthWrapper(this._appAuth, this._lock, [this._crashlytics]);

  Future<AuthTokenResponse> login(AuthTokenRequest request) async {
    return _lock.synchronized(() async {
      return _login(request);
    });
  }

  Future<AuthTokenResponse> _login(AuthTokenRequest request) async {
    try {
      final response = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          request.clientId,
          request.loginRedirectUrl,
          issuer: request.issuer,
          scopes: request.scopes,
          clientSecret: request.clientSecret,
          additionalParameters: request.additionalParameters,
        ),
      );
      if (response.idToken != null && response.accessToken != null && response.refreshToken != null) {
        return AuthTokenResponse(
          idToken: response.idToken!,
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );
      } else {
        final message = "Incorrect Login output : response $response";
        _crashlytics?.recordNonNetworkException(message);
        throw AuthWrapperLoginException(message);
      }
    } on PlatformException catch (e, stack) {
      final message = e.toString();
      if (e.isNetworkException()) throw AuthWrapperNetworkException(message);
      if (e.isDeviceClockWrong()) throw AuthWrapperWrongDeviceClockException(message);
      if (e.isCodeExchangeFailing() && e.isUserCancellation()) throw UserCanceledLoginException(message);
      if (e.isCodeExchangeFailing() && e.isRefusedWithoutOAuthError()) {
        throw AuthWrapperLoginTemporarilyRefusedException(message);
      }
      _recordAppAuthException(e, stack);
      if (e.isCodeExchangeFailing()) throw AuthWrapperCalledCancelException(message);
      throw AuthWrapperLoginException(message);
    }
  }

  Future<AuthTokenResponse> refreshToken(AuthRefreshTokenRequest request) async {
    return _lock.synchronized(() async {
      return _refreshToken(request);
    });
  }

  Future<AuthTokenResponse> _refreshToken(AuthRefreshTokenRequest request) async {
    try {
      final response = await _appAuth.token(
        TokenRequest(
          request.clientId,
          request.loginRedirectUrl,
          issuer: request.issuer,
          clientSecret: request.clientSecret,
          refreshToken: request.refreshToken,
        ),
      );
      if (response.idToken != null && response.accessToken != null && response.refreshToken != null) {
        return AuthTokenResponse(
          idToken: response.idToken!,
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );
      } else {
        final message = "Incorrect Refresh token output : response $response";
        _crashlytics?.recordNonNetworkException(message);
        throw AuthWrapperRefreshTokenException(message);
      }
    } on PlatformException catch (e, stack) {
      final message = e.toString();
      if (e.isNetworkException() || e.isTokenRequestNetworkError()) throw AuthWrapperNetworkException(message);
      if (e.isRefusedWithoutOAuthError()) throw AuthWrapperRefreshTemporarilyRefusedException(message);
      _recordAppAuthException(e, stack);
      if (e.isRefreshTokenExpired()) throw AuthWrapperRefreshTokenExpiredException(message);
      throw AuthWrapperRefreshTokenException(message);
    }
  }

  void _recordAppAuthException(PlatformException e, StackTrace stack) {
    _crashlytics?.setCustomKey('appauth_error_code', e.code);
    _crashlytics?.setCustomKey('appauth_error_details', e.details.toString());
    _crashlytics?.recordNonNetworkException(e, stack);
  }
}

class AuthWrapperException implements Exception {
  final String? message;

  AuthWrapperException(this.message);

  @override
  String toString() => message ?? super.toString();
}

class AuthWrapperLoginException extends AuthWrapperException {
  AuthWrapperLoginException(super.message);
}

class AuthWrapperRefreshTokenException extends AuthWrapperException {
  AuthWrapperRefreshTokenException(super.message);
}

class AuthWrapperLogoutException extends AuthWrapperException {
  AuthWrapperLogoutException(super.message);
}

class AuthWrapperNetworkException extends AuthWrapperException {
  AuthWrapperNetworkException(super.message);
}

class AuthWrapperWrongDeviceClockException extends AuthWrapperLoginException {
  AuthWrapperWrongDeviceClockException(super.message);
}

class AuthWrapperCalledCancelException extends AuthWrapperLoginException {
  AuthWrapperCalledCancelException(super.message);
}

class UserCanceledLoginException extends AuthWrapperLoginException {
  UserCanceledLoginException(super.message);
}

/// Connect a refusé l'échange du code sans le traiter (rate limit, erreur serveur) : réessayer plus tard.
class AuthWrapperLoginTemporarilyRefusedException extends AuthWrapperLoginException {
  AuthWrapperLoginTemporarilyRefusedException(super.message);
}

class AuthWrapperRefreshTokenExpiredException extends AuthWrapperRefreshTokenException {
  AuthWrapperRefreshTokenExpiredException(super.message);
}

/// Connect a refusé le refresh sans le traiter (rate limit, erreur serveur) :
/// le refresh token reste valide, il faudra retenter plus tard.
class AuthWrapperRefreshTemporarilyRefusedException extends AuthWrapperRefreshTokenException {
  AuthWrapperRefreshTemporarilyRefusedException(super.message);
}

// Erreurs générales d'AppAuth, qui ne viennent pas d'une réponse OAuth du serveur.
// iOS (OIDError.h) : domaine org.openid.appauth.general.
// Android (AuthorizationException.GeneralErrors) : type 0.
const _iosAppAuthGeneralErrorDomain = 'org.openid.appauth.general';
const _androidAppAuthGeneralErrorType = '0';

extension on PlatformException {
  bool isNetworkException() => code == "discovery_failed" || code == "network";

  bool isCodeExchangeFailing() => code == "authorize_and_exchange_code_failed";

  bool isUserCancellation() {
    return message?.contains('User cancelled flow') == true ||
        message?.contains(
              'org.openid'
              '.appauth.general erreur -3',
            ) ==
            true;
  }

  // Validation du iat de l'id_token par AppAuth : le message diffère selon la plateforme.
  // Android : "Issued at time is more than 10 minutes before or after the current time"
  // iOS (code -15) : "Issued at time is more than 600 seconds before or after the current time"
  bool isDeviceClockWrong() =>
      '$message $details'.contains('Issued at time') || details.toString().contains('minutes');

  bool isRefreshTokenExpired() {
    if (code != "token_failed") return false;
    return _appAuthError().error == "invalid_grant";
  }

  // Connexion perdue pendant l'appel au token endpoint lui-même (après la discovery).
  // iOS : OIDErrorCodeNetworkError (-5). Android : NETWORK_ERROR (3).
  bool isTokenRequestNetworkError() => _isAppAuthGeneralError(iosCode: '-5', androidCode: '3');

  // Réponse du token endpoint en erreur sans champ OAuth `error` : la demande n'a pas été traitée,
  // au refresh comme à l'échange du code du login. C'est le cas du 429 de connect, qui répond
  // {"statusCode":429,"message":"..."}, et des 5xx.
  // iOS : OIDErrorCodeServerError (-6), le statut HTTP reste dans l'erreur sous-jacente.
  // Android : AppAuth perd le statut HTTP. Un corps sans `error` ni `token_type`, ou qui n'est
  // pas du JSON, donne JSON_DESERIALIZATION_ERROR (5) : impossible de distinguer un 429 d'un 5xx.
  bool isRefusedWithoutOAuthError() => _isAppAuthGeneralError(iosCode: '-6', androidCode: '5');

  bool _isAppAuthGeneralError({required String iosCode, required String androidCode}) {
    if (code != "token_failed" && !isCodeExchangeFailing()) return false;
    final error = _appAuthError();
    return (error.type == _iosAppAuthGeneralErrorDomain && error.code == iosCode) ||
        (error.type == _androidAppAuthGeneralErrorType && error.code == androidCode);
  }

  // flutter_appauth expose les détails typés dans FlutterAppAuthPlatformException.platformErrorDetails ;
  // `details` ne contient que les détails historiques (un simple message sur Android).
  ({String? type, String? code, String? error}) _appAuthError() {
    final self = this;
    final details = self is FlutterAppAuthPlatformException ? self.platformErrorDetails : this.details;
    return switch (details) {
      FlutterAppAuthPlatformErrorDetails() => (type: details.type, code: details.code, error: details.error),
      Map() => (
          type: details['type']?.toString(),
          code: details['code']?.toString(),
          error: details['error']?.toString(),
        ),
      _ => (type: null, code: null, error: null),
    };
  }
}
