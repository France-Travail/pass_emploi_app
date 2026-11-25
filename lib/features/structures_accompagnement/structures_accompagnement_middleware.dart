import 'package:pass_emploi_app/features/structures_accompagnement/structures_accompagnement_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/structures_accompagnement_repository.dart';
import 'package:redux/redux.dart';

class StructuresAccompagnementMiddleware extends MiddlewareClass<AppState> {
  final StructuresAccompagnementRepository _repository;

  StructuresAccompagnementMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    // Route réservée au mode invité.
    if (!store.state.isInviteLoginMode()) return;
    if (action is StructuresAccompagnementRequestAction) {
      final request = action.request;
      final codePostal = request.commune.codePostal;
      store.dispatch(StructuresAccompagnementLoadingAction(request));
      final result = codePostal == null
          ? null
          : await _repository.get(type: request.type, codeInsee: request.commune.code, codePostal: codePostal);
      if (result != null) {
        store.dispatch(StructuresAccompagnementSuccessAction(request, result));
      } else {
        store.dispatch(StructuresAccompagnementFailureAction(request));
      }
    }
  }
}
