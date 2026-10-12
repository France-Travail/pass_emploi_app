import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_actions.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_state.dart';

RepriseCompteInviteState repriseCompteInviteReducer(RepriseCompteInviteState current, dynamic action) {
  if (action is RepriseCompteInviteLoadingAction) return RepriseCompteInviteLoadingState();
  if (action is RepriseCompteInviteFailureAction) return RepriseCompteInviteFailureState(action.message);
  if (action is RepriseCompteInviteWrongDeviceClockAction) return RepriseCompteInviteWrongDeviceClockState();
  if (action is RepriseCompteInviteResetAction) return RepriseCompteInviteNotInitializedState();
  return current;
}
