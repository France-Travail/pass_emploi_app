import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_actions.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_state.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/metier.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_emploi_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_immersion_page.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';

const _accompagnementsAvecAlternance = [Accompagnement.cej, Accompagnement.aij, Accompagnement.avenirPro];

// Recharge les pistes quand le compte a changé (ou repart de zéro en démo).
void ouvrirMesPistes(BuildContext context) {
  final state = StoreProvider.of<AppState>(context, listen: false).state;
  MesPistes.instance.ouvrirSession(jeune: state.userId(), demo: state.demoState);
}

bool peutPartagerAuConseiller(BuildContext context) => StoreProvider.of<AppState>(context).state.hasChat();

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

// Parcoursmétiers.tv range ses vidéos sous l'intitulé ROME, mais sa recherche ne trouve pas la forme double
// « Boulanger / Boulangère » : on cherche la forme simple. Certains intitulés longs ne trouvent aucune vidéo.
String lienVideosMetier(RomeFicheMetier fiche) {
  return 'https://parcoursmetiers.tv/recherche?q=${Uri.encodeComponent(fiche.motCle)}';
}

// My Job Glasses demande un compte (gratuit, connexion possible avec France Travail), puis revient sur la recherche.
String lienEchangerAvecUnPro(RomeFicheMetier fiche) {
  return 'https://app.myjobglasses.com/search?q=${Uri.encodeComponent(fiche.motCle)}';
}

// Les pages de recherche préremplissent le métier depuis les critères de l'utilisateur.
void _retenirMetier(BuildContext context, RomeFicheMetier fiche) {
  final store = StoreProvider.of<AppState>(context);
  final criteres = store.criteresRechercheUtilisateur.copyWith(
    metier: () => MetierRomeCritere(Metier(codeRome: fiche.code, libelle: fiche.motCle)),
  );
  store.dispatch(CriteresRecherchePersistSuccessAction(criteres));
  store.dispatch(CriteresRecherchePersistWriteAction(criteres));
}
