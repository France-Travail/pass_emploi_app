import 'package:equatable/equatable.dart';

// ROME renvoie ses retours à la ligne échappés (« \n » littéral) dans les textes.
final _retourALaLigne = RegExp(r'\\n|\n');

List<String> _lignes(String? texte) {
  if (texte == null) return [];
  return texte.split(_retourALaLigne).map((ligne) => ligne.trim()).where((ligne) => ligne.isNotEmpty).toList();
}

List<String> _libelles(Iterable<dynamic>? json) {
  if (json == null) return [];
  return json.map((element) => element['libelle'] as String).toSet().toList();
}

class RomeCentreInteret extends Equatable {
  final String code;
  final String libelle;

  const RomeCentreInteret({required this.code, required this.libelle});

  factory RomeCentreInteret.fromJson(dynamic json) {
    return RomeCentreInteret(code: json['code'] as String, libelle: json['libelle'] as String);
  }

  @override
  List<Object?> get props => [code, libelle];
}

class RomeMetierResume extends Equatable {
  final String code;
  final String libelle;
  final String? riasecMajeur;
  final String? riasecMineur;
  final String? grandDomaine;

  const RomeMetierResume({
    required this.code,
    required this.libelle,
    this.riasecMajeur,
    this.riasecMineur,
    this.grandDomaine,
  });

  factory RomeMetierResume.fromJson(dynamic json) {
    final grandDomaine = json['domaineProfessionnel']?['grandDomaine'];
    return RomeMetierResume(
      code: json['code'] as String,
      libelle: json['libelle'] as String,
      riasecMajeur: _lettreOuNull(json['riasecMajeur'] as String?),
      riasecMineur: _lettreOuNull(json['riasecMineur'] as String?),
      grandDomaine: grandDomaine == null
          ? null
          : _grandsDomainesCourts[grandDomaine['code']] ?? grandDomaine['libelle'] as String?,
    );
  }

  static String? _lettreOuNull(String? lettre) => (lettre == null || lettre.isEmpty) ? null : lettre;

  static const _grandsDomainesCourts = {
    'A': 'Agriculture, nature, animaux',
    'B': 'Artisanat d’art',
    'C': 'Banque, assurance, immobilier',
    'D': 'Commerce, vente',
    'E': 'Communication, médias',
    'F': 'Bâtiment, travaux publics',
    'G': 'Hôtellerie, restauration, tourisme',
    'H': 'Industrie',
    'I': 'Installation, maintenance',
    'J': 'Santé',
    'K': 'Services à la personne',
    'L': 'Spectacle',
    'M': 'Support à l’entreprise',
    'N': 'Transport, logistique',
  };

  @override
  List<Object?> get props => [code, libelle, riasecMajeur, riasecMineur, grandDomaine];
}

class RomeContextesTravail {
  final String categorie;
  final List<String> libelles;

  const RomeContextesTravail({required this.categorie, required this.libelles});

  static const _categories = {
    'CONDITIONS_TRAVAIL': 'Conditions',
    'HORAIRE_ET_DUREE_TRAVAIL': 'Horaires',
    'LIEU_ET_DEPLACEMENT': 'Lieux et déplacements',
    'STATUT_EMPLOI': 'Statut',
    'TYPE_STRUCTURE_ACCUEIL': 'Où travailler',
    'TYPE_BENEFICIAIRE': 'Auprès de qui',
    'PUBLIC_SPECIFIQUE': 'Publics',
  };

  static List<RomeContextesTravail> grouper(Iterable<dynamic>? json) {
    final parCategorie = <String, List<String>>{};
    for (final contexte in json ?? const []) {
      final code = contexte['categorie'] as String? ?? '';
      final categorie = _categories[code] ?? _lisible(code);
      parCategorie.putIfAbsent(categorie, () => []).add(contexte['libelle'] as String);
    }
    return [
      for (final entree in parCategorie.entries) RomeContextesTravail(categorie: entree.key, libelles: entree.value),
    ];
  }

  static String _lisible(String code) {
    if (code.isEmpty) return 'Autres';
    final mots = code.toLowerCase().replaceAll('_', ' ');
    return mots[0].toUpperCase() + mots.substring(1);
  }
}

class RomeFicheMetier {
  final String code;
  final String libelle;
  final String? enBref;
  final List<String> auQuotidien;
  final List<String> acces;
  final String? riasecMajeur;
  final String? riasecMineur;
  final String? domaine;
  final List<String> appellations;
  final List<String> centresInteret;
  final List<String> competences;
  final List<String> qualites;
  final List<RomeContextesTravail> contextes;
  final List<String> domainesDeFormation;
  final bool emploiReglemente;
  final bool transitionEcologique;
  final bool transitionNumerique;

  const RomeFicheMetier({
    required this.code,
    required this.libelle,
    required this.enBref,
    required this.auQuotidien,
    required this.acces,
    required this.riasecMajeur,
    required this.riasecMineur,
    required this.domaine,
    required this.appellations,
    required this.centresInteret,
    required this.competences,
    required this.qualites,
    required this.contextes,
    required this.domainesDeFormation,
    required this.emploiReglemente,
    required this.transitionEcologique,
    required this.transitionNumerique,
  });

  factory RomeFicheMetier.fromJson(dynamic json) {
    final libelle = json['libelle'] as String;
    final definition = _lignes(json['definition'] as String?);
    final competencesMobilisees = json['competencesMobilisees'] as List<dynamic>? ?? const [];
    return RomeFicheMetier(
      code: json['code'] as String,
      libelle: libelle,
      enBref: definition.isEmpty ? null : definition.first,
      auQuotidien: definition.skip(1).toList(),
      acces: _lignes(json['accesEmploi'] as String?),
      riasecMajeur: json['riasecMajeur'] as String?,
      riasecMineur: json['riasecMineur'] as String?,
      domaine: json['domaineProfessionnel']?['libelle'] as String?,
      appellations: _appellations(json['appellations'] as List<dynamic>?, libelle),
      centresInteret: _centresInteret(json),
      competences: _libelles(json['competencesMobiliseesPrincipales'] as List<dynamic>?).take(8).toList(),
      qualites: _libelles(competencesMobilisees.where((c) => c['type'] == 'MACRO-SAVOIR-ETRE-PROFESSIONNEL')),
      contextes: RomeContextesTravail.grouper(json['contextesTravail'] as List<dynamic>?),
      domainesDeFormation: _libelles(json['formacodes'] as List<dynamic>?),
      emploiReglemente: json['emploiReglemente'] == true,
      transitionEcologique: json['transitionEcologique'] == true,
      transitionNumerique: json['transitionNumerique'] == true,
    );
  }

  RomeMetierResume get resume {
    return RomeMetierResume(code: code, libelle: libelle, riasecMajeur: riasecMajeur, riasecMineur: riasecMineur);
  }

  // « Développeur / Développeuse informatique » donne « Développeur informatique » : la recherche d'offres
  // par mot-clé trouve mieux un intitulé sans la forme double.
  String get motCle {
    final formeDouble = RegExp(r'^(.+?) / \S+(.*)$').firstMatch(libelle);
    return formeDouble == null ? libelle : '${formeDouble.group(1)}${formeDouble.group(2)}';
  }

  static List<String> _appellations(List<dynamic>? json, String libelleMetier) {
    return _libelles(json).where((appellation) => appellation != libelleMetier).take(8).toList();
  }

  static List<String> _centresInteret(dynamic json) {
    final lies = json['centresInteretsLies'] as List<dynamic>?;
    if (lies == null || lies.isEmpty) return _libelles(json['centresInterets'] as List<dynamic>?);
    final principauxDabord = [...lies]..sort((a, b) => (b['principal'] == true ? 1 : 0) - (a['principal'] == true ? 1 : 0));
    return principauxDabord.map((lie) => lie['centreInteret']['libelle'] as String).toList();
  }
}
