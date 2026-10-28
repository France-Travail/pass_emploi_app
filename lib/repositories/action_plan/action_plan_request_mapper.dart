import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

class ActionPlanRequestMapper {
  const ActionPlanRequestMapper();

  Map<String, dynamic> toRequest(OnboardingQuestionnaireAnswers answers) {
    final precisionAutre = _mapPrecisionAutre(answers);
    return {
      if (answers.dateNaissance != null) 'dateNaissance': _formatDate(answers.dateNaissance!),
      'situation': _mapSituation(answers.situation!),
      if (precisionAutre != null) 'precisionAutre': precisionAutre,
      'goals': answers.objectifs.map(_mapObjectif).toList(),
      'domaine': _mapDomaine(answers),
      if (answers.habitation != null) 'habitation': _mapCommune(answers.habitation!),
      if (answers.villeRecherche != null) 'villeRecherche': _mapCommune(answers.villeRecherche!),
      if (answers.villeRecherche != null) 'rayonKm': answers.rayonKm,
      'obstacles': _mapFreins(answers.freins),
    };
  }

  /// Reporte sur [local] les réponses du GET /jeunes/:id/questionnaire. L'API ne connaît pas le prénom : la réponse
  /// locale est conservée. « Je ne sais pas » au domaine n'est pas enregistré côté serveur : il revient non répondu.
  OnboardingQuestionnaireAnswers fromQuestionnaireResponse(
    Map<String, dynamic> json,
    OnboardingQuestionnaireAnswers local,
  ) {
    final situation = QuestionnaireSituation.values.where((e) => _mapSituation(e) == json['situation']).firstOrNull;
    final precisionAutre = situation == QuestionnaireSituation.autre ? _nonEmpty(json['precisionAutre']) : null;
    final goals = json['goals'];
    final obstacles = json['obstacles'];
    final dateNaissance = json['dateNaissance'] is String ? DateTime.tryParse(json['dateNaissance'] as String) : null;
    final habitation = _parseCommune(json['habitation']);
    final villeRecherche = _parseCommune(json['villeRecherche']);
    final domaine = json['domaine'] as String?;
    return local.copyWith(
      dateNaissance: dateNaissance,
      clearDateNaissance: dateNaissance == null,
      habitation: habitation,
      clearHabitation: habitation == null,
      situation: situation,
      clearSituation: situation == null,
      situationAutre: precisionAutre,
      clearSituationAutre: precisionAutre == null,
      objectifs: goals is List
          ? QuestionnaireObjectif.values.where((e) => goals.contains(_mapObjectif(e))).toSet()
          : <QuestionnaireObjectif>{},
      domaine: domaine,
      clearDomaine: domaine == null,
      domaineInconnu: false,
      villeRecherche: villeRecherche,
      clearVilleRecherche: villeRecherche == null,
      rayonKm: (json['rayonKm'] as num?)?.toInt(),
      freins: obstacles is List
          ? QuestionnaireFrein.values.where((e) => obstacles.contains(_mapFrein(e))).toSet()
          : <QuestionnaireFrein>{},
    );
  }

  static QuestionnaireCommune? _parseCommune(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final code = json['codeInsee'];
    final nom = json['nom'];
    if (code is! String || nom is! String) return null;
    return QuestionnaireCommune(code: code, nom: nom);
  }

  // La précision n'a de sens qu'avec la situation « Autre ».
  static String? _mapPrecisionAutre(OnboardingQuestionnaireAnswers answers) {
    if (answers.situation != QuestionnaireSituation.autre) return null;
    return _nonEmpty(answers.situationAutre);
  }

  static String? _nonEmpty(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
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
    QuestionnaireFrein.rienNeMeBloque => 'RIEN_NE_ME_BLOQUE',
  };
}
