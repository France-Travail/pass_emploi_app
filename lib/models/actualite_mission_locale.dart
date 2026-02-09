import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/utils/string_extensions.dart';

class ActualiteMissionLocale extends Equatable {
  final String id;
  final String titre;
  final String corps;
  final String titreDuLien;
  final String lien;
  final String nomConseiller;
  final DateTime dateCreation;

  ActualiteMissionLocale({
    required this.id,
    required this.titre,
    required this.corps,
    required this.titreDuLien,
    required this.lien,
    required this.nomConseiller,
    required this.dateCreation,
  });

  factory ActualiteMissionLocale.fromJson(Map<String, dynamic> json) {
    final dateCreation = json['dateCreation'] as String?;
    if (dateCreation == null) {
      throw Exception('dateCreation is required');
    }
    return ActualiteMissionLocale(
      id: json['id'] as String,
      titre: json['titre'] as String,
      corps: json['corps'] as String,
      titreDuLien: json['titreDuLien'] as String,
      lien: json['lien'] as String,
      nomConseiller: json['nomConseiller'] as String,
      dateCreation: dateCreation.toDateTimeSafe() ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, titre, corps, titreDuLien, lien, nomConseiller, dateCreation];
}
