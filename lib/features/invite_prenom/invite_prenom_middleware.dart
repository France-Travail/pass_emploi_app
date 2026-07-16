import 'package:pass_emploi_app/features/invite_prenom/invite_prenom_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/invite_prenom_repository.dart';
import 'package:redux/redux.dart';

class InvitePrenomMiddleware extends MiddlewareClass<AppState> {
  final InvitePrenomRepository _repository;

  InvitePrenomMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    final userId = store.state.userId();
    if (userId == null) return;

    if (action is InvitePrenomRequestAction) {
      store.dispatch(InvitePrenomLoadingAction());
      final prenom = await _repository.getPrenom(userId);
      if (prenom != null) {
        store.dispatch(InvitePrenomSuccessAction(prenom));
      } else {
        store.dispatch(InvitePrenomFailureAction());
      }
    } else if (action is InvitePrenomUpdateRequestAction) {
      store.dispatch(InvitePrenomLoadingAction());
      final ok = await _repository.updatePrenom(userId, action.prenom);
      if (ok) {
        store.dispatch(InvitePrenomUpdateSuccessAction(action.prenom));
      } else {
        store.dispatch(InvitePrenomUpdateFailureAction(action.prenom));
      }
    }
  }
}
