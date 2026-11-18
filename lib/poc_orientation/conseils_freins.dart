import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

// Conseils tirés des freins déclarés au questionnaire du plan, rangés sous l'étape de la fiche où ils servent.
List<String> conseilsPourEtape(
  EtapePiste etape,
  OnboardingQuestionnaireAnswers? reponses, {
  required bool sansDiplome,
}) {
  if (reponses == null) return const [];
  final freins = reponses.freins;
  return switch (etape) {
    EtapePiste.decouvrir => [
      if (freins.contains(QuestionnaireFrein.sante) || freins.contains(QuestionnaireFrein.handicap))
        PocOrientationStrings.conseilSante,
    ],
    EtapePiste.tester => [
      if (freins.contains(QuestionnaireFrein.pasDePermis) || freins.contains(QuestionnaireFrein.pasDeTransport))
        PocOrientationStrings.conseilTransport(
          reponses.villeRecherche?.nom ?? reponses.habitation?.nom,
          reponses.rayonKm,
        ),
      if (freins.contains(QuestionnaireFrein.peuExperience)) PocOrientationStrings.conseilExperience,
      if (freins.contains(QuestionnaireFrein.manqueConfiance)) PocOrientationStrings.conseilConfiance,
    ],
    EtapePiste.seFormer => [
      if (freins.contains(QuestionnaireFrein.finDeMois)) PocOrientationStrings.conseilFinDeMois,
      if (freins.contains(QuestionnaireFrein.pasDeDiplome))
        sansDiplome ? PocOrientationStrings.conseilSansDiplome : PocOrientationStrings.conseilFormationCourte,
    ],
  };
}

// La rubrique « accès » de la fiche ROME le dit quand le métier est ouvert sans diplôme.
bool accessibleSansDiplome(RomeFicheMetier fiche) {
  return RegExp(r'sans (aucun )?dipl[oô]me', caseSensitive: false).hasMatch(fiche.acces.join(' '));
}
