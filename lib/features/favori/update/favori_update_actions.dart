import 'package:pass_emploi_app/models/favori.dart';

class FavoriUpdateRequestAction<T> {
  final String favoriId;
  final FavoriStatus newStatus;
  final FavoriStatus? currentStatus;

  FavoriUpdateRequestAction(this.favoriId, this.newStatus, {this.currentStatus});
}

class FavoriUpdateLoadingAction<T> {
  final String favoriId;

  FavoriUpdateLoadingAction(this.favoriId);
}

class FavoriUpdateSuccessAction<T> {
  final String favoriId;
  final FavoriStatus confirmedNewStatus;
  final bool isPostulated;

  FavoriUpdateSuccessAction(this.favoriId, this.confirmedNewStatus, {this.isPostulated = false});
}

class FavoriUpdateFailureAction<T> {
  final String favoriId;

  FavoriUpdateFailureAction(this.favoriId);
}

class FavoriUpdateConfirmationResetAction {
  FavoriUpdateConfirmationResetAction();
}
