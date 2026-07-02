import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/models/metier.dart';

sealed class MetierCritere extends Equatable {
  String get label;

  static MetierCritere? fromJson(dynamic json) {
    if (json == null) return null;
    return switch (json['type'] as String?) {
      'rome' => MetierRomeCritere(Metier(codeRome: json['codeRome'] as String, libelle: json['libelle'] as String)),
      'texteLibre' => MetierTexteLibreCritere(json['texte'] as String),
      _ => null,
    };
  }

  Map<String, dynamic> toJson();
}

class MetierRomeCritere extends MetierCritere {
  final Metier metier;

  MetierRomeCritere(this.metier);

  @override
  String get label => metier.libelle;

  @override
  Map<String, dynamic> toJson() => {'type': 'rome', 'codeRome': metier.codeRome, 'libelle': metier.libelle};

  @override
  List<Object?> get props => [metier];
}

class MetierTexteLibreCritere extends MetierCritere {
  final String texte;

  MetierTexteLibreCritere(this.texte);

  @override
  String get label => texte;

  @override
  Map<String, dynamic> toJson() => {'type': 'texteLibre', 'texte': texte};

  @override
  List<Object?> get props => [texte];
}

class CriteresRechercheUtilisateur extends Equatable {
  final MetierCritere? metier;
  final Location? location;
  final int? rayon;

  const CriteresRechercheUtilisateur({this.metier, this.location, this.rayon});

  CriteresRechercheUtilisateur copyWith({MetierCritere? metier, Location? location, int? rayon}) {
    return CriteresRechercheUtilisateur(
      metier: metier ?? this.metier,
      location: location ?? this.location,
      rayon: rayon ?? this.rayon,
    );
  }

  factory CriteresRechercheUtilisateur.fromJson(dynamic json) {
    return CriteresRechercheUtilisateur(
      metier: MetierCritere.fromJson(json['metier']),
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      rayon: json['rayon'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (metier != null) 'metier': metier!.toJson(),
        if (location != null) 'location': location!.toJson(),
        if (rayon != null) 'rayon': rayon,
      };

  @override
  List<Object?> get props => [metier, location, rayon];
}
