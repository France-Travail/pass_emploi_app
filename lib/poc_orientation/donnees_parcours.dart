import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/alerte/list/alerte_list_actions.dart';
import 'package:pass_emploi_app/features/alerte/list/alerte_list_state.dart';
import 'package:pass_emploi_app/features/favori/list/favori_list_actions.dart';
import 'package:pass_emploi_app/features/favori/list/favori_list_state.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/features/suggestions_recherche/list/suggestions_recherche_actions.dart';
import 'package:pass_emploi_app/features/suggestions_recherche/list/suggestions_recherche_state.dart';
import 'package:pass_emploi_app/poc_orientation/contexte_jeune.dart';
import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pistes_pour_toi.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

// Ce que le parcours lit hors du store : le parcours France Travail fictif et les chiffres de Lille (démo seulement,
// fichiers locaux, aucun appel réseau).
class DonneesParcours {
  const DonneesParcours({this.experiences = const [], this.marche});

  final List<ExperienceFranceTravail> experiences;
  final MarcheTravail? marche;
}

Future<DonneesParcours> chargerDonneesParcours(AppState state) async {
  final experiences = ParcoursFranceTravailDemo.concerne(state)
      ? await ParcoursFranceTravailDemo.charger()
      : const <ExperienceFranceTravail>[];
  final marche = state.demoState ? await MarcheTravailDemo.charger() : null;
  return DonneesParcours(experiences: experiences, marche: marche);
}

// Favoris, recherches et suggestions : chargés comme le font leurs écrans (en démo, depuis les fichiers locaux).
void demanderLesDonneesDuJeune(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    final store = StoreProvider.of<AppState>(context, listen: false);
    if (store.state.favoriListState is! FavoriListSuccessState) store.dispatch(FavoriListRequestAction());
    if (store.state.alerteListState is! AlerteListSuccessState) store.dispatch(AlerteListRequestAction());
    if (store.state.suggestionsRechercheState is! SuggestionsRechercheSuccessState) {
      store.dispatch(SuggestionsRechercheRequestAction());
    }
  });
}

// Tant que favoris, recherches ou suggestions arrivent, l'accueil attend : sinon il montrerait une étape, puis une autre.
bool donneesDuJeuneEnChargement(AppState state) {
  return state.favoriListState is FavoriListLoadingState ||
      state.alerteListState is AlerteListLoadingState ||
      state.suggestionsRechercheState is SuggestionsRechercheLoadingState;
}

// La liste à trier, « Des métiers pour toi ».
List<PisteProposee> metiersATrier(AppState state, MesPistesEtat etat, DonneesParcours? donnees) {
  final contexte = ContexteJeune.depuis(state, experiencesFranceTravail: donnees?.experiences ?? const []);
  return proposerDesPistes(contexte, etat, marche: donnees?.marche);
}

// Les chiffres de la démo valent pour Lille : on ne les montre pas à un jeune qui cherche ailleurs.
MarcheTravail? marchePourLeJeune(AppState state, MarcheTravail? marche) {
  if (marche == null) return null;
  final commune = communeDuJeune(state);
  return commune == null || commune == marche.codeInseeVille ? marche : null;
}

// Code Insee de la ville de recherche du questionnaire, ou de la ville où il habite.
String? communeDuJeune(AppState state) {
  final questionnaire = state.onboardingQuestionnaireState;
  final reponses = questionnaire is OnboardingQuestionnaireSuccessState ? questionnaire.answers : null;
  return (reponses?.villeRecherche ?? reponses?.habitation)?.code;
}
