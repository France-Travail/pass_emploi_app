import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

class ActionPlanRequestMapper {
  const ActionPlanRequestMapper();

  Map<String, dynamic> toRequest(OnboardingQuestionnaireAnswers answers) {
    return {
      if (answers.dateNaissance != null) 'dateNaissance': _formatDate(answers.dateNaissance!),
      'situation': _mapSituation(answers.situation!),
      'goals': answers.objectifs.map(_mapObjectif).toList(),
      'domaine': _mapDomaine(answers),
      if (answers.habitation != null) 'habitation': _mapCommune(answers.habitation!),
      if (answers.villeRecherche != null) 'villeRecherche': _mapCommune(answers.villeRecherche!),
      if (answers.villeRecherche != null) 'rayonKm': answers.rayonKm,
      'obstacles': _mapFreins(answers.freins),
    };
  }

  static String? _mapDomaine(OnboardingQuestionnaireAnswers answers) {
    if (answers.domaineInconnu) return null;
    final domaine = answers.domaine?.trim();
    if (domaine == null || domaine.isEmpty) return null;
    return domaine;
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static Map<String, String> _mapCommune(QuestionnaireCommune commune) => {
    'codeInsee': commune.code,
    'nom': commune.nom,
  };

  static String _mapSituation(QuestionnaireSituation situation) => switch (situation) {
    QuestionnaireSituation.college => 'COLLEGE',
    QuestionnaireSituation.lycee => 'LYCEE',
    QuestionnaireSituation.etudesSuperieures => 'ETUDES_SUPERIEURES',
    QuestionnaireSituation.emploi => 'EMPLOI',
    QuestionnaireSituation.autre => 'AUTRE',
  };

  static String _mapObjectif(QuestionnaireObjectif objectif) => switch (objectif) {
    QuestionnaireObjectif.orienter => 'ORIENTER',
    QuestionnaireObjectif.decouvrirMetiers => 'DECOUVRIR_METIERS',
    QuestionnaireObjectif.former => 'FORMER',
    QuestionnaireObjectif.stageImmersion => 'STAGE_IMMERSION',
    QuestionnaireObjectif.alternance => 'ALTERNANCE',
    QuestionnaireObjectif.emploi => 'EMPLOI',
    QuestionnaireObjectif.engager => 'ENGAGER',
    QuestionnaireObjectif.mobiliteInternationale => 'MOBILITE_INTERNATIONALE',
    QuestionnaireObjectif.accompagne => 'ACCOMPAGNE',
    QuestionnaireObjectif.creerActivite => 'CREER_ACTIVITE',
    QuestionnaireObjectif.vieQuotidienne => 'VIE_QUOTIDIENNE',
  };

  static List<String> _mapFreins(Set<QuestionnaireFrein> freins) {
    if (freins.isEmpty) return [];
    if (freins.contains(QuestionnaireFrein.rienNeMeBloque)) return ['RIEN_NE_ME_BLOQUE'];
    return freins.map(_mapFrein).toList();
  }

  static String _mapFrein(QuestionnaireFrein frein) => switch (frein) {
    QuestionnaireFrein.pasDeTransport => 'PAS_DE_TRANSPORT',
    QuestionnaireFrein.pasDePermis => 'PAS_DE_PERMIS',
    QuestionnaireFrein.pasDeLogement => 'PAS_DE_LOGEMENT',
    QuestionnaireFrein.manqueConfiance => 'MANQUE_CONFIANCE',
    QuestionnaireFrein.finDeMois => 'FIN_DE_MOIS',
    QuestionnaireFrein.gardeEnfant => 'GARDE_ENFANT',
    QuestionnaireFrein.pasDeDiplome => 'PAS_DE_DIPLOME',
    QuestionnaireFrein.numerique => 'NUMERIQUE',
    QuestionnaireFrein.handicap => 'HANDICAP',
    QuestionnaireFrein.sante => 'SANTE',
    QuestionnaireFrein.peuExperience => 'PEU_EXPERIENCE',
    QuestionnaireFrein.francais => 'FRANCAIS',
    QuestionnaireFrein.autre => 'AUTRE',
    QuestionnaireFrein.rienNeMeBloque => 'RIEN_NE_ME_BLOQUE',
  };
}
