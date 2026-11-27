import 'package:pass_emploi_app/models/cgu.dart';

class CguAlreadyAcceptedAction {}

class CguNeverAcceptedAction {}

class CguUpdateRequiredAction {
  final Cgu updatedCgu;

  CguUpdateRequiredAction(this.updatedCgu);
}

class CguAcceptedAction {
  final DateTime date;

  CguAcceptedAction(this.date);
}

/// L'acceptation n'a pas pu être enregistrée : la page des CGU reste affichée et signale l'erreur.
class CguAcceptFailureAction {}

class CguRefusedAction {}
