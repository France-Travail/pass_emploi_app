import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/utils/string_extensions.dart';

class ActualiteMissionLocale extends Equatable {
  final String titre;
  final String contenu;
  final String? titreLien;
  final String? lien;
  final String nomPrenomConseiller;
  final DateTime dateCreation;
  final bool isSupprime;

  ActualiteMissionLocale({
    required this.titre,
    required this.contenu,
    required this.titreLien,
    required this.lien,
    required this.nomPrenomConseiller,
    required this.dateCreation,
    required this.isSupprime,
  });

  factory ActualiteMissionLocale.fromJson(Map<String, dynamic> json) {
    final dateCreation = json['dateCreation'] as String?;
    if (dateCreation == null) {
      throw Exception('dateCreation is required');
    }
    return ActualiteMissionLocale(
      titre: json['titre'] as String,
      contenu: json['contenu'] as String,
      titreLien: json['titreLien'] as String?,
      lien: json['lien'] as String?,
      nomPrenomConseiller: json['nomPrenomConseiller'] as String,
      dateCreation: dateCreation.toDateTimeSafe() ?? DateTime.now(),
      isSupprime: json['dateSuppression'] != null,
    );
  }

  @override
  List<Object?> get props => [titre, contenu, titreLien, lien, nomPrenomConseiller, dateCreation, isSupprime];
}
