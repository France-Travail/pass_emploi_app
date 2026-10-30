import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_actions.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_state.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/models/metier.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_donnees.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_modeles.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

// Les parcours repartent de « Ta recherche » (métier, ville, rayon) et la mettent à jour, comme les
// autres recherches de l'onglet Offres. Un métier tapé librement ne correspond à aucun code : il est ignoré.
class PocCriteresInitiaux {
  final PocMetier? metier;
  final Location? lieu;
  final int rayon;

  const PocCriteresInitiaux({required this.metier, required this.lieu, required this.rayon});

  factory PocCriteresInitiaux.depuis(Store<AppState> store) {
    final criteres = store.criteresRechercheUtilisateur;
    final metier = criteres.metier;
    final location = criteres.location;
    return PocCriteresInitiaux(
      metier: metier is MetierRomeCritere ? pocMetierParCode(metier.metier.codeRome) : null,
      lieu: location != null && location.type == LocationType.COMMUNE ? location : null,
      rayon: criteres.rayon ?? pocRayonParDefautKm,
    );
  }
}

void pocRetenirCriteres(Store<AppState> store, {PocMetier? metier, required Location lieu, int? rayon}) {
  final criteres = store.criteresRechercheUtilisateur.copyWith(
    metier: metier != null
        ? () => MetierRomeCritere(Metier(codeRome: metier.codeRome, libelle: metier.libelle))
        : null,
    location: () => lieu,
    rayon: rayon != null ? () => rayon : null,
  );
  store.dispatch(CriteresRecherchePersistSuccessAction(criteres));
  store.dispatch(CriteresRecherchePersistWriteAction(criteres));
}
