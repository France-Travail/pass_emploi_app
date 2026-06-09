import 'package:pass_emploi_app/features/soft_update/soft_update_actions.dart';
import 'package:pass_emploi_app/features/soft_update/soft_update_state.dart';

SoftUpdateState softUpdateReducer(SoftUpdateState current, dynamic action) {
  if (action is ShowSoftUpdateAction) return ShowSoftUpdateState();
  if (action is SoftUpdateDismissAction || action is SoftUpdateDownloadAction) {
    return SoftUpdateNotShownState();
  }
  return current;
}
