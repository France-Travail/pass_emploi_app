import 'package:pass_emploi_app/features/invite_prenom/invite_prenom_actions.dart';
import 'package:pass_emploi_app/features/invite_prenom/invite_prenom_state.dart';

InvitePrenomState invitePrenomReducer(InvitePrenomState current, dynamic action) {
  if (action is InvitePrenomLoadingAction) return InvitePrenomLoadingState();
  if (action is InvitePrenomFailureAction) return InvitePrenomFailureState();
  if (action is InvitePrenomSuccessAction) return InvitePrenomSuccessState(action.prenom);
  if (action is InvitePrenomUpdateSuccessAction) return InvitePrenomUpdatedState(action.prenom);
  if (action is InvitePrenomUpdateFailureAction) return InvitePrenomUpdateFailureState(action.prenom);
  return current;
}
