import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/immersion.dart';
import 'package:pass_emploi_app/models/offre_emploi.dart';
import 'package:pass_emploi_app/models/offre_type.dart';
import 'package:pass_emploi_app/models/service_civique.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/string_extensions.dart';

enum FavoriStatus { added, removed, applied }

class Favori extends Equatable {
  final String id;
  final OffreType type;
  final DateTime dateDeCreation;
  final DateTime? datePostulation;
  final String titre;
  final String? organisation;
  final String? localisation;
  final Origin? origin;

  Favori({
    required this.id,
    required this.type,
    required this.dateDeCreation,
    this.datePostulation,
    required this.titre,
    required this.organisation,
    required this.localisation,
    this.origin,
  });

  static Favori? fromJson(dynamic json) {
    final type = OffreType.from(json["type"] as String);
    if (type == null) return null;
    return Favori(
      id: json['idOffre'] as String,
      type: type,
      dateDeCreation: (json['dateCreation'] as String).toDateTimeUtcOnLocalTimeZone(),
      datePostulation:
          json['dateCandidature'] != null ? (json['dateCandidature'] as String).toDateTimeUtcOnLocalTimeZone() : null,
      titre: json['titre'] as String,
      organisation: json['organisation'] as String?,
      localisation: json['localisation'] as String?,
      origin: Origin.fromJson(json),
    );
  }

  @override
  List<Object?> get props => [id, type, titre, organisation, localisation, origin];
}

extension FavoriExt on Favori {
  OffreEmploi get toOffreEmploi => OffreEmploi(
        id: id,
        title: titre,
        companyName: organisation,
        contractType: Strings.favorisUnknownContractType,
        isAlternance: false,
        location: localisation,
        duration: null,
        origin: origin,
      );

  Immersion get toImmersion => Immersion(
        id: id,
        metier: titre,
        nomEtablissement: organisation ?? '',
        secteurActivite: Strings.favorisUnknownSecteur,
        ville: localisation ?? '',
      );

  ServiceCivique get toServiceCivique => ServiceCivique(
        id: id,
        title: titre,
        location: localisation,
        domain: null,
        companyName: organisation,
        startDate: null,
      );
}
