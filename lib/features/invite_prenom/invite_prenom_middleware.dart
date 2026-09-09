import 'package:pass_emploi_app/features/invite_prenom/invite_prenom_actions.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
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

    if (action is InvitePrenomRequestAction ||
        (action is LoginSuccessAction && action.user.loginMode.isInvite())) {
      await _fetchPrenom(store, userId);
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

  Future<void> _fetchPrenom(Store<AppState> store, String userId) async {
    store.dispatch(InvitePrenomLoadingAction());
    final prenom = await _repository.getPrenom(userId);
    if (prenom != null) {
      store.dispatch(InvitePrenomSuccessAction(prenom));
    } else {
      store.dispatch(InvitePrenomFailureAction());
    }
  }
}
