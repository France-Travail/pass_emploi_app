import 'package:pass_emploi_app/features/accueil/accueil_actions.dart';
import 'package:pass_emploi_app/features/communications/communications_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/communications_repository.dart';
import 'package:redux/redux.dart';

class CommunicationsMiddleware extends MiddlewareClass<AppState> {
  final CommunicationsRepository _repository;

  CommunicationsMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    final userId = store.state.userId();
    if (userId == null) return;
    if (action is CommunicationsRequestAction || action is AccueilRequestAction) {
      store.dispatch(CommunicationsLoadingAction());
      final result = await _repository.get(userId);
      if (result != null) {
        store.dispatch(CommunicationsSuccessAction(result));
      } else {
        store.dispatch(CommunicationsFailureAction());
      }
    }
  }
}
