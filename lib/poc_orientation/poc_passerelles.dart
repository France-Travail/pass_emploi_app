import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_actions.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_state.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/metier.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_emploi_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_immersion_page.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';

const _accompagnementsAvecAlternance = [Accompagnement.cej, Accompagnement.aij, Accompagnement.avenirPro];

bool peutChercherAlternance(BuildContext context) {
  return _accompagnementsAvecAlternance.contains(StoreProvider.of<AppState>(context).state.accompagnement());
}

void ouvrirRechercheOffres(BuildContext context, RomeFicheMetier fiche, {required bool alternance}) {
  _retenirMetier(context, fiche);
  Navigator.of(context).push(RechercheOffreEmploiPage.materialPageRoute(onlyAlternance: alternance));
}

void ouvrirRechercheImmersion(BuildContext context, RomeFicheMetier fiche) {
  _retenirMetier(context, fiche);
  Navigator.of(context).push(RechercheOffreImmersionPage.materialPageRoute());
}

void ouvrirFormationsAlternance(RomeFicheMetier fiche) {
  launchExternalUrl('https://labonnealternance.apprentissage.beta.gouv.fr/recherche?romes=${fiche.code}');
}

void ouvrirFormationsFranceTravail(RomeFicheMetier fiche) {
  launchExternalUrl('https://candidat.francetravail.fr/formations/recherche?quoi=${fiche.code}');
}

void ouvrirFormationsOnisep() => launchExternalUrl('https://www.onisep.fr/recherche/formations');

// Les pages de recherche préremplissent le métier depuis les critères de l'utilisateur.
void _retenirMetier(BuildContext context, RomeFicheMetier fiche) {
  final store = StoreProvider.of<AppState>(context);
  final criteres = store.criteresRechercheUtilisateur.copyWith(
    metier: () => MetierRomeCritere(Metier(codeRome: fiche.code, libelle: fiche.motCle)),
  );
  store.dispatch(CriteresRecherchePersistSuccessAction(criteres));
  store.dispatch(CriteresRecherchePersistWriteAction(criteres));
}
