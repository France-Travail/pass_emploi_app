import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/auth/authenticator.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/remote_config_repository.dart';
import 'package:redux/redux.dart';
import 'package:synchronized/synchronized.dart';

class AuthAccessTokenRetriever {
  static const _failureCountKey = 'consecutiveRefreshGenericErrors';

  final Authenticator _authenticator;
  final RemoteConfigRepository _remoteConfigRepository;
  final FlutterSecureStorage _preferences;
  final Lock _lock;
  late Store<AppState> _store;
  int? _cachedFailureCount;

  AuthAccessTokenRetriever(
    this._authenticator,
    this._remoteConfigRepository,
    this._preferences,
    this._lock,
  );

  Future<String> accessToken() async {
    return _lock.synchronized(() async => _accessToken());
  }

  Future<String> _accessToken() async {
    final accessToken = await _authenticator.idToken();
    if (accessToken == null) throw Exception("ID Token is null");

    if (accessToken.isValid(now: DateTime.now())) {
      await _resetFailureCount();
      return (await _authenticator.accessToken())!;
    }

    final refreshTokenStatus = await _authenticator.performRefreshToken();
    switch (refreshTokenStatus) {
      case RefreshTokenStatus.SUCCESSFUL:
        await _resetFailureCount();
        return (await _authenticator.accessToken())!;
      case RefreshTokenStatus.NETWORK_UNREACHABLE:
        throw Exception(
          "Token refresh failed (network error): $refreshTokenStatus",
        );
      case RefreshTokenStatus.GENERIC_ERROR:
        final count = await _incrementFailureCount();
        _store.dispatch(TokenRefreshGenericErrorAction(count));
        if (count >= _remoteConfigRepository.maxRefreshFailuresBeforeLogout()) {
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
