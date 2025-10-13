enum FavoriUpdateStatus { LOADING, SUCCESS, ERROR }

class FavoriUpdateState {
  final Map<String, FavoriUpdateStatus> requestStatus;
  final String? confirmationPostuleOffreId;

  FavoriUpdateState(this.requestStatus, {this.confirmationPostuleOffreId});
}
