import 'package:pass_emploi_app/features/favori/update/favori_update_actions.dart';
import 'package:pass_emploi_app/features/favori/update/favori_update_state.dart';
import 'package:pass_emploi_app/features/offres_suivies/offres_suivies_state.dart';

FavoriUpdateState favoriUpdateReducer(FavoriUpdateState currentState, dynamic action) {
  if (action is FavoriUpdateLoadingAction) {
    return _updateState(currentState, action.favoriId, FavoriUpdateStatus.LOADING, null);
  } else if (action is FavoriUpdateSuccessAction) {
    return _updateState(
      currentState,
      action.favoriId,
      FavoriUpdateStatus.SUCCESS,
      action.confirmationOffre,
    );
  } else if (action is FavoriUpdateFailureAction) {
    return _updateState(currentState, action.favoriId, FavoriUpdateStatus.ERROR, null);
  } else if (action is FavoriUpdateConfirmationResetAction) {
    return FavoriUpdateState(currentState.requestStatus, confirmationOffre: null);
  } else {
    return currentState;
  }
}

FavoriUpdateState _updateState(
  FavoriUpdateState currentState,
  String offreId,
  FavoriUpdateStatus status,
  ConfirmationOffre? confirmation,
) {
  final newStatusMap = Map.of(currentState.requestStatus);
  newStatusMap[offreId] = status;
  return FavoriUpdateState(
    newStatusMap,
    confirmationOffre: confirmation,
  );
}
