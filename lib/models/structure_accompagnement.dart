import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

enum StructureAccompagnementType {
  missionLocale('MILO'),
  franceTravail('FRANCE_TRAVAIL');

  final String apiValue;

  const StructureAccompagnementType(this.apiValue);
}

class StructureAccompagnementAdresse extends Equatable {
  final String? ligne;
  final String? codePostal;
  final String? ville;

  const StructureAccompagnementAdresse({this.ligne, this.codePostal, this.ville});

  factory StructureAccompagnementAdresse.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return const StructureAccompagnementAdresse();
    return StructureAccompagnementAdresse(
      ligne: _nonBlank(json['ligne']),
      codePostal: _nonBlank(json['codePostal']),
      ville: _nonBlank(json['ville']),
    );
  }

  /// « 2 avenue de l'URSS, 31400 Toulouse » : rue, puis code postal et ville, sans les morceaux manquants.
  String? get complete {
    final localite = [codePostal, ville].nonNulls.join(' ');
    final parts = [ligne, if (localite.isNotEmpty) localite].nonNulls;
    return parts.isEmpty ? null : parts.join(', ');
  }

  @override
  List<Object?> get props => [ligne, codePostal, ville];
}

class StructureAccompagnement extends Equatable {
  final String nom;
  final StructureAccompagnementAdresse adresse;
  final String? telephone;
  final List<String> horaires;

  /// Horaires rédigés en phrases pour les lecteurs d'écran (« Lundi à mercredi ouvert de 8h30 à 12h30… »).
  final String? horairesAlt;

  const StructureAccompagnement({
    required this.nom,
    required this.adresse,
    this.telephone,
    this.horaires = const [],
    this.horairesAlt,
  });

  factory StructureAccompagnement.fromJson(Map<String, dynamic> json) {
    final horaires = json['horaires'];
    return StructureAccompagnement(
      nom: (json['nom'] as String).trim(),
      adresse: StructureAccompagnementAdresse.fromJson(json['adresse']),
      telephone: _nonBlank(json['telephone']),
      horaires: horaires is List ? horaires.map(_nonBlank).nonNulls.toList() : const [],
      horairesAlt: _nonBlank(json['horairesAlt']),
    );
  }

  @override
  List<Object?> get props => [nom, adresse, telephone, horaires, horairesAlt];
}

/// D'où vient la ville de la recherche (suivi Matomo uniquement : la ville elle-même n'est jamais suivie).
enum StructuresAccompagnementCommuneOrigine {
  questionnaire("Questionnaire"),
  saisie("Saisie"),
  geolocalisation("Géolocalisation");

  final String trackingLabel;

  const StructuresAccompagnementCommuneOrigine(this.trackingLabel);
}

class StructuresAccompagnementRequest extends Equatable {
  final StructureAccompagnementType type;
  final QuestionnaireCommune commune;
  final StructuresAccompagnementCommuneOrigine origine;

  const StructuresAccompagnementRequest({required this.type, required this.commune, required this.origine});

  @override
  List<Object?> get props => [type, commune, origine];
}

String? _nonBlank(dynamic value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
