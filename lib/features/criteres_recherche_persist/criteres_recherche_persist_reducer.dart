import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_actions.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_state.dart';

CriteresRecherchePersistState criteresRecherchePersistReducer(CriteresRecherchePersistState current, dynamic action) {
  if (action is CriteresRecherchePersistSuccessAction) return CriteresRecherchePersistSuccessState(action.criteres);
  return current;
}
