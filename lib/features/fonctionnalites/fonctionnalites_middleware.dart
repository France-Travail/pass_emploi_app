import 'package:pass_emploi_app/features/fonctionnalites/fonctionnalites_actions.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/push_notification/register/register_push_notification_token_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/fonctionnalites_repository.dart';
import 'package:redux/redux.dart';

class FonctionnalitesMiddleware extends MiddlewareClass<AppState> {
  final FonctionnalitesRepository _repository;

  FonctionnalitesMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    if (action is LoginSuccessAction) {
      await _load(store, action.user.id, withLoading: true);
    } else if (action is FonctionnalitesRequestAction) {
      await _load(store, store.state.userId(), withLoading: true);
    } else if (action is FonctionnalitesRefreshAction || action is ConfigureApplicationOnForegroundAction) {
      await _load(store, store.state.userId(), withLoading: false);
    }
  }

  Future<void> _load(Store<AppState> store, String? userId, {required bool withLoading}) async {
    if (userId == null) return;
    if (withLoading) store.dispatch(FonctionnalitesLoadingAction());
    final actives = await _repository.get(userId);
    if (actives != null) {
      store.dispatch(FonctionnalitesSuccessAction(actives));
    } else {
      store.dispatch(FonctionnalitesFailureAction());
    }
  }
}
