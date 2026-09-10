import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pass_emploi_app/models/rendezvous.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/utils/string_extensions.dart';

class SessionMilo extends Equatable {
  final String id;
  final String nomSession;
  final String nomOffre;
  final DateTime dateDeDebut;
  final DateTime? dateDeFin;
  final SessionMiloType type;
  final String? theme;
  final bool estInscrit;
  final bool? autoinscription;
  final bool? autodesinscription;
  final int? nombreDePlacesRestantes;
  final DateTime? dateMaxInscription;

  SessionMilo({
    required this.id,
    required this.nomSession,
    required this.nomOffre,
    required this.dateDeDebut,
    this.dateDeFin,
    required this.type,
    required this.theme,
    required this.estInscrit,
    required this.autoinscription,
    required this.autodesinscription,
    this.nombreDePlacesRestantes,
    this.dateMaxInscription,
  });

  factory SessionMilo.fromJson(dynamic json) {
    return SessionMilo(
      id: json["id"] as String,
      nomSession: json["nomSession"] as String,
      nomOffre: json["nomOffre"] as String,
      dateDeDebut: (json["dateHeureDebut"] as String).toDateTimeUtcOnLocalTimeZone(),
      dateDeFin: (json["dateHeureFin"] as String?)?.toDateTimeUtcOnLocalTimeZone(),
      type: SessionMiloType.fromJson(json["type"]),
      theme: json["theme"] as String?,
      estInscrit: (json["inscription"] as String?) == "INSCRIT",
      autoinscription: json["autoinscription"] as bool?,
      autodesinscription: json["autodesinscription"] as bool?,
      nombreDePlacesRestantes: json["nbPlacesRestantes"] as int?,
      dateMaxInscription: (json["dateMaxInscription"] as String?)?.toDateTimeUtcOnLocalTimeZone(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    nomSession,
    dateDeDebut,
    dateDeFin,
    type,
    estInscrit,
    autoinscription,
    autodesinscription,
    nombreDePlacesRestantes,
    dateMaxInscription,
    theme,
  ];

  Rendezvous get toRendezVous {
    return Rendezvous(
      id: id,
      title: displayableTitle,
      date: dateDeDebut,
      type: type.toRendezvousType,
      isAnnule: false,
      source: RendezvousSource.milo,
      isInVisio: false,
      estInscrit: estInscrit,
      createdFromSessionMilo: true,
      autoinscription: autoinscription,
      autodesinscription: autodesinscription,
      nombreDePlacesRestantes: nombreDePlacesRestantes,
      dateMaxInscription: dateMaxInscription,
      theme: theme,
      duration: dateDeFin?.difference(dateDeDebut).inMinutes,
    );
  }

  String get displayableTitle {
    return "$nomOffre - $nomSession";
  }

  static String? themeEmoji(String? theme) => _themeType(theme)?.emoji;

  static Color? themeEmojiBackground(String? theme) => _themeType(theme)?.emojiBackground;

  static UserActionReferentielType? _themeType(String? theme) {
    return switch (theme) {
      "Accès à l'emploi" => UserActionReferentielType.emploi,
      "Formation" => UserActionReferentielType.formation,
      "Projet professionnel" => UserActionReferentielType.projetProfessionnel,
      "Logement" => UserActionReferentielType.logement,
      "Santé" => UserActionReferentielType.sante,
      "Citoyenneté" => UserActionReferentielType.citoyennete,
      "Loisirs, sport, culture" => UserActionReferentielType.cultureSportLoisirs,
      _ => null,
    };
  }
}

class SessionMiloType extends Equatable {
  final SessionMiloTypeCode code;
  final String label;

  const SessionMiloType(this.code, this.label);

  @override
  List<Object?> get props => [code, label];

  factory SessionMiloType.fromJson(dynamic json) {
    return SessionMiloType(
      _parseSessionMiloTypeCode(json['code'] as String),
      json['label'] as String,
    );
  }

  RendezvousType get toRendezvousType {
    return RendezvousType(code.rendezvousTypeCode, label);
  }
}

enum SessionMiloTypeCode {
  WORKSHOP,
  COLLECTIVE_INFORMATION,
  AUTRE,
}

SessionMiloTypeCode _parseSessionMiloTypeCode(String sessionMiloTypeCode) {
  return SessionMiloTypeCode.values.firstWhere(
    // ignore: sdk_version_since
    (e) => e.name == sessionMiloTypeCode,
    orElse: () => SessionMiloTypeCode.AUTRE,
  );
}

extension SessionMiloTypeCodeExt on SessionMiloTypeCode {
  RendezvousTypeCode get rendezvousTypeCode {
    switch (this) {
      case SessionMiloTypeCode.WORKSHOP:
        return RendezvousTypeCode.ATELIER;
      case SessionMiloTypeCode.COLLECTIVE_INFORMATION:
        return RendezvousTypeCode.INFORMATION_COLLECTIVE;
      case SessionMiloTypeCode.AUTRE:
        return RendezvousTypeCode.AUTRE;
    }
  }
}
