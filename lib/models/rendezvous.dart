import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/conseiller.dart';

class Rendezvous extends Equatable {
  final String id;
  final RendezvousSource source;
  final DateTime date;
  final bool isInVisio;
  final bool isAnnule;
  final RendezvousType type;
  final bool? withConseiller;
  final String? modality;
  final int? duration;
  final String? title;
  final String? comment;
  final String? organism;
  final String? address;
  final String? phone;
  final String? visioRedirectUrl;
  final String? theme;
  final String? description;
  final String? precision;
  final Conseiller? conseiller;
  final Conseiller? createur;
  final bool? estInscrit;
  final String? animateur;
  final bool? createdFromSessionMilo;
  final bool? autoinscription;
  final bool? autodesinscription;
  final int? nombreDePlacesRestantes;
  final DateTime? dateMaxInscription;
  final DateTime? dateMaxDesinscription;

  Rendezvous({
    required this.id,
    required this.source,
    required this.date,
    required this.isInVisio,
    required this.isAnnule,
    required this.type,
    this.withConseiller,
    this.modality,
    this.duration,
    this.title,
    this.comment,
    this.organism,
    this.address,
    this.phone,
    this.visioRedirectUrl,
    this.theme,
    this.description,
    this.precision,
    this.conseiller,
    this.createur,
    this.estInscrit,
    this.animateur,
    this.createdFromSessionMilo,
    this.autoinscription,
    this.autodesinscription,
    this.nombreDePlacesRestantes,
    this.dateMaxInscription,
    this.dateMaxDesinscription,
  });

  RendezvousModalityType modalityType() {
    if (modality == "par téléphone") return RendezvousModalityType.TELEPHONE;
    return RendezvousModalityType.NONE;
  }

  @override
  List<Object?> get props {
    return [
      id,
      source,
      date,
      duration,
      isInVisio,
      modality,
      isAnnule,
      type,
      withConseiller,
      title,
      comment,
      organism,
      address,
      phone,
      visioRedirectUrl,
      theme,
      description,
      precision,
      conseiller,
      createur,
      estInscrit,
      animateur,
      createdFromSessionMilo,
      autoinscription,
      autodesinscription,
      nombreDePlacesRestantes,
      dateMaxInscription,
      dateMaxDesinscription,
    ];
  }

  bool get autoInscriptionAvailable =>
      estInscrit == false && //
      autoinscription == true &&
      !isComplet &&
      (dateMaxInscription == null || dateMaxInscription?.isAfter(DateTime.now()) == true);

  bool get isComplet => nombreDePlacesRestantes != null && nombreDePlacesRestantes == 0;
}

class RendezvousType extends Equatable {
  final RendezvousTypeCode code;
  final String label;

  const RendezvousType(this.code, this.label);

  @override
  List<Object?> get props => [code, label];
}

enum RendezvousTypeCode {
  ACTIVITE_EXTERIEURES,
  ATELIER,
  ENTRETIEN_INDIVIDUEL_CONSEILLER,
  ENTRETIEN_PARTENAIRE,
  INFORMATION_COLLECTIVE,
  VISITE,
  PRESTATION,
  AUTRE,
}

enum RendezvousModalityType { TELEPHONE, NONE }

enum RendezvousSource { milo, passEmploi }

extension RendezvousSourceExt on RendezvousSource {
  bool get isMilo => this == RendezvousSource.milo;
}

const rendezvousDefaultEmoji = '📅';

Color get rendezvousDefaultEmojiBackground => DsfrColors.blueCumulus950;

extension RendezvousTypeCodeVisual on RendezvousTypeCode {
  String get emoji => switch (this) {
        RendezvousTypeCode.ACTIVITE_EXTERIEURES => '🌳',
        RendezvousTypeCode.ATELIER => '🛠️',
        RendezvousTypeCode.ENTRETIEN_INDIVIDUEL_CONSEILLER => '👤',
        RendezvousTypeCode.ENTRETIEN_PARTENAIRE => '🤝',
        RendezvousTypeCode.INFORMATION_COLLECTIVE => 'ℹ️',
        RendezvousTypeCode.VISITE => '🏢',
        RendezvousTypeCode.PRESTATION => '📋',
        RendezvousTypeCode.AUTRE => rendezvousDefaultEmoji,
      };

  Color get emojiBackground => switch (this) {
        RendezvousTypeCode.ACTIVITE_EXTERIEURES => DsfrColors.greenTilleulVerveine950,
        RendezvousTypeCode.ATELIER => DsfrColors.brownCaramel950,
        RendezvousTypeCode.ENTRETIEN_INDIVIDUEL_CONSEILLER => DsfrColors.purpleGlycine925,
        RendezvousTypeCode.ENTRETIEN_PARTENAIRE => DsfrColors.greenMenthe950,
        RendezvousTypeCode.INFORMATION_COLLECTIVE => DsfrColors.blueCumulus950,
        RendezvousTypeCode.VISITE => DsfrColors.blueFrance950,
        RendezvousTypeCode.PRESTATION => DsfrColors.pinkTuile925,
        RendezvousTypeCode.AUTRE => rendezvousDefaultEmojiBackground,
      };
}
