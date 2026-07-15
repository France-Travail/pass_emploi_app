class InvitePrenomRequestAction {}

class InvitePrenomLoadingAction {}

class InvitePrenomFailureAction {}

class InvitePrenomSuccessAction {
  final String prenom;

  InvitePrenomSuccessAction(this.prenom);
}

class InvitePrenomUpdateRequestAction {
  final String prenom;

  InvitePrenomUpdateRequestAction(this.prenom);
}

class InvitePrenomUpdateSuccessAction {
  final String prenom;

  InvitePrenomUpdateSuccessAction(this.prenom);
}

class InvitePrenomUpdateFailureAction {
  final String prenom;

  InvitePrenomUpdateFailureAction(this.prenom);
}
