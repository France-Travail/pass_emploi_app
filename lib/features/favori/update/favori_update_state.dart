import 'package:pass_emploi_app/features/offres_suivies/offres_suivies_state.dart';

enum FavoriUpdateStatus { LOADING, SUCCESS, ERROR }

class FavoriUpdateState {
  final Map<String, FavoriUpdateStatus> requestStatus;
  final ConfirmationOffre? confirmationOffre;

  FavoriUpdateState(this.requestStatus, {this.confirmationOffre});
}
