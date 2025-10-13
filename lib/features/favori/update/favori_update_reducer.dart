import 'package:pass_emploi_app/features/favori/update/favori_update_actions.dart';
import 'package:pass_emploi_app/features/favori/update/favori_update_state.dart';

FavoriUpdateState favoriUpdateReducer(FavoriUpdateState currentState, dynamic action) {
  if (action is FavoriUpdateLoadingAction) {
    return _updateState(currentState, action.favoriId, FavoriUpdateStatus.LOADING, isPostulated: false);
  } else if (action is FavoriUpdateSuccessAction) {
    return _updateState(currentState, action.favoriId, FavoriUpdateStatus.SUCCESS, isPostulated: action.isPostulated);
  } else if (action is FavoriUpdateFailureAction) {
    return _updateState(currentState, action.favoriId, FavoriUpdateStatus.ERROR, isPostulated: false);
  } else if (action is FavoriUpdateConfirmationResetAction) {
    return FavoriUpdateState(currentState.requestStatus, confirmationPostuleOffreId: null);
  } else {
    return currentState;
  }
}

FavoriUpdateState _updateState(FavoriUpdateState currentState, String offreId, FavoriUpdateStatus status,
    {required bool isPostulated}) {
  final newStatusMap = Map.of(currentState.requestStatus);
  newStatusMap[offreId] = status;
  return FavoriUpdateState(newStatusMap, confirmationPostuleOffreId: isPostulated ? offreId : null);
}
