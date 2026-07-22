import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class InviteCommune extends Equatable {
  final String code;
  final String nom;
  final String? codePostal;
  final double? latitude;
  final double? longitude;

  const InviteCommune({
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

  factory InviteCommune.fromJson(Map<String, dynamic> json, {String? preferredCodePostal}) {
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
    return InviteCommune(
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

  factory InviteCommune.fromStorageJson(Map<String, dynamic> json) {
    return InviteCommune(
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

enum InviteSituation {
  college,
  lycee,
  etudesSuperieures,
  emploi,
  autre;

  String get label => switch (this) {
        InviteSituation.college => Strings.inviteOnboardingSituationCollege,
        InviteSituation.lycee => Strings.inviteOnboardingSituationLycee,
        InviteSituation.etudesSuperieures => Strings.inviteOnboardingSituationEtudes,
        InviteSituation.emploi => Strings.inviteOnboardingSituationEmploi,
        InviteSituation.autre => Strings.inviteOnboardingSituationAutre,
      };

  String get emoji => switch (this) {
        InviteSituation.college => '📚',
        InviteSituation.lycee => '🎓',
        InviteSituation.etudesSuperieures => '🏫',
        InviteSituation.emploi => '💼',
        InviteSituation.autre => '✨',
      };

  Color get illustrationColor => switch (this) {
        InviteSituation.college => DsfrColors.purpleGlycine950,
        InviteSituation.lycee => DsfrColors.blueCumulus950,
        InviteSituation.etudesSuperieures => DsfrColors.greenTilleulVerveine950,
        InviteSituation.emploi => DsfrColors.pinkTuile925,
        InviteSituation.autre => DsfrColors.greenEmeraude950,
      };

  String get storageValue => name;

  static InviteSituation? fromStorage(String? value) {
    if (value == null) return null;
    for (final situation in InviteSituation.values) {
      if (situation.storageValue == value) return situation;
    }
    return null;
  }
}

enum InviteObjectif {
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
        InviteObjectif.orienter => Strings.inviteOnboardingObjectifOrienter,
        InviteObjectif.decouvrirMetiers => Strings.inviteOnboardingObjectifDecouvrirMetiers,
        InviteObjectif.former => Strings.inviteOnboardingObjectifFormer,
        InviteObjectif.stageImmersion => Strings.inviteOnboardingObjectifStage,
        InviteObjectif.alternance => Strings.inviteOnboardingObjectifAlternance,
        InviteObjectif.emploi => Strings.inviteOnboardingObjectifEmploi,
        InviteObjectif.engager => Strings.inviteOnboardingObjectifEngager,
        InviteObjectif.mobiliteInternationale => Strings.inviteOnboardingObjectifMobilite,
        InviteObjectif.accompagne => Strings.inviteOnboardingObjectifAccompagne,
        InviteObjectif.creerActivite => Strings.inviteOnboardingObjectifCreerActivite,
        InviteObjectif.vieQuotidienne => Strings.inviteOnboardingObjectifVieQuotidienne,
      };

  String get emoji => switch (this) {
        InviteObjectif.orienter => '🧭',
        InviteObjectif.decouvrirMetiers => '🔎',
        InviteObjectif.former => '📚',
        InviteObjectif.stageImmersion => '👀',
        InviteObjectif.alternance => '🔧',
        InviteObjectif.emploi => '💼',
        InviteObjectif.engager => '🤝',
        InviteObjectif.mobiliteInternationale => '✈️',
        InviteObjectif.accompagne => '🩹',
        InviteObjectif.creerActivite => '🚀',
        InviteObjectif.vieQuotidienne => '🍿',
      };

  Color get illustrationColor => switch (this) {
        InviteObjectif.orienter => DsfrColors.pinkTuile950,
        InviteObjectif.decouvrirMetiers => DsfrColors.greenTilleulVerveine950,
        InviteObjectif.former => DsfrColors.purpleGlycine950,
        InviteObjectif.stageImmersion => DsfrColors.blueCumulus950,
        InviteObjectif.alternance => DsfrColors.blueFrance925,
        InviteObjectif.emploi => DsfrColors.greenEmeraude950,
        InviteObjectif.engager => DsfrColors.greenTilleulVerveine925,
        InviteObjectif.mobiliteInternationale => DsfrColors.purpleGlycine925,
        InviteObjectif.accompagne => DsfrColors.pinkTuile925,
        InviteObjectif.creerActivite => DsfrColors.greenEmeraude925,
        InviteObjectif.vieQuotidienne => DsfrColors.pinkTuile950,
      };

  String get storageValue => name;

  static InviteObjectif? fromStorage(String value) {
    for (final objectif in InviteObjectif.values) {
      if (objectif.storageValue == value) return objectif;
    }
    return null;
  }
}

enum InviteFrein {
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
        InviteFrein.pasDePermis => Strings.inviteOnboardingFreinPasDePermis,
        InviteFrein.pasDeTransport => Strings.inviteOnboardingFreinPasDeTransport,
        InviteFrein.pasDeLogement => Strings.inviteOnboardingFreinPasDeLogement,
        InviteFrein.manqueConfiance => Strings.inviteOnboardingFreinManqueConfiance,
        InviteFrein.finDeMois => Strings.inviteOnboardingFreinFinDeMois,
        InviteFrein.pasDeDiplome => Strings.inviteOnboardingFreinPasDeDiplome,
        InviteFrein.peuExperience => Strings.inviteOnboardingFreinPeuExperience,
        InviteFrein.handicap => Strings.inviteOnboardingFreinHandicap,
        InviteFrein.sante => Strings.inviteOnboardingFreinSante,
        InviteFrein.gardeEnfant => Strings.inviteOnboardingFreinGardeEnfant,
        InviteFrein.numerique => Strings.inviteOnboardingFreinNumerique,
        InviteFrein.francais => Strings.inviteOnboardingFreinFrancais,
        InviteFrein.autre => Strings.inviteOnboardingFreinAutre,
        InviteFrein.rienNeMeBloque => Strings.inviteOnboardingFreinRienNeMeBloque,
      };

  String get emoji => switch (this) {
        InviteFrein.pasDePermis => '🚗',
        InviteFrein.pasDeTransport => '🚌',
        InviteFrein.pasDeLogement => '🏠',
        InviteFrein.manqueConfiance => '😟',
        InviteFrein.finDeMois => '💶',
        InviteFrein.pasDeDiplome => '🎓',
        InviteFrein.peuExperience => '💼',
        InviteFrein.handicap => '♿',
        InviteFrein.sante => '🩺',
        InviteFrein.gardeEnfant => '👶',
        InviteFrein.numerique => '💻',
        InviteFrein.francais => '🗣️',
        InviteFrein.autre => '✅',
        InviteFrein.rienNeMeBloque => '✨',
      };

  Color get illustrationColor => switch (this) {
        InviteFrein.pasDePermis => DsfrColors.greenTilleulVerveine950,
        InviteFrein.pasDeTransport => DsfrColors.blueFrance925,
        InviteFrein.pasDeLogement => DsfrColors.greenEmeraude950,
        InviteFrein.manqueConfiance => DsfrColors.pinkTuile950,
        InviteFrein.finDeMois => DsfrColors.greenTilleulVerveine925,
        InviteFrein.pasDeDiplome => DsfrColors.blueFrance925,
        InviteFrein.peuExperience => DsfrColors.greenEmeraude925,
        InviteFrein.handicap => DsfrColors.blueCumulus950,
        InviteFrein.sante => DsfrColors.purpleGlycine950,
        InviteFrein.gardeEnfant => DsfrColors.pinkTuile925,
        InviteFrein.numerique => DsfrColors.greenTilleulVerveine950,
        InviteFrein.francais => DsfrColors.greenEmeraude950,
        InviteFrein.autre => DsfrColors.purpleGlycine950,
        InviteFrein.rienNeMeBloque => DsfrColors.greenEmeraude950,
      };

  bool get isExclusive => this == InviteFrein.rienNeMeBloque;

  String get storageValue => name;

  static InviteFrein? fromStorage(String value) {
    for (final frein in InviteFrein.values) {
      if (frein.storageValue == value) return frein;
    }
    return null;
  }
}

class InviteOnboardingAnswers extends Equatable {
  final String? prenom;
  final DateTime? dateNaissance;
  final InviteCommune? habitation;
  final InviteSituation? situation;
  final Set<InviteObjectif> objectifs;
  final String? domaine;
  final bool domaineInconnu;
  final InviteCommune? villeRecherche;
  final int rayonKm;
  final Set<InviteFrein> freins;

  const InviteOnboardingAnswers({
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

  InviteOnboardingAnswers copyWith({
    String? prenom,
    bool clearPrenom = false,
    DateTime? dateNaissance,
    bool clearDateNaissance = false,
    InviteCommune? habitation,
    bool clearHabitation = false,
    InviteSituation? situation,
    bool clearSituation = false,
    Set<InviteObjectif>? objectifs,
    String? domaine,
    bool clearDomaine = false,
    bool? domaineInconnu,
    InviteCommune? villeRecherche,
    bool clearVilleRecherche = false,
    int? rayonKm,
    Set<InviteFrein>? freins,
  }) {
    return InviteOnboardingAnswers(
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

  factory InviteOnboardingAnswers.fromJson(Map<String, dynamic> json) {
    final objectifsJson = json['objectifs'];
    final freinsJson = json['freins'];
    return InviteOnboardingAnswers(
      prenom: json['prenom'] as String?,
      dateNaissance: json['dateNaissance'] != null ? DateTime.tryParse(json['dateNaissance'] as String) : null,
      habitation: json['habitation'] != null
          ? InviteCommune.fromStorageJson(json['habitation'] as Map<String, dynamic>)
          : null,
      situation: InviteSituation.fromStorage(json['situation'] as String?),
      objectifs: objectifsJson is List
          ? objectifsJson.map((e) => InviteObjectif.fromStorage(e as String)).whereType<InviteObjectif>().toSet()
          : {},
      domaine: json['domaine'] as String?,
      domaineInconnu: json['domaineInconnu'] as bool? ?? false,
      villeRecherche: json['villeRecherche'] != null
          ? InviteCommune.fromStorageJson(json['villeRecherche'] as Map<String, dynamic>)
          : null,
      rayonKm: json['rayonKm'] as int? ?? 20,
      freins: freinsJson is List
          ? freinsJson.map((e) => InviteFrein.fromStorage(e as String)).whereType<InviteFrein>().toSet()
          : {},
    );
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
