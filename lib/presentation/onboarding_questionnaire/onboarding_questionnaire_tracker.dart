import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';

enum OnboardingQuestionnaireEntryPoint {
  accueilIncomplet("Accueil - carte questionnaire incomplet"),
  accueilPartiel("Accueil - carte questionnaire partiel"),
  planVideModifier("Accueil - Modifier du plan vide"),
  accueilModifier("Accueil - Modifier en bas de page"),
  profil("Profil - Modifier mes informations");

  final String label;

  const OnboardingQuestionnaireEntryPoint(this.label);
}

enum OnboardingQuestionnaireGeolocationFailure {
  permissionRefusee("Permission refusée"),
  serviceDesactive("Service désactivé"),
  positionIntrouvable("Position introuvable"),
  aucuneCommune("Aucune commune correspondante");

  final String label;

  const OnboardingQuestionnaireGeolocationFailure(this.label);
}

enum OnboardingQuestionnaireGenerationOutcome {
  planGenere("Plan généré"),
  planVide("Plan vide"),
  echec("Génération échouée"),
  impossible("Génération impossible");

  final String label;

  const OnboardingQuestionnaireGenerationOutcome(this.label);
}

/// First pass and update are two separate funnels (category and screen path).
/// Only closed-list values and counters are sent: never the prénom, the commune name nor the domaine typed.
class OnboardingQuestionnaireTracker {
  final bool isUpdate;

  const OnboardingQuestionnaireTracker({required this.isUpdate});

  String get category =>
      isUpdate ? AnalyticsEventNames.questionnaireUpdateCategory : AnalyticsEventNames.questionnaireFirstPassCategory;

  void trackStepScreen(OnboardingQuestionnaireStep step) {
    trackScreen('/questionnaire/${isUpdate ? 'mise-a-jour' : 'premier-passage'}/${step.trackingSlug}');
  }

  void trackStepEvent(String action, OnboardingQuestionnaireStep step) {
    trackEvent(action, name: step.trackingLabel, value: step.questionnaireIndex);
  }

  void trackOpening(OnboardingQuestionnaireEntryPoint entryPoint) {
    trackEvent(AnalyticsEventNames.questionnaireOpenedAction, name: entryPoint.label);
  }

  void trackGenerationOutcome(OnboardingQuestionnaireGenerationOutcome outcome, {int? objectivesCount}) {
    trackEvent(AnalyticsEventNames.questionnaireGenerationOutcomeAction, name: outcome.label, value: objectivesCount);
  }

  void trackScreen(String name) => PassEmploiMatomoTracker.instance.trackScreen(name);

  void trackEvent(String action, {String? name, int? value}) {
    PassEmploiMatomoTracker.instance.trackEvent(
      eventCategory: category,
      action: action,
      eventName: name,
      eventValue: value,
    );
  }
}

extension OnboardingQuestionnaireStepTracking on OnboardingQuestionnaireStep {
  String get trackingLabel => switch (this) {
    OnboardingQuestionnaireStep.prenom => "Étape 1 - Prénom",
    OnboardingQuestionnaireStep.dateNaissance => "Étape 2 - Date de naissance",
    OnboardingQuestionnaireStep.habitation => "Étape 3 - Habitation",
    OnboardingQuestionnaireStep.situation => "Étape 4 - Situation",
    OnboardingQuestionnaireStep.objectifs => "Étape 5 - Objectifs",
    OnboardingQuestionnaireStep.domaine => "Étape 6 - Domaine",
    OnboardingQuestionnaireStep.villeRecherche => "Étape 7 - Zone de recherche",
    OnboardingQuestionnaireStep.freins => "Étape 8 - Freins",
    OnboardingQuestionnaireStep.loader => "Génération du plan",
  };

  String get trackingSlug => switch (this) {
    OnboardingQuestionnaireStep.prenom => "etape-1-prenom",
    OnboardingQuestionnaireStep.dateNaissance => "etape-2-date-de-naissance",
    OnboardingQuestionnaireStep.habitation => "etape-3-habitation",
    OnboardingQuestionnaireStep.situation => "etape-4-situation",
    OnboardingQuestionnaireStep.objectifs => "etape-5-objectifs",
    OnboardingQuestionnaireStep.domaine => "etape-6-domaine",
    OnboardingQuestionnaireStep.villeRecherche => "etape-7-zone-de-recherche",
    OnboardingQuestionnaireStep.freins => "etape-8-freins",
    OnboardingQuestionnaireStep.loader => "generation-du-plan",
  };
}
