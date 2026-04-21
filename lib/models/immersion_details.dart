import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/immersion.dart';
import 'package:pass_emploi_app/models/immersion_contact.dart';

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
  final String website;
  final String codeRome;
  final bool fromEntrepriseAccueillante;
  final bool fitForDisabledWorkers;
  final ImmersionContactMode contactMode;
  final ImmersionContact? contact;

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
    required this.website,
    this.codeRome = '',
    required this.fromEntrepriseAccueillante,
    required this.fitForDisabledWorkers,
    required this.contactMode,
    required this.contact,
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
      website: json['website'] as String? ?? '',
      codeRome: json['codeRome'] as String? ?? '',
      fromEntrepriseAccueillante: json['estVolontaire'] as bool,
      fitForDisabledWorkers: json['fitForDisabledWorkers'] as bool? ?? false,
      contactMode: parseImmersionContactMode(json['contactMode'] as String?),
      contact: json['contact'] != null ? ImmersionContact.fromJson(json['contact']) : null,
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
        website,
        codeRome,
        fromEntrepriseAccueillante,
        fitForDisabledWorkers,
        contactMode,
        contact,
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
        fromEntrepriseAccueillante: fromEntrepriseAccueillante,
        fitForDisabledWorkers: fitForDisabledWorkers,
      );
}
