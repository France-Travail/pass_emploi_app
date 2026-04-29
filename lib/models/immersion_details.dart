import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/immersion.dart';
import 'package:pass_emploi_app/models/immersion_contact.dart';

enum ImmersionModeDistanciel {
  FULL_REMOTE,
  HYBRID,
  ON_SITE,
}

ImmersionModeDistanciel? parseImmersionModeDistanciel(String? value) {
  return switch (value) {
    'FULL_REMOTE' => ImmersionModeDistanciel.FULL_REMOTE,
    'HYBRID' => ImmersionModeDistanciel.HYBRID,
    'ON_SITE' => ImmersionModeDistanciel.ON_SITE,
    _ => null,
  };
}

class ImmersionDetails extends Equatable {
  final String id;
  final String siret;
  final String appellationCode;
  final String locationId;
  final String metier;
  final String companyName;
  final String secteurActivite;
  final String ville;
  final String address;
  final String? informationComplementaire;
  final String? website;
  final String codeRome;
  final bool fitForDisabledWorkers;
  final ImmersionContactMode contactMode;
  final ImmersionModeDistanciel? modeDistanciel;

  ImmersionDetails({
    required this.id,
    required this.siret,
    required this.appellationCode,
    required this.locationId,
    required this.metier,
    required this.companyName,
    required this.secteurActivite,
    required this.ville,
    required this.address,
    this.informationComplementaire,
    this.website,
    this.codeRome = '',
    required this.fitForDisabledWorkers,
    required this.contactMode,
    this.modeDistanciel,
  });

  factory ImmersionDetails.fromJson(dynamic json) {
    final siret = json['siret'] as String;
    final appellationCode = json['appellationCode'] as String? ?? '';
    final locationId = json['locationId'] as String? ?? '';
    return ImmersionDetails(
      id: Immersion.buildSyntheticId(siret: siret, appellationCode: appellationCode, locationId: locationId),
      siret: siret,
      appellationCode: appellationCode,
      locationId: locationId,
      metier: json['metier'] as String,
      companyName: json['nomEtablissement'] as String,
      secteurActivite: json['secteurActivite'] as String,
      ville: json['ville'] as String,
      address: json['adresse'] as String,
      informationComplementaire: json['informationsComplementaires'] as String? ?? '',
      website: json['siteWeb'] as String? ?? '',
      codeRome: json['codeRome'] as String? ?? '',
      fitForDisabledWorkers: json['fitForDisabledWorkers'] as bool? ?? false,
      contactMode: parseImmersionContactMode(json['contact'] as String?),
      modeDistanciel: parseImmersionModeDistanciel(json['modeDistanciel'] as String?),
    );
  }

  @override
  List<Object?> get props => [
    id,
    siret,
    appellationCode,
    locationId,
    metier,
    companyName,
    secteurActivite,
    ville,
    address,
    informationComplementaire,
    website,
    codeRome,
    fitForDisabledWorkers,
    contactMode,
    modeDistanciel,
  ];
}

extension ImmersionDetailsExt on ImmersionDetails {
  Immersion get toImmersion => Immersion(
    id: id,
    siret: siret,
    appellationCode: appellationCode,
    locationId: locationId,
    metier: metier,
    nomEtablissement: companyName,
    secteurActivite: secteurActivite,
    ville: ville,
    fitForDisabledWorkers: fitForDisabledWorkers,
  );
}
