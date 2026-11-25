import 'package:pass_emploi_app/features/structures_accompagnement/structures_accompagnement_actions.dart';
import 'package:pass_emploi_app/features/structures_accompagnement/structures_accompagnement_state.dart';

StructuresAccompagnementState structuresAccompagnementReducer(StructuresAccompagnementState current, dynamic action) {
  if (action is StructuresAccompagnementLoadingAction) return StructuresAccompagnementLoadingState(action.request);
  if (action is StructuresAccompagnementResetAction) return StructuresAccompagnementNotInitializedState();
  // Une réponse arrivée après un retour à la recherche (ou après une autre recherche) est ignorée.
  if (current is! StructuresAccompagnementLoadingState) return current;
  if (action is StructuresAccompagnementFailureAction && action.request == current.request) {
    return StructuresAccompagnementFailureState(action.request);
  }
  if (action is StructuresAccompagnementSuccessAction && action.request == current.request) {
    return StructuresAccompagnementSuccessState(action.request, action.result);
  }
  return current;
}
