import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

class BayesImpactProfileMapper {
  const BayesImpactProfileMapper();

  Map<String, dynamic> toProfile(OnboardingQuestionnaireAnswers answers) {
    final profile = <String, dynamic>{
      'authProvider': 'guest',
      'situation': _mapSituation(answers.situation!),
      'goals': answers.objectifs.map(_mapObjectif).whereType<String>().toList(),
      'obstacles': _mapFreins(answers.freins),
    };

    final prenom = answers.prenom?.trim();
    if (prenom != null && prenom.isNotEmpty) {
      profile['firstName'] = prenom;
    }

    final age = _ageFromBirthDate(answers.dateNaissance);
    if (age != null) {
      profile['age'] = age;
    }

    if (answers.domaineInconnu) {
      profile['domain'] = null;
    } else if (answers.domaine != null && answers.domaine!.trim().isNotEmpty) {
      profile['domain'] = answers.domaine!.trim();
    }

    final location = _mapLocation(answers);
    if (location != null) {
      profile['location'] = location;
    }

    return profile;
  }

  static String _mapSituation(QuestionnaireSituation situation) => switch (situation) {
        QuestionnaireSituation.college => 'middle-school',
        QuestionnaireSituation.lycee => 'high-school',
        QuestionnaireSituation.etudesSuperieures => 'higher-education',
        QuestionnaireSituation.emploi => 'employed',
        QuestionnaireSituation.autre => 'other',
      };

  static String? _mapObjectif(QuestionnaireObjectif objectif) => switch (objectif) {
        QuestionnaireObjectif.orienter => 'orientation',
        QuestionnaireObjectif.former => 'training',
        QuestionnaireObjectif.emploi => 'job',
        QuestionnaireObjectif.alternance => 'apprenticeship',
        QuestionnaireObjectif.stageImmersion => 'internship-immersion',
        QuestionnaireObjectif.decouvrirMetiers => 'discover-jobs',
        QuestionnaireObjectif.engager => 'civic-engagement',
        QuestionnaireObjectif.mobiliteInternationale => 'international-mobility',
        QuestionnaireObjectif.accompagne => 'guidance-support',
        QuestionnaireObjectif.creerActivite => 'start-business',
        QuestionnaireObjectif.vieQuotidienne => 'dont-know',
      };

  static List<String> _mapFreins(Set<QuestionnaireFrein> freins) {
    if (freins.contains(QuestionnaireFrein.rienNeMeBloque) || freins.isEmpty) return [];
    final mapped = <String>{};
    for (final frein in freins) {
      final value = switch (frein) {
        QuestionnaireFrein.pasDePermis => 'transport',
        QuestionnaireFrein.pasDeTransport => 'transport',
        QuestionnaireFrein.pasDeLogement => 'housing',
        QuestionnaireFrein.manqueConfiance => 'confidence',
        QuestionnaireFrein.finDeMois => 'money',
        QuestionnaireFrein.gardeEnfant => 'childcare',
        QuestionnaireFrein.pasDeDiplome => 'no-diploma',
        QuestionnaireFrein.numerique => 'no-device',
        QuestionnaireFrein.handicap => 'disability',
        QuestionnaireFrein.sante => 'health',
        QuestionnaireFrein.peuExperience || QuestionnaireFrein.francais || QuestionnaireFrein.autre || QuestionnaireFrein.rienNeMeBloque => null,
      };
      if (value != null) mapped.add(value);
    }
    return mapped.toList();
  }

  static int? _ageFromBirthDate(DateTime? birthDate) {
    if (birthDate == null) return null;
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final hadBirthday = now.month > birthDate.month || (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hadBirthday) age--;
    if (age < 14 || age > 30) return null;
    return age;
  }

  static Map<String, dynamic>? _mapLocation(OnboardingQuestionnaireAnswers answers) {
    final commune = answers.villeRecherche;
    if (commune == null) return null;
    return {
      'city': commune.nom,
      'radiusKm': answers.rayonKm,
      if (_departmentCode(commune.code) != null) 'territory': _departmentCode(commune.code),
    };
  }

  static String? _departmentCode(String inseeCode) {
    if (inseeCode.length < 2) return null;
    if (inseeCode.startsWith('97') || inseeCode.startsWith('98')) {
      return inseeCode.length >= 3 ? inseeCode.substring(0, 3) : null;
    }
    return inseeCode.substring(0, 2);
  }
}
