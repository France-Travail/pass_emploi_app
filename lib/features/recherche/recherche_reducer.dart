import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/features/recherche/recherche_state.dart';

RechercheState<Criteres, Filtres, Result>
    rechercheReducer<Criteres extends Equatable, Filtres extends Equatable, Result extends Equatable>(
  RechercheState<Criteres, Filtres, Result> current,
  dynamic action,
) {
  if (action is RechercheResetAction<Result>) {
    return current.copyWith(
      status: RechercheStatus.nouvelleRecherche,
      request: () => null,
      results: () => null,
      canLoadMore: false,
    );
  }
  if (action is RechercheNewAction<Result>) {
    return current.copyWith(
      status: RechercheStatus.nouvelleRecherche,
    );
  }
  if (action is RechercheRequestAction<Criteres, Filtres>) {
    return current.copyWith(
      status: RechercheStatus.loading,
      request: () => action.request,
    );
  }
  if (action is RechercheSuccessAction<Result>) {
    return current.copyWith(
      status: RechercheStatus.success,
      results: () => action.results,
      canLoadMore: action.canLoadMore,
    );
  }
  //TODO: c'est pas dommage de faire la newRequest ici et dans le middleware ?
  //TODO: et probable qu'il faille faire pareil pour load more (ou pas, il faut plutôt le faire quand c'est en success)
  if (action is RechercheUpdateFiltres<Filtres>) {
    final currentRequest = current.request;
    final newRequest = currentRequest?.copyWith(filtres: action.filtres);
    return current.copyWith(
      status: RechercheStatus.loading,
      request: () => newRequest,
    );
  }
  if (action is RechercheFailureAction<Result>) return current.copyWith(status: RechercheStatus.failure);
  return current;
}
