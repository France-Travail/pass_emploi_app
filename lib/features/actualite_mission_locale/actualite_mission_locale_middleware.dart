import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/actualite_mission_locale_repository.dart';
import 'package:redux/redux.dart';

class ActualiteMissionLocaleMiddleware extends MiddlewareClass<AppState> {
  final ActualiteMissionLocaleRepository _repository;

  ActualiteMissionLocaleMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    final userId = store.state.userId();
    if (userId == null) return;
    final state = store.state.loginState;
    final user = state is LoginSuccessState ? state.user : null;
    final isMiLo = user?.loginMode.isMiLo() == true;
    if (!isMiLo) return;
    if (action is ActualiteMissionLocaleRequestAction) {
      store.dispatch(ActualiteMissionLocaleLoadingAction());
      final result = await _repository.get(userId);
      if (result != null) {
        store.dispatch(ActualiteMissionLocaleSuccessAction(result));
      } else {
        store.dispatch(ActualiteMissionLocaleFailureAction());
      }
    }
  }
}
