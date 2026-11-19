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

const nomRouteExplorerMetiers = '/poc_orientation/explorer_metiers';

// Après le tri, retour à l'accueil « Explorer les métiers » (ou au premier écran, s'il n'est pas ouvert).
void revenirAExplorerMetiers(NavigatorState navigateur) {
  navigateur.popUntil((route) => route.settings.name == nomRouteExplorerMetiers || route.isFirst);
}

// Recharge les pistes quand le compte a changé (ou repart de zéro en démo).
void ouvrirMesPistes(BuildContext context) {
  final state = StoreProvider.of<AppState>(context, listen: false).state;
  MesPistes.instance.ouvrirSession(jeune: state.userId(), demo: state.demoState);
}

bool peutPartagerAuConseiller(BuildContext context) => StoreProvider.of<AppState>(context).state.hasChat();

bool peutChercherAlternance(BuildContext context) {
  return _accompagnementsAvecAlternance.contains(StoreProvider.of<AppState>(context).state.accompagnement());
}

void ouvrirRechercheOffres(BuildContext context, RomeMetierResume metier, {required bool alternance}) {
  _retenirMetier(context, metier);
  Navigator.of(context).push(RechercheOffreEmploiPage.materialPageRoute(onlyAlternance: alternance));
}

void ouvrirRechercheImmersion(BuildContext context, RomeMetierResume metier) {
  _retenirMetier(context, metier);
  Navigator.of(context).push(RechercheOffreImmersionPage.materialPageRoute());
}

void ouvrirFormationsAlternance(RomeMetierResume metier) {
  launchExternalUrl('https://labonnealternance.apprentissage.beta.gouv.fr/recherche?romes=${metier.code}');
}

void ouvrirFormationsFranceTravail(RomeMetierResume metier) {
  launchExternalUrl('https://candidat.francetravail.fr/formations/recherche?quoi=${metier.code}');
}

void ouvrirFormationsOnisep() => launchExternalUrl('https://www.onisep.fr/recherche/formations');

// Parcoursmétiers.tv range ses vidéos sous l'intitulé ROME, mais sa recherche ne trouve pas la forme double
// « Boulanger / Boulangère » : on cherche la forme simple. Certains intitulés longs ne trouvent aucune vidéo.
String lienVideosMetier(RomeMetierResume metier) {
  return 'https://parcoursmetiers.tv/recherche?q=${Uri.encodeComponent(motCleDuMetier(metier.libelle))}';
}

// My Job Glasses demande un compte (gratuit, connexion possible avec France Travail), puis revient sur la recherche.
String lienEchangerAvecUnPro(RomeMetierResume metier) {
  return 'https://app.myjobglasses.com/search?q=${Uri.encodeComponent(motCleDuMetier(metier.libelle))}';
}

// Les pages de recherche préremplissent le métier depuis les critères de l'utilisateur.
void _retenirMetier(BuildContext context, RomeMetierResume metier) {
  final store = StoreProvider.of<AppState>(context);
  final criteres = store.criteresRechercheUtilisateur.copyWith(
    metier: () => MetierRomeCritere(Metier(codeRome: metier.code, libelle: motCleDuMetier(metier.libelle))),
  );
  store.dispatch(CriteresRecherchePersistSuccessAction(criteres));
  store.dispatch(CriteresRecherchePersistWriteAction(criteres));
}
