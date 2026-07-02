import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/location.dart';

class CriteresRecherchePersistWriteAction {
  final CriteresRechercheUtilisateur criteres;

  CriteresRecherchePersistWriteAction(this.criteres);
}

class CriteresRecherchePersistWriteLocationAction {
  final Location? location;

  CriteresRecherchePersistWriteLocationAction(this.location);
}

class CriteresRecherchePersistSuccessAction {
  final CriteresRechercheUtilisateur criteres;

  CriteresRecherchePersistSuccessAction(this.criteres);
}
