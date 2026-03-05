import 'package:pass_emploi_app/features/auto_desinscription/auto_desinscription_actions.dart';
import 'package:pass_emploi_app/features/auto_desinscription/auto_desinscription_state.dart';

AutoDesinscriptionState autoDesinscriptionReducer(AutoDesinscriptionState current, dynamic action) {
  if (action is AutoDesinscriptionLoadingAction) return AutoDesinscriptionLoadingState();
  if (action is AutoDesinscriptionFailureAction) return AutoDesinscriptionFailureState();
  if (action is AutoDesinscriptionSuccessAction) return AutoDesinscriptionSuccessState(action.result);
  if (action is AutoDesinscriptionResetAction) return AutoDesinscriptionNotInitializedState();
  return current;
}
