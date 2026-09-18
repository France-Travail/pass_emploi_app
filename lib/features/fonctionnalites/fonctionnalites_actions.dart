import 'package:pass_emploi_app/models/fonctionnalite.dart';

class FonctionnalitesRequestAction {}

class FonctionnalitesRefreshAction {}

class FonctionnalitesLoadingAction {}

class FonctionnalitesSuccessAction {
  final Set<Fonctionnalite> actives;

  FonctionnalitesSuccessAction(this.actives);
}

class FonctionnalitesFailureAction {}
