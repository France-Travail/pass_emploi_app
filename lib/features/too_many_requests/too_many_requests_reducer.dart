import 'package:pass_emploi_app/features/too_many_requests/too_many_requests_actions.dart';
import 'package:pass_emploi_app/features/too_many_requests/too_many_requests_state.dart';

TooManyRequestsState tooManyRequestsReducer(
  TooManyRequestsState current,
  dynamic action,
) {
  if (action is TooManyRequestsAction) {
    // On garde la fin la plus lointaine : un refus court de l'API ne raccourcit pas une pause plus longue.
    final currentRetryNotBefore = current.retryNotBefore;
    if (currentRetryNotBefore != null && !action.retryNotBefore.isAfter(currentRetryNotBefore)) return current;
    return TooManyRequestsState(retryNotBefore: action.retryNotBefore);
  }
  return current;
}
