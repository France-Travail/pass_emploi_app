import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pass_emploi_app/features/alerte/list/alerte_list_state.dart';
import 'package:pass_emploi_app/features/favori/list/favori_list_state.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/features/suggestions_recherche/list/suggestions_recherche_state.dart';
import 'package:pass_emploi_app/models/alerte/alerte.dart';
import 'package:pass_emploi_app/models/favori.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/models/suggestion_recherche.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

class ExperienceFranceTravail {
  const ExperienceFranceTravail({
    required this.intitule,
    required this.codeRome,
    required this.libelleRome,
    this.dureeMois,
  });

  final String intitule;
  final String codeRome;
  final String libelleRome;
  final int? dureeMois;

  factory ExperienceFranceTravail.fromJson(dynamic json) {
    return ExperienceFranceTravail(
      intitule: json['intitule'] as String,
      codeRome: json['codeRome'] as String,
      libelleRome: json['libelleRome'] as String,
      dureeMois: json['dureeMois'] as int?,
    );
  }
}

// Ce que l'app sait déjà du jeune : ses réponses au questionnaire du plan, ses favoris, ses recherches enregistrées,
// les suggestions déjà en base (conseiller, métiers déclarés à France Travail, Diagoriente) et, pour un jeune France
// Travail, son parcours (simulé en démo : en vrai, API « Expériences professionnelles » avec son accord).
class ContexteJeune {
  const ContexteJeune({
    this.questionnaire,
    this.favoris = const [],
    this.alertes = const [],
    this.suggestions = const [],
    this.experiencesFranceTravail = const [],
  });

  final OnboardingQuestionnaireAnswers? questionnaire;
  final List<Favori> favoris;
  final List<Alerte> alertes;
  final List<SuggestionRecherche> suggestions;
  final List<ExperienceFranceTravail> experiencesFranceTravail;

  factory ContexteJeune.depuis(AppState state, {List<ExperienceFranceTravail> experiencesFranceTravail = const []}) {
    final questionnaire = state.onboardingQuestionnaireState;
    final favoris = state.favoriListState;
    final alertes = state.alerteListState;
    final suggestions = state.suggestionsRechercheState;
    return ContexteJeune(
      questionnaire: questionnaire is OnboardingQuestionnaireSuccessState ? questionnaire.answers : null,
      favoris: favoris is FavoriListSuccessState ? favoris.results : const [],
      alertes: alertes is AlerteListSuccessState ? alertes.alertes : const [],
      suggestions: suggestions is SuggestionsRechercheSuccessState ? suggestions.suggestions : const [],
      experiencesFranceTravail: experiencesFranceTravail,
    );
  }

  Set<QuestionnaireFrein> get freins => questionnaire?.freins ?? const {};

  bool get neSaitPasEncore => questionnaire?.domaineInconnu ?? false;
}

// Parcours France Travail fictif de la démo France Travail (fichier local, aucun appel réseau).
class ParcoursFranceTravailDemo {
  static bool concerne(AppState state) => state.demoState && state.user()?.loginMode == LoginMode.DEMO_PE;

  static Future<List<ExperienceFranceTravail>> charger() {
    // rootBundle garde déjà le fichier en mémoire après la première lecture.
    return rootBundle
        .loadString('assets/mode_demo/poc_orientation_profil_ft.json')
        .then(
          (texte) => [
            for (final experience in (jsonDecode(texte)['experiences'] as List))
              ExperienceFranceTravail.fromJson(experience),
          ],
        );
  }
}
