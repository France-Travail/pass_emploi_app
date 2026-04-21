import 'package:equatable/equatable.dart';

const String _idSeparator = '|';

class Immersion extends Equatable {
  final String id;
  final String siret;
  final String appellationCode;
  final String locationId;
  final String metier;
  final String nomEtablissement;
  final String secteurActivite;
  final String ville;
  final bool fromEntrepriseAccueillante;
  final bool fitForDisabledWorkers;

  Immersion({
    required this.id,
    required this.siret,
    required this.appellationCode,
    required this.locationId,
    required this.metier,
    required this.nomEtablissement,
    required this.secteurActivite,
    required this.ville,
    this.fromEntrepriseAccueillante = false,
    this.fitForDisabledWorkers = false,
  });

  static String buildSyntheticId({
    required String siret,
    required String appellationCode,
    required String locationId,
  }) {
    return '$siret$_idSeparator$appellationCode$_idSeparator$locationId';
  }

  @Deprecated('Do not parse ID for retrocompatibility. Pass parameters directly to the constructor instead.')
  static ({String siret, String appellationCode, String locationId}) parseSyntheticId(String id) {
    final parts = id.split(_idSeparator);
    return (siret: parts[0], appellationCode: parts[1], locationId: parts[2]);
  }

  factory Immersion.fromJson(dynamic json) {
    final siret = json['siret'] as String? ?? '';
    final appellationCode = json['appellationCode'] as String? ?? '';
    final locationId = json['locationId'] as String? ?? '';
    final rawId = json['id'] as String?;
    return Immersion(
      id: rawId ?? buildSyntheticId(siret: siret, appellationCode: appellationCode, locationId: locationId),
      siret: siret,
      appellationCode: appellationCode,
      locationId: locationId,
      metier: json['metier'] as String,
      nomEtablissement: json['nomEtablissement'] as String,
      secteurActivite: json['secteurActivite'] as String,
      ville: json['ville'] as String,
      fromEntrepriseAccueillante: json['estVolontaire'] as bool? ?? false,
      fitForDisabledWorkers: json['fitForDisabledWorkers'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "siret": siret,
      "appellationCode": appellationCode,
      "locationId": locationId,
      "metier": metier,
      "nomEtablissement": nomEtablissement,
      "secteurActivite": secteurActivite,
      "ville": ville,
      "estVolontaire": fromEntrepriseAccueillante,
      "fitForDisabledWorkers": fitForDisabledWorkers,
    };
  }

  @override
  List<Object?> get props => [
    id,
    siret,
    appellationCode,
    locationId,
    metier,
    nomEtablissement,
    secteurActivite,
    ville,
    fromEntrepriseAccueillante,
    fitForDisabledWorkers,
  ];
}
