import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

// Fiches ROME rangées dans la démo (récupérées une fois en recette) : les autres métiers montrent celle du boulanger.
const _fichesDeDemo = {
  'A1101', 'C1201', 'D1101', 'D1104', 'D1106', 'D1108', 'D1202', //
  'D1212', 'D1301', 'D1401', 'D1502', 'D1507', 'G1603',
};

String pocOrientationFicheDeDemo(String code) {
  return _fichesDeDemo.contains(code) ? 'poc_orientation_fiche_$code' : 'poc_orientation_fiche_metier';
}

// La fiche par défaut (poc_orientation_fiche_metier) est celle du boulanger, D1102.
bool aUneFicheDeDemo(String code) => code == 'D1102' || _fichesDeDemo.contains(code);

enum DifficulteRecrutement {
  tresFaible('Très faible'),
  faible('Faible'),
  moyenne('Moyenne'),
  elevee('Élevée'),
  tresElevee('Très élevée');

  const DifficulteRecrutement(this.libelle);

  final String libelle;

  static DifficulteRecrutement? de(String? libelle) =>
      values.where((difficulte) => difficulte.libelle == libelle).firstOrNull;

  bool get auMoinsMoyenne => index >= moyenne.index;
}

class ChiffresMetier {
  const ChiffresMetier({
    this.offres12Mois,
    this.demandeurs,
    this.salaireMin,
    this.salaireMax,
    this.embauchesTrimestre,
    this.partCdi,
    this.accesEmploi6Mois,
    this.difficulte,
    this.origines = const {},
  });

  final int? offres12Mois;
  final int? demandeurs;
  final int? salaireMin;
  final int? salaireMax;
  final int? embauchesTrimestre;
  final int? partCdi;
  final int? accesEmploi6Mois;
  final DifficulteRecrutement? difficulte;
  final Map<String, int> origines;

  factory ChiffresMetier.fromJson(dynamic json) {
    final salaire = json['salaire'] as List?;
    return ChiffresMetier(
      offres12Mois: json['offres12Mois'] as int?,
      demandeurs: json['demandeurs'] as int?,
      salaireMin: salaire?.first as int?,
      salaireMax: salaire?.last as int?,
      embauchesTrimestre: json['embauchesTrimestre'] as int?,
      partCdi: json['partCdi'] as int?,
      accesEmploi6Mois: json['accesEmploi6Mois'] as int?,
      difficulte: DifficulteRecrutement.de(json['difficulte'] as String?),
      origines: {
        for (final entree in ((json['origines'] as Map?) ?? const {}).entries)
          entree.key as String: entree.value as int,
      },
    );
  }

  // Les causes les plus marquées des difficultés de recrutement : les plus fortes d'abord, puis dans l'ordre de Data
  // Emploi à égalité.
  List<String> get principalesOrigines {
    final ordre = origines.keys.toList();
    final fortes = origines.entries.where((entree) => entree.value >= 75).toList()
      ..sort((a, b) {
        final force = b.value.compareTo(a.value);
        return force != 0 ? force : ordre.indexOf(a.key).compareTo(ordre.indexOf(b.key));
      });
    return [for (final entree in fortes.take(2)) entree.key];
  }
}

class MarcheTravail {
  const MarcheTravail({
    required this.typeTerritoire,
    required this.codeTerritoire,
    required this.nomTerritoire,
    required this.ville,
    required this.codeInseeVille,
    required this.periodeOffres,
    required this.metiers,
    required this.metiersProches,
  });

  // Seuil retenu pour le POC : au moins 100 offres en un an sur le territoire.
  static const seuilCaRecrute = 100;

  final String typeTerritoire;
  final String codeTerritoire;
  final String nomTerritoire;
  final String ville;
  final String codeInseeVille;
  final String periodeOffres;
  final Map<String, ChiffresMetier> metiers;
  final Map<String, List<RomeMetierResume>> metiersProches;

  factory MarcheTravail.fromJson(dynamic json) {
    final territoire = json['territoire'];
    return MarcheTravail(
      typeTerritoire: territoire['type'] as String,
      codeTerritoire: territoire['code'] as String,
      nomTerritoire: territoire['nom'] as String,
      ville: territoire['ville'] as String,
      codeInseeVille: territoire['codeInseeVille'] as String,
      periodeOffres: json['periodes']['offres'] as String,
      metiers: {
        for (final entree in (json['metiers'] as Map).entries)
          entree.key as String: ChiffresMetier.fromJson(entree.value),
      },
      metiersProches: {
        for (final entree in (json['metiersProches'] as Map).entries)
          entree.key as String: [
            for (final proche in entree.value as List)
              RomeMetierResume(code: proche['code'] as String, libelle: proche['libelle'] as String),
          ],
      },
    );
  }

  ChiffresMetier? chiffres(String code) => metiers[code];

  bool caRecrute(String code) => (chiffres(code)?.offres12Mois ?? 0) >= seuilCaRecrute;

  String lienDataEmploi(String codeRome) => lienDataEmploiMetier(typeTerritoire, codeTerritoire, codeRome);
}

// Page publique Data Emploi d'un métier sur un territoire (marche sans abonnement à l'API).
String lienDataEmploiMetier(String typeTerritoire, String codeTerritoire, String codeRome) {
  return 'https://dataemploi.francetravail.fr/emploi/metier/chiffres-cles/$typeTerritoire/$codeTerritoire/$codeRome';
}

// Département d'une commune à partir de son code Insee : 3 caractères outre-mer (974…), 2 sinon (59, 2A…).
String? departementDe(String? codeInsee) {
  if (codeInsee == null || codeInsee.length != 5) return null;
  return codeInsee.startsWith('97') ? codeInsee.substring(0, 3) : codeInsee.substring(0, 2);
}

// En démo, les chiffres viennent du fichier relevé sur Data Emploi : aucun appel réseau. Pour un vrai compte, le POC
// n'a pas encore l'API Marché du travail (pas d'abonnement) : la fiche propose seulement le lien vers Data Emploi.
class MarcheTravailDemo {
  // rootBundle garde déjà le fichier en mémoire après la première lecture.
  static Future<MarcheTravail> charger() {
    return rootBundle
        .loadString('assets/mode_demo/poc_orientation_marche_travail.json')
        .then((texte) => MarcheTravail.fromJson(jsonDecode(texte)));
  }
}
