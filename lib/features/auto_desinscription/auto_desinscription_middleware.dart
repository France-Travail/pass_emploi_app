import 'package:pass_emploi_app/features/auto_desinscription/auto_desinscription_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/auto_desinscription_repository.dart';
import 'package:redux/redux.dart';

class AutoDesinscriptionMiddleware extends MiddlewareClass<AppState> {
  final AutoDesinscriptionRepository _repository;

  AutoDesinscriptionMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    final userId = store.state.userId();
    if (userId == null) return;
    if (action is AutoDesinscriptionRequestAction) {
      store.dispatch(AutoDesinscriptionLoadingAction());
      final result = await _repository.desinscrire(userId, action.eventId, action.motif);
      if (result != null) {
        store.dispatch(AutoDesinscriptionSuccessAction(result));
      } else {
        store.dispatch(AutoDesinscriptionFailureAction());
      }
    }
  }
}
