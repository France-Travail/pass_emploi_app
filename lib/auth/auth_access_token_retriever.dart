import 'package:clock/clock.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/auth/authenticator.dart';
import 'package:pass_emploi_app/auth/token_refresh_pause.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/remote_config_repository.dart';
import 'package:redux/redux.dart';

class AuthAccessTokenRetriever {
  static const _failureCountKey = 'consecutiveRefreshGenericErrors';

  final Authenticator _authenticator;
  final RemoteConfigRepository _remoteConfigRepository;
  final FlutterSecureStorage _preferences;
  final TokenRefreshPause _refreshPause;
  late Store<AppState> _store;
  int? _cachedFailureCount;
  Future<String>? _pendingAccessToken;

  AuthAccessTokenRetriever(
    this._authenticator,
    this._remoteConfigRepository,
    this._preferences,
  ) : _refreshPause = TokenRefreshPause(firstPause: _remoteConfigRepository.tokenRefreshFirstPause);

  /// Les appels faits pendant qu'une demande est en cours partagent son résultat :
  /// un écran qui lance plusieurs requêtes en parallèle ne déclenche qu'un refresh.
  Future<String> accessToken() {
    return _pendingAccessToken ??= _accessToken().whenComplete(() => _pendingAccessToken = null);
  }

  Future<String> _accessToken() async {
    final accessToken = await _authenticator.idToken();
    if (accessToken == null) throw Exception("ID Token is null");

    if (accessToken.isValid(now: clock.now())) {
      _refreshPause.reset();
      await _resetFailureCount();
      return (await _authenticator.accessToken())!;
    }

    final pauseEnd = _refreshPause.activeUntil(clock.now());
    if (pauseEnd != null) throw TokenRefreshTemporarilyRefusedException(pauseEnd);

    final refreshTokenStatus = await _authenticator.refreshStoredSession();
    switch (refreshTokenStatus) {
      case RefreshTokenStatus.SUCCESSFUL:
        _refreshPause.reset();
        await _resetFailureCount();
        return (await _authenticator.accessToken())!;
      case RefreshTokenStatus.TEMPORARILY_REFUSED:
        final retryNotBefore = _refreshPause.start(clock.now());
        _store.dispatch(TokenRefreshTemporarilyRefusedAction(retryNotBefore));
        throw TokenRefreshTemporarilyRefusedException(retryNotBefore);
      case RefreshTokenStatus.NETWORK_UNREACHABLE:
        throw Exception(
          "Token refresh failed (network error): $refreshTokenStatus",
        );
      case RefreshTokenStatus.GENERIC_ERROR:
        final count = await _incrementFailureCount();
        _store.dispatch(TokenRefreshGenericErrorAction(count));
        // Un invité ne peut pas se reconnecter à son compte : le déconnecter le lui ferait perdre.
        final canLogout = !_store.state.isInviteLoginMode();
        if (canLogout && count >= _remoteConfigRepository.maxRefreshFailuresBeforeLogout()) {
          await _resetFailureCount();
          _store.dispatch(
            RequestLogoutAction(LogoutReason.tooManyRefreshGenericErrors),
          );
        }
        throw Exception(
          "Token refresh failed (generic error): $refreshTokenStatus",
        );
      case RefreshTokenStatus.EXPIRED_REFRESH_TOKEN:
      case RefreshTokenStatus.USER_NOT_LOGGED_IN:
        await _resetFailureCount();
        _store.dispatch(RequestLogoutAction(LogoutReason.expiredRefreshToken));
        throw Exception("Cannot refresh token: $refreshTokenStatus");
    }
  }

  Future<int> _failureCount() async {
    return _cachedFailureCount ??=
        int.tryParse(await _preferences.read(key: _failureCountKey) ?? '') ?? 0;
  }

  Future<int> _incrementFailureCount() async {
    final next = (await _failureCount()) + 1;
    _cachedFailureCount = next;
    await _preferences.write(key: _failureCountKey, value: next.toString());
    return next;
  }

  Future<void> _resetFailureCount() async {
    if ((await _failureCount()) == 0) return;
    _cachedFailureCount = 0;
    await _preferences.delete(key: _failureCountKey);
  }

  void setStore(Store<AppState> store) => _store = store;
}

/// Connect refuse temporairement le refresh : la session est conservée, on retentera
/// après [retryNotBefore].
class TokenRefreshTemporarilyRefusedException implements Exception {
  final DateTime retryNotBefore;

  TokenRefreshTemporarilyRefusedException(this.retryNotBefore);

  @override
  String toString() => "Token refresh temporarily refused, retry not before $retryNotBefore";
}
