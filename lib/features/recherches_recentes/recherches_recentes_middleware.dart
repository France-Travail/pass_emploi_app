import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/features/recherches_recentes/recherches_recentes_actions.dart';
import 'package:pass_emploi_app/models/alerte/alerte.dart';
import 'package:pass_emploi_app/models/alerte/alerte_from_request.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/recherches_recentes_repository.dart';
import 'package:redux/redux.dart';

class RecherchesRecentesMiddleware extends MiddlewareClass<AppState> {
  final RecherchesRecentesRepository _repository;

  RecherchesRecentesMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    if (action is LoginSuccessAction) {
      final result = await _repository.get();
      store.dispatch(RecherchesRecentesSuccessAction(result));
    } else if (action is RechercheSuccessAction) {
      await addToRecentSearch(action, store);
    }
  }

  Future<void> addToRecentSearch(
    RechercheSuccessAction<Equatable, Equatable, dynamic> action,
    Store<AppState> store,
  ) async {
    final search = createAlerteFromRequest(action.request);
    if (search == null) return;

    var newList = List<Alerte>.from(store.state.recherchesRecentesState.recentSearches);
    newList.insert(0, search);
    newList = newList.take(50).toList();

    await _repository.save(newList);
    store.dispatch(RecherchesRecentesSuccessAction(newList));
  }
}
