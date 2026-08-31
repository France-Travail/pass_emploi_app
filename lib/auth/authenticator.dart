import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/auth/auth_id_token.dart';
import 'package:pass_emploi_app/auth/auth_refresh_token_request.dart';
import 'package:pass_emploi_app/auth/auth_token_request.dart';
import 'package:pass_emploi_app/auth/auth_token_response.dart';
import 'package:pass_emploi_app/auth/auth_wrapper.dart';
import 'package:pass_emploi_app/configuration/configuration.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/repositories/auth/logout_repository.dart';
import 'package:pass_emploi_app/repositories/installation_id_repository.dart';

const String _idTokenKey = "idToken";
const String _accessTokenKey = "accessToken";
const String _refreshTokenKey = "refreshToken";
const String _loginInProgressKey = "loginInProgress";

enum RefreshTokenStatus { SUCCESSFUL, GENERIC_ERROR, USER_NOT_LOGGED_IN, NETWORK_UNREACHABLE, EXPIRED_REFRESH_TOKEN }

enum AuthenticationMode { GENERIC, SIMILO, POLE_EMPLOI, DEMO }

const Map<String, String> similoParams = {"kc_idp_hint": "similo-jeune"};
const Map<String, String> poleEmploiParams = {"kc_idp_hint": "ft-beneficiaire"};

sealed class AuthenticatorResponse {}

class SuccessAuthenticatorResponse extends AuthenticatorResponse {}

class CancelledAuthenticatorResponse extends AuthenticatorResponse {}

class WrongDeviceClockAuthenticatorResponse extends AuthenticatorResponse {}

class FailureAuthenticatorResponse extends AuthenticatorResponse {
  final String message;

  FailureAuthenticatorResponse(this.message);
}

class Authenticator {
  final AuthWrapper _authWrapper;
  final LogoutRepository _logoutRepository;
  final Configuration _configuration;
  final FlutterSecureStorage _preferences;
  final Crashlytics? _crashlytics;
  final InstallationIdRepository? _installationIdRepository;

  Authenticator(
    this._authWrapper,
    this._logoutRepository,
    this._configuration,
    this._preferences, [
    this._crashlytics,
    this._installationIdRepository,
  ]);

  Future<AuthenticatorResponse> login(AuthenticationMode mode) async {
    await _markLoginInProgress(mode);
    try {
      final response = await _authWrapper.login(
        AuthTokenRequest(
          _configuration.authClientId,
          _configuration.authLoginRedirectUrl,
          _configuration.authIssuer,
          _configuration.authScopes,
          _configuration.authClientSecret,
          await _additionalParams(mode),
        ),
      );
      await _saveToken(response);
      return SuccessAuthenticatorResponse();
    } catch (e) {
      if (e is UserCanceledLoginException) return CancelledAuthenticatorResponse();
      if (e is AuthWrapperWrongDeviceClockException) return WrongDeviceClockAuthenticatorResponse();
      return FailureAuthenticatorResponse(e.toString());
    } finally {
      await _clearLoginInProgress();
    }
  }

  /// Le marqueur n'est nettoyé que quand le flow AppAuth rend la main (succès,
  /// échec ou annulation). S'il est encore présent au bootstrap suivant, le
  /// process est mort pendant l'auth (navigateur ouvert, redirect jamais
  /// délivré à l'app) : l'utilisateur a été renvoyé à l'écran de connexion
  /// sans qu'aucune erreur ne soit visible nulle part.
  Future<void> checkForInterruptedLogin() async {
    final String? marker = await _preferences.read(key: _loginInProgressKey);
    if (marker == null) return;
    await _clearLoginInProgress();
    final parts = marker.split('|');
    final startedAt = parts.length > 1 ? int.tryParse(parts[1]) : null;
    final elapsedSeconds = startedAt != null
        ? ((DateTime.now().millisecondsSinceEpoch - startedAt) ~/ 1000).toString()
        : 'unknown';
    _crashlytics?.setCustomKey('interrupted_login_mode', parts.first);
    _crashlytics?.setCustomKey('interrupted_login_elapsed_seconds', elapsedSeconds);
    _crashlytics?.recordNonNetworkException(
      "Login interrompu : le flow AppAuth n'a jamais rendu la main (process tué pendant l'auth ?)",
      StackTrace.current,
    );
  }

  Future<void> _markLoginInProgress(AuthenticationMode mode) async {
    try {
      await _preferences.write(
        key: _loginInProgressKey,
        value: "${mode.name}|${DateTime.now().millisecondsSinceEpoch}",
      );
    } catch (_) {
      // Un stockage défaillant ne doit pas empêcher le login pour un simple marqueur de diagnostic.
    }
  }

  Future<void> _clearLoginInProgress() async {
    try {
      await _preferences.delete(key: _loginInProgressKey);
    } catch (_) {
      // Un stockage défaillant ne doit pas empêcher le login pour un simple marqueur de diagnostic.
    }
  }

  Future<bool> isLoggedIn() async => await idToken() != null;

  Future<AuthIdToken?> idToken() async {
    final String? idToken = await _preferences.read(key: _idTokenKey);
    if (idToken != null) {
      try {
        return AuthIdToken.parse(idToken);
      } catch (e, stack) {
        _crashlytics?.recordNonNetworkException("Corrupted ID token : $idToken", stack);
        await _preferences.delete(key: _idTokenKey);
      }
    }
    return null;
  }

  Future<String?> accessToken() async => _preferences.read(key: _accessTokenKey);

  Future<RefreshTokenStatus> performRefreshToken() async {
    final String? refreshToken = await _preferences.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      return RefreshTokenStatus.USER_NOT_LOGGED_IN;
    }

    try {
      final AuthTokenResponse response = await _authWrapper.refreshToken(
        AuthRefreshTokenRequest(
          _configuration.authClientId,
          _configuration.authLoginRedirectUrl,
          _configuration.authIssuer,
          refreshToken,
          _configuration.authClientSecret,
        ),
      );
      await _saveToken(response);
      return RefreshTokenStatus.SUCCESSFUL;
    } on AuthWrapperNetworkException {
      return RefreshTokenStatus.NETWORK_UNREACHABLE;
    } on AuthWrapperRefreshTokenExpiredException {
      if (await _preferences.read(key: _refreshTokenKey) != refreshToken) {
        return RefreshTokenStatus.SUCCESSFUL;
      }
      await _deleteToken();
      return RefreshTokenStatus.EXPIRED_REFRESH_TOKEN;
    } on AuthWrapperRefreshTokenException {
      return RefreshTokenStatus.GENERIC_ERROR;
    }
  }

  Future<bool> logout(String userId, LogoutReason reason) async {
    final String? refreshToken = await _preferences.read(key: _refreshTokenKey);
    if (refreshToken != null) {
      await _logoutRepository.logout(refreshToken, userId, reason);
    }
    await _deleteToken();
    return true;
  }

  Future<void> _saveToken(AuthTokenResponse response) async {
    await _preferences.write(key: _refreshTokenKey, value: response.refreshToken);
    await _preferences.write(key: _accessTokenKey, value: response.accessToken);
    await _preferences.write(key: _idTokenKey, value: response.idToken);
  }

  Future<void> _deleteToken() async {
    await _preferences.delete(key: _idTokenKey);
    await _preferences.delete(key: _accessTokenKey);
    await _preferences.delete(key: _refreshTokenKey);
  }

  Future<Map<String, String>?> _additionalParams(AuthenticationMode mode) async {
    Map<String, String>? modeParams;
    if (mode == AuthenticationMode.SIMILO) modeParams = similoParams;
    if (mode == AuthenticationMode.POLE_EMPLOI) modeParams = poleEmploiParams;

    // Transmis en query du /auth pour que Connect logge l'installation id sur
    // tout le parcours de login : les échecs y sont sinon anonymes tant que
    // l'app n'a pas atteint l'API (qui reçoit X-InstallationId en header).
    final installationId = await _installationId();
    if (installationId == null) return modeParams;
    return {...?modeParams, 'installation_id': installationId};
  }

  Future<String?> _installationId() async {
    try {
      return await _installationIdRepository?.getInstallationId();
    } catch (_) {
      // Un stockage défaillant ne doit pas empêcher le login pour un identifiant de diagnostic.
      return null;
    }
  }
}
