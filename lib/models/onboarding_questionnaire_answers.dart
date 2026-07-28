import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class QuestionnaireCommune extends Equatable {
  final String code;
  final String nom;
  final String? codePostal;
  final double? latitude;
  final double? longitude;

  const QuestionnaireCommune({
    required this.code,
    required this.nom,
    this.codePostal,
    this.latitude,
    this.longitude,
  });

  String get displayLabel {
    if (codePostal == null || codePostal!.isEmpty) return nom;
    return '$nom ($codePostal)';
  }

  factory QuestionnaireCommune.fromJson(Map<String, dynamic> json, {String? preferredCodePostal}) {
    final codesPostaux = json['codesPostaux'];
    String? codePostal;
    if (codesPostaux is List && codesPostaux.isNotEmpty) {
      final codes = codesPostaux.map((e) => e.toString()).toList();
      if (preferredCodePostal != null && codes.contains(preferredCodePostal)) {
        codePostal = preferredCodePostal;
      } else {
        codePostal = codes.first;
      }
    }
    final centre = json['centre'];
    double? latitude;
    double? longitude;
    if (centre is Map<String, dynamic>) {
      final coordinates = centre['coordinates'];
      if (coordinates is List && coordinates.length >= 2) {
        longitude = (coordinates[0] as num?)?.toDouble();
        latitude = (coordinates[1] as num?)?.toDouble();
      }
    }
    return QuestionnaireCommune(
      code: json['code'] as String,
      nom: json['nom'] as String,
      codePostal: codePostal,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'nom': nom,
        if (codePostal != null) 'codePostal': codePostal,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

  factory QuestionnaireCommune.fromStorageJson(Map<String, dynamic> json) {
    return QuestionnaireCommune(
      code: json['code'] as String,
      nom: json['nom'] as String,
      codePostal: json['codePostal'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [code, nom, codePostal, latitude, longitude];
}

enum QuestionnaireSituation {
  college,
  lycee,
  etudesSuperieures,
  emploi,
  autre;

  String get label => switch (this) {
        QuestionnaireSituation.college => Strings.onboardingQuestionnaireSituationCollege,
        QuestionnaireSituation.lycee => Strings.onboardingQuestionnaireSituationLycee,
        QuestionnaireSituation.etudesSuperieures => Strings.onboardingQuestionnaireSituationEtudes,
        QuestionnaireSituation.emploi => Strings.onboardingQuestionnaireSituationEmploi,
        QuestionnaireSituation.autre => Strings.onboardingQuestionnaireSituationAutre,
      };

  String get emoji => switch (this) {
        QuestionnaireSituation.college => '📚',
        QuestionnaireSituation.lycee => '🎓',
        QuestionnaireSituation.etudesSuperieures => '🏫',
        QuestionnaireSituation.emploi => '💼',
        QuestionnaireSituation.autre => '✨',
      };

  Color get illustrationColor => switch (this) {
        QuestionnaireSituation.college => DsfrColors.purpleGlycine950,
        QuestionnaireSituation.lycee => DsfrColors.blueCumulus950,
        QuestionnaireSituation.etudesSuperieures => DsfrColors.greenTilleulVerveine950,
        QuestionnaireSituation.emploi => DsfrColors.pinkTuile925,
        QuestionnaireSituation.autre => DsfrColors.greenEmeraude950,
      };

  String get storageValue => name;

  static QuestionnaireSituation? fromStorage(String? value) {
    if (value == null) return null;
    for (final situation in QuestionnaireSituation.values) {
      if (situation.storageValue == value) return situation;
    }
    return null;
  }
}

enum QuestionnaireObjectif {
  orienter,
  decouvrirMetiers,
  former,
  stageImmersion,
  alternance,
  emploi,
  engager,
  mobiliteInternationale,
  accompagne,
  creerActivite,
  vieQuotidienne;

  String get label => switch (this) {
        QuestionnaireObjectif.orienter => Strings.onboardingQuestionnaireObjectifOrienter,
        QuestionnaireObjectif.decouvrirMetiers => Strings.onboardingQuestionnaireObjectifDecouvrirMetiers,
        QuestionnaireObjectif.former => Strings.onboardingQuestionnaireObjectifFormer,
        QuestionnaireObjectif.stageImmersion => Strings.onboardingQuestionnaireObjectifStage,
        QuestionnaireObjectif.alternance => Strings.onboardingQuestionnaireObjectifAlternance,
        QuestionnaireObjectif.emploi => Strings.onboardingQuestionnaireObjectifEmploi,
        QuestionnaireObjectif.engager => Strings.onboardingQuestionnaireObjectifEngager,
        QuestionnaireObjectif.mobiliteInternationale => Strings.onboardingQuestionnaireObjectifMobilite,
        QuestionnaireObjectif.accompagne => Strings.onboardingQuestionnaireObjectifAccompagne,
        QuestionnaireObjectif.creerActivite => Strings.onboardingQuestionnaireObjectifCreerActivite,
        QuestionnaireObjectif.vieQuotidienne => Strings.onboardingQuestionnaireObjectifVieQuotidienne,
      };

  String get emoji => switch (this) {
        QuestionnaireObjectif.orienter => '🧭',
        QuestionnaireObjectif.decouvrirMetiers => '🔎',
        QuestionnaireObjectif.former => '📚',
        QuestionnaireObjectif.stageImmersion => '👀',
        QuestionnaireObjectif.alternance => '🔧',
        QuestionnaireObjectif.emploi => '💼',
        QuestionnaireObjectif.engager => '🤝',
        QuestionnaireObjectif.mobiliteInternationale => '✈️',
        QuestionnaireObjectif.accompagne => '🩹',
        QuestionnaireObjectif.creerActivite => '🚀',
        QuestionnaireObjectif.vieQuotidienne => '🍿',
      };

  Color get illustrationColor => switch (this) {
        QuestionnaireObjectif.orienter => DsfrColors.pinkTuile950,
        QuestionnaireObjectif.decouvrirMetiers => DsfrColors.greenTilleulVerveine950,
        QuestionnaireObjectif.former => DsfrColors.purpleGlycine950,
        QuestionnaireObjectif.stageImmersion => DsfrColors.blueCumulus950,
        QuestionnaireObjectif.alternance => DsfrColors.blueFrance925,
        QuestionnaireObjectif.emploi => DsfrColors.greenEmeraude950,
        QuestionnaireObjectif.engager => DsfrColors.greenTilleulVerveine925,
        QuestionnaireObjectif.mobiliteInternationale => DsfrColors.purpleGlycine925,
        QuestionnaireObjectif.accompagne => DsfrColors.pinkTuile925,
        QuestionnaireObjectif.creerActivite => DsfrColors.greenEmeraude925,
        QuestionnaireObjectif.vieQuotidienne => DsfrColors.pinkTuile950,
      };

  String get storageValue => name;

  static QuestionnaireObjectif? fromStorage(String value) {
    for (final objectif in QuestionnaireObjectif.values) {
      if (objectif.storageValue == value) return objectif;
    }
    return null;
  }
}

enum QuestionnaireFrein {
  pasDePermis,
  pasDeTransport,
  pasDeLogement,
  manqueConfiance,
  finDeMois,
  pasDeDiplome,
  peuExperience,
  handicap,
  sante,
  gardeEnfant,
  numerique,
  francais,
  autre,
  rienNeMeBloque;

  String get label => switch (this) {
        QuestionnaireFrein.pasDePermis => Strings.onboardingQuestionnaireFreinPasDePermis,
        QuestionnaireFrein.pasDeTransport => Strings.onboardingQuestionnaireFreinPasDeTransport,
        QuestionnaireFrein.pasDeLogement => Strings.onboardingQuestionnaireFreinPasDeLogement,
        QuestionnaireFrein.manqueConfiance => Strings.onboardingQuestionnaireFreinManqueConfiance,
        QuestionnaireFrein.finDeMois => Strings.onboardingQuestionnaireFreinFinDeMois,
        QuestionnaireFrein.pasDeDiplome => Strings.onboardingQuestionnaireFreinPasDeDiplome,
        QuestionnaireFrein.peuExperience => Strings.onboardingQuestionnaireFreinPeuExperience,
        QuestionnaireFrein.handicap => Strings.onboardingQuestionnaireFreinHandicap,
        QuestionnaireFrein.sante => Strings.onboardingQuestionnaireFreinSante,
        QuestionnaireFrein.gardeEnfant => Strings.onboardingQuestionnaireFreinGardeEnfant,
        QuestionnaireFrein.numerique => Strings.onboardingQuestionnaireFreinNumerique,
        QuestionnaireFrein.francais => Strings.onboardingQuestionnaireFreinFrancais,
        QuestionnaireFrein.autre => Strings.onboardingQuestionnaireFreinAutre,
        QuestionnaireFrein.rienNeMeBloque => Strings.onboardingQuestionnaireFreinRienNeMeBloque,
      };

  String get emoji => switch (this) {
        QuestionnaireFrein.pasDePermis => '🚗',
        QuestionnaireFrein.pasDeTransport => '🚌',
        QuestionnaireFrein.pasDeLogement => '🏠',
        QuestionnaireFrein.manqueConfiance => '😟',
        QuestionnaireFrein.finDeMois => '💶',
        QuestionnaireFrein.pasDeDiplome => '🎓',
        QuestionnaireFrein.peuExperience => '💼',
        QuestionnaireFrein.handicap => '♿',
        QuestionnaireFrein.sante => '🩺',
        QuestionnaireFrein.gardeEnfant => '👶',
        QuestionnaireFrein.numerique => '💻',
        QuestionnaireFrein.francais => '🗣️',
        QuestionnaireFrein.autre => '✅',
        QuestionnaireFrein.rienNeMeBloque => '✨',
      };

  Color get illustrationColor => switch (this) {
        QuestionnaireFrein.pasDePermis => DsfrColors.greenTilleulVerveine950,
        QuestionnaireFrein.pasDeTransport => DsfrColors.blueFrance925,
        QuestionnaireFrein.pasDeLogement => DsfrColors.greenEmeraude950,
        QuestionnaireFrein.manqueConfiance => DsfrColors.pinkTuile950,
        QuestionnaireFrein.finDeMois => DsfrColors.greenTilleulVerveine925,
        QuestionnaireFrein.pasDeDiplome => DsfrColors.blueFrance925,
        QuestionnaireFrein.peuExperience => DsfrColors.greenEmeraude925,
        QuestionnaireFrein.handicap => DsfrColors.blueCumulus950,
        QuestionnaireFrein.sante => DsfrColors.purpleGlycine950,
        QuestionnaireFrein.gardeEnfant => DsfrColors.pinkTuile925,
        QuestionnaireFrein.numerique => DsfrColors.greenTilleulVerveine950,
        QuestionnaireFrein.francais => DsfrColors.greenEmeraude950,
        QuestionnaireFrein.autre => DsfrColors.purpleGlycine950,
        QuestionnaireFrein.rienNeMeBloque => DsfrColors.greenEmeraude950,
      };

  bool get isExclusive => this == QuestionnaireFrein.rienNeMeBloque;

  String get storageValue => name;

  static QuestionnaireFrein? fromStorage(String value) {
    for (final frein in QuestionnaireFrein.values) {
      if (frein.storageValue == value) return frein;
    }
    return null;
  }
}

class OnboardingQuestionnaireAnswers extends Equatable {
  final String? prenom;
  final DateTime? dateNaissance;
  final QuestionnaireCommune? habitation;
  final QuestionnaireSituation? situation;
  final Set<QuestionnaireObjectif> objectifs;
  final String? domaine;
  final bool domaineInconnu;
  final QuestionnaireCommune? villeRecherche;
  final int rayonKm;
  final Set<QuestionnaireFrein> freins;

  const OnboardingQuestionnaireAnswers({
    this.prenom,
    this.dateNaissance,
    this.habitation,
    this.situation,
    this.objectifs = const {},
    this.domaine,
    this.domaineInconnu = false,
    this.villeRecherche,
    this.rayonKm = 20,
    this.freins = const {},
  });

  OnboardingQuestionnaireAnswers copyWith({
    String? prenom,
    bool clearPrenom = false,
    DateTime? dateNaissance,
    bool clearDateNaissance = false,
    QuestionnaireCommune? habitation,
    bool clearHabitation = false,
    QuestionnaireSituation? situation,
    bool clearSituation = false,
    Set<QuestionnaireObjectif>? objectifs,
    String? domaine,
    bool clearDomaine = false,
    bool? domaineInconnu,
    QuestionnaireCommune? villeRecherche,
    bool clearVilleRecherche = false,
    int? rayonKm,
    Set<QuestionnaireFrein>? freins,
  }) {
    return OnboardingQuestionnaireAnswers(
      prenom: clearPrenom ? null : (prenom ?? this.prenom),
      dateNaissance: clearDateNaissance ? null : (dateNaissance ?? this.dateNaissance),
      habitation: clearHabitation ? null : (habitation ?? this.habitation),
      situation: clearSituation ? null : (situation ?? this.situation),
      objectifs: objectifs ?? this.objectifs,
      domaine: clearDomaine ? null : (domaine ?? this.domaine),
      domaineInconnu: domaineInconnu ?? this.domaineInconnu,
      villeRecherche: clearVilleRecherche ? null : (villeRecherche ?? this.villeRecherche),
      rayonKm: rayonKm ?? this.rayonKm,
      freins: freins ?? this.freins,
    );
  }

  Map<String, dynamic> toJson() => {
        if (prenom != null) 'prenom': prenom,
        if (dateNaissance != null) 'dateNaissance': dateNaissance!.toIso8601String(),
        if (habitation != null) 'habitation': habitation!.toJson(),
        if (situation != null) 'situation': situation!.storageValue,
        'objectifs': objectifs.map((e) => e.storageValue).toList(),
        if (domaine != null) 'domaine': domaine,
        'domaineInconnu': domaineInconnu,
        if (villeRecherche != null) 'villeRecherche': villeRecherche!.toJson(),
        'rayonKm': rayonKm,
        'freins': freins.map((e) => e.storageValue).toList(),
      };

  factory OnboardingQuestionnaireAnswers.fromJson(Map<String, dynamic> json) {
    final objectifsJson = json['objectifs'];
    final freinsJson = json['freins'];
    return OnboardingQuestionnaireAnswers(
      prenom: json['prenom'] as String?,
      dateNaissance: json['dateNaissance'] != null ? DateTime.tryParse(json['dateNaissance'] as String) : null,
      habitation: json['habitation'] != null
          ? QuestionnaireCommune.fromStorageJson(json['habitation'] as Map<String, dynamic>)
          : null,
      situation: QuestionnaireSituation.fromStorage(json['situation'] as String?),
      objectifs: objectifsJson is List
          ? objectifsJson.map((e) => QuestionnaireObjectif.fromStorage(e as String)).whereType<QuestionnaireObjectif>().toSet()
          : {},
      domaine: json['domaine'] as String?,
      domaineInconnu: json['domaineInconnu'] as bool? ?? false,
      villeRecherche: json['villeRecherche'] != null
          ? QuestionnaireCommune.fromStorageJson(json['villeRecherche'] as Map<String, dynamic>)
          : null,
      rayonKm: json['rayonKm'] as int? ?? 20,
      freins: freinsJson is List
          ? freinsJson.map((e) => QuestionnaireFrein.fromStorage(e as String)).whereType<QuestionnaireFrein>().toSet()
          : {},
    );
  }

  bool get canGenerateActionPlan => situation != null && objectifs.isNotEmpty;

  bool get isPrenomAnswered => prenom != null && prenom!.trim().isNotEmpty;

  bool get isDateNaissanceAnswered => dateNaissance != null;

  bool get isHabitationAnswered => habitation != null;

  bool get isSituationAnswered => situation != null;

  bool get isObjectifsAnswered => objectifs.isNotEmpty;

  bool get isDomaineAnswered => domaineInconnu || (domaine != null && domaine!.trim().isNotEmpty);

  bool get isVilleRechercheAnswered => villeRecherche != null;

  bool get isFreinsAnswered => freins.isNotEmpty;

  int get answeredStepsCount {
    var count = 0;
    if (isPrenomAnswered) count++;
    if (isDateNaissanceAnswered) count++;
    if (isHabitationAnswered) count++;
    if (isSituationAnswered) count++;
    if (isObjectifsAnswered) count++;
    if (isDomaineAnswered) count++;
    if (isVilleRechercheAnswered) count++;
    if (isFreinsAnswered) count++;
    return count;
  }

  static const int totalStepsCount = 8;

  bool get isProfileComplete => answeredStepsCount == totalStepsCount;

  OnboardingQuestionnaireCompleteness get completeness {
    if (!canGenerateActionPlan) return OnboardingQuestionnaireCompleteness.incomplet;
    if (!isProfileComplete) return OnboardingQuestionnaireCompleteness.partiel;
    return OnboardingQuestionnaireCompleteness.complet;
  }

  @override
  List<Object?> get props => [
        prenom,
        dateNaissance,
        habitation,
        situation,
        objectifs,
        domaine,
        domaineInconnu,
        villeRecherche,
        rayonKm,
        freins,
      ];
}

enum OnboardingQuestionnaireCompleteness { incomplet, partiel, complet }
