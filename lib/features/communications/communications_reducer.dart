import 'package:pass_emploi_app/features/communications/communications_actions.dart';
import 'package:pass_emploi_app/features/communications/communications_state.dart';

CommunicationsState communicationsReducer(CommunicationsState current, dynamic action) {
  if (action is CommunicationsLoadingAction && current is! CommunicationsSuccessState) {
    return CommunicationsLoadingState();
  }
  if (action is CommunicationsFailureAction) return CommunicationsFailureState();
  if (action is CommunicationsSuccessAction) return CommunicationsSuccessState(action.result.messageInformatif);
  return current;
}
