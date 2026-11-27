import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:pass_emploi_app/auth/auth_access_token_retriever.dart';
import 'package:pass_emploi_app/features/too_many_requests/too_many_requests_actions.dart';
import 'package:pass_emploi_app/network/interceptors/pass_emploi_base_interceptor.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

/// Signale au store les requêtes refusées pour excès de requêtes, pour que les écrans affichent
/// le message dédié au lieu de l'erreur générique.
///
/// À ajouter en dernier : quand le cache répond à la place de l'API, l'erreur n'arrive pas jusqu'ici
/// et l'écran, qui reçoit ses données, n'a pas à afficher de message.
class TooManyRequestsInterceptor extends PassEmploiBaseInterceptor {
  late Store<AppState> _store;

  void setStore(Store<AppState> store) => _store = store;

  @override
  void onPassEmploiError(DioException err, ErrorInterceptorHandler handler) {
    final retryNotBefore = err.tooManyRequestsRetryNotBefore(clock.now());
    if (retryNotBefore != null) _store.dispatch(TooManyRequestsAction(retryNotBefore));
    handler.next(err);
  }
}

extension TooManyRequestsDioException on DioException {
  static const _defaultRetryAfter = Duration(minutes: 1);

  /// 429 de l'API, ou refresh du token refusé par connect (l'AuthInterceptor rejette alors la requête).
  bool isTooManyRequests() => tooManyRequestsRetryNotBefore(clock.now()) != null;

  DateTime? tooManyRequestsRetryNotBefore(DateTime now) {
    final error = this.error;
    if (error is TokenRefreshTemporarilyRefusedException) return error.retryNotBefore;
    final response = this.response;
    if (response?.statusCode != 429) return null;
    // L'API renvoie le délai en secondes dans Retry-After.
    final retryAfterSeconds = int.tryParse(
      response?.headers.value('retry-after') ?? '',
    );
    return now.add(
      retryAfterSeconds != null ? Duration(seconds: retryAfterSeconds) : _defaultRetryAfter,
    );
  }
}
