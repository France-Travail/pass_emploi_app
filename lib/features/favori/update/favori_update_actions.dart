import 'package:pass_emploi_app/features/offres_suivies/offres_suivies_state.dart';
import 'package:pass_emploi_app/models/favori.dart';

class FavoriUpdateRequestAction<T> {
  final String favoriId;
  final FavoriStatus newStatus;
  final FavoriStatus? currentStatus;
  final bool showConfirmationOffre;

  FavoriUpdateRequestAction(
    this.favoriId,
    this.newStatus, {
    this.currentStatus,
    this.showConfirmationOffre = true,
  });
}

class FavoriUpdateLoadingAction<T> {
  final String favoriId;

  FavoriUpdateLoadingAction(this.favoriId);
}

class FavoriUpdateSuccessAction<T> {
  final String favoriId;
  final FavoriStatus confirmedNewStatus;
  final ConfirmationOffre? confirmationOffre;

  FavoriUpdateSuccessAction(this.favoriId, this.confirmedNewStatus, this.confirmationOffre);
}

class FavoriUpdateFailureAction<T> {
  final String favoriId;

  FavoriUpdateFailureAction(this.favoriId);
}

class FavoriUpdateConfirmationResetAction {
  FavoriUpdateConfirmationResetAction();
}
