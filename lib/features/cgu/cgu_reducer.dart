import 'package:pass_emploi_app/features/cgu/cgu_actions.dart';
import 'package:pass_emploi_app/features/cgu/cgu_state.dart';

CguState cguReducer(CguState current, dynamic action) {
  if (action is CguNeverAcceptedAction) return CguNeverAcceptedState();
  if (action is CguAlreadyAcceptedAction) return CguAlreadyAcceptedState();
  if (action is CguUpdateRequiredAction) return CguUpdateRequiredState(action.updatedCgu);
  // Chaque nouvelle tentative efface l'échec précédent : un nouvel échec affiche de nouveau l'erreur.
  if (action is CguAcceptedAction) return _withAcceptFailed(current, false);
  if (action is CguAcceptFailureAction) return _withAcceptFailed(current, true);
  return current;
}

CguState _withAcceptFailed(CguState current, bool acceptFailed) {
  return switch (current) {
    CguNeverAcceptedState() => CguNeverAcceptedState(acceptFailed: acceptFailed),
    CguUpdateRequiredState() => CguUpdateRequiredState(current.updatedCgu, acceptFailed: acceptFailed),
    _ => current,
  };
}
