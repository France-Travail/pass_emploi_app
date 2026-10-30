import 'package:dio/dio.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

class FormationInserJeunes {
  final String uai;
  final String etablissement;
  final String typeDiplome;
  final String libelleFormation;
  final String annee;
  final bool apprentissage;
  final double? tauxEmploi6Mois;
  final double? tauxPoursuiteEtudes;

  const FormationInserJeunes({
    required this.uai,
    required this.etablissement,
    required this.typeDiplome,
    required this.libelleFormation,
    required this.annee,
    required this.apprentissage,
    required this.tauxEmploi6Mois,
    required this.tauxPoursuiteEtudes,
  });

  factory FormationInserJeunes.fromJson(dynamic json, {required bool apprentissage}) {
    return FormationInserJeunes(
      uai: json['uai'] as String,
      etablissement: json['libelle'] as String,
      typeDiplome: json['type_diplome'] as String? ?? '',
      libelleFormation: json['libelle_formation'] as String? ?? '',
      annee: (json['annee'] as String? ?? '').replaceFirst('cumul ', ''),
      apprentissage: apprentissage,
      tauxEmploi6Mois: (json['taux_emploi_6_mois'] as num?)?.toDouble(),
      tauxPoursuiteEtudes: (json['taux_poursuite_etudes'] as num?)?.toDouble(),
    );
  }

  String get diplome {
    final libelle = libelleFormation.isEmpty ? '' : libelleFormation[0].toUpperCase() + libelleFormation.substring(1);
    return '${_typesDiplome[_type] ?? typeDiplome} $libelle'.trim();
  }

  // Les titres professionnels portent une lettre de nomenclature après leur niveau (« TH5 X ») : on l'ignore.
  String get _type => typeDiplome.replaceFirstMapped(RegExp(r'^(TH\d) [A-Z]$'), (titre) => titre.group(1)!);

  // Le même diplôme est parfois écrit avec ou sans tiret (« estheticien-cosmeticien ») selon l'établissement.
  String get cleDiplome {
    final libelle = libelleFormation.toLowerCase().replaceAll('-', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    return '$_type|$libelle';
  }

  bool get aDesResultats => tauxEmploi6Mois != null || (tauxPoursuiteEtudes ?? 0) > 0;

  int get rangDiplome {
    final rang = _ordreDiplomes.indexOf(_type);
    return rang == -1 ? _ordreDiplomes.length : rang;
  }

  String get _cle => '$uai|$typeDiplome|$libelleFormation';

  static const _typesDiplome = {
    'CAP': 'CAP',
    'CAPA': 'CAP agricole',
    'BP': 'Brevet professionnel',
    'BPA': 'Brevet professionnel agricole',
    'MC3': 'Mention complémentaire',
    'MC4': 'Mention complémentaire',
    'BAC PRO': 'Bac pro',
    'BAC PRO AG': 'Bac pro agricole',
    'BMA': 'Brevet des métiers d’art',
    'BM': 'Brevet de maîtrise',
    'CS3': 'Certificat de spécialisation',
    'CS4': 'Certificat de spécialisation',
    'BTS': 'BTS',
    'BTSA': 'BTS agricole',
    'DIV 3': 'Diplôme niveau CAP :',
    'DIV 4': 'Diplôme niveau bac :',
    'DIV 5': 'Diplôme bac+2 :',
    'TH3': 'Titre professionnel niveau CAP :',
    'TH4': 'Titre professionnel niveau bac :',
    'TH5': 'Titre professionnel bac+2 :',
    'TH6': 'Titre professionnel bac+3/4 :',
    'TH7': 'Titre professionnel bac+5 :',
  };

  static const _ordreDiplomes = [
    'CAP',
    'CAPA',
    'MC3',
    'CS3',
    'DIV 3',
    'TH3',
    'BP',
    'BPA',
    'BAC PRO',
    'BAC PRO AG',
    'MC4',
    'CS4',
    'BMA',
    'BM',
    'DIV 4',
    'TH4',
    'BTS',
    'BTSA',
    'DIV 5',
    'TH5',
    'TH6',
    'TH7',
  ];
}

// Département d'une ville (code INSEE) ou d'un département choisi dans l'app.
String? departementDe(Location? lieu) {
  if (lieu == null) return null;
  if (lieu.type == LocationType.DEPARTMENT) return lieu.code;
  return lieu.code.startsWith('97') ? lieu.code.substring(0, 3) : lieu.code.substring(0, 2);
}

// Les 3 premiers caractères d'un code UAI d'établissement sont ceux de son département (620 et 720 pour la Corse).
String _prefixeUai(String departement) {
  return switch (departement) {
    '2A' => '620',
    '2B' => '720',
    _ => departement.length == 2 ? '0$departement' : departement,
  };
}

final _diplomesCites = RegExp(
  r"\b(?:CAP|Bac pro(?:fessionnel)?|Baccalauréat professionnel|BP|Brevet professionnel|BTS|Mention complémentaire|MC|BMA)\s+(?:«\s*)?(?:en\s+|de\s+|du\s+|des\s+|d['’]\s*)?([A-Za-zÀ-ÖØ-öø-ÿ'’ -]{3,60})",
  caseSensitive: false,
);
final _finDeSpecialite = RegExp(r"\s+(?:ou|et|avec|dans|en|pour|peut|peuvent|est|sont|à|au|de niveau)\s+|[,;.()»]");
const _motsGeneriques = {
  'spécialisation',
  'spécialité',
  'spécialisé',
  'spécialisée',
  'option',
  'mention',
  'niveau',
  'diplôme',
  'gestion',
  'technique',
  'techniques',
  'pratique',
  'formation',
  'métier',
  'métiers',
  'soin',
  'soins',
  'agent',
  'agente',
  'aide',
  'assistant',
  'assistante',
  'chef',
  'cheffe',
  'responsable',
  'technicien',
  'technicienne',
  'opérateur',
  'opératrice',
  'employé',
  'employée',
  'chargé',
  'chargée',
  'conseiller',
  'conseillère',
  'ouvrier',
  'ouvrière',
  'directeur',
  'directrice',
  'gestionnaire',
};

// InserJeunes ne connaît pas les codes métier. On cherche le nom du métier, le domaine de formation de la fiche ROME
// (« Esthétique soin corporel ») et les diplômes cités dans « Pour y accéder » (« CAP Boulanger »).
List<String> motsClesFormation(RomeFicheMetier fiche) {
  final mots = <String>{};
  void ajouter(String? mot) {
    if (mot != null && mot.length >= 4) mots.add(_sansAccents(mot.toLowerCase()));
  }

  ajouter(_premierMotSignificatif(fiche.motCle));
  for (final domaine in fiche.domainesDeFormation) {
    ajouter(_premierMotSignificatif(domaine.split(RegExp(r' - |,')).first));
  }
  for (final ligne in fiche.acces) {
    for (final diplome in _diplomesCites.allMatches(ligne)) {
      final specialite = diplome.group(1)!.split(_finDeSpecialite).first.trim();
      if (_premierMotSignificatif(specialite) != null) ajouter(specialite);
    }
  }
  return mots.take(6).toList();
}

String? _premierMotSignificatif(String texte) {
  return texte
      .toLowerCase()
      .split(RegExp(r"[\s\-'’/]+"))
      .where((mot) => mot.length >= 4 && !_motsGeneriques.contains(mot))
      .firstOrNull;
}

String _sansAccents(String texte) {
  const avec = 'àâäéèêëîïôöùûüç';
  const sans = 'aaaeeeeiioouuuc';
  return texte.split('').map((lettre) {
    final position = avec.indexOf(lettre);
    return position == -1 ? lettre : sans[position];
  }).join();
}

class InserJeunesClient {
  InserJeunesClient._();

  static final instance = InserJeunesClient._();

  static const _jeuxDeDonnees = 'https://data.education.gouv.fr/api/explore/v2.1/catalog/datasets';
  static const _apprentissage = 'fr-en-inserjeunes-cfa-formation_fine';
  static const _lyceePro = 'fr-en-inserjeunes-lycee_pro-formation-fine';

  final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 30)));

  Future<List<FormationInserJeunes>> formations({required List<String> motsCles, required String? departement}) async {
    if (motsCles.isEmpty) return [];
    final recherche = motsCles.map((mot) => 'search(libelle_formation, "${mot.replaceAll('"', '')}")').join(' or ');
    final filtre = [
      if (departement != null) 'startswith(uai, "${_prefixeUai(departement)}")',
      '($recherche)',
    ].join(' and ');
    final resultats = await Future.wait([
      _chercher(_apprentissage, filtre, apprentissage: true),
      _chercher(_lyceePro, filtre, apprentissage: false),
    ]);
    return resultats.expand((formations) => formations).toList();
  }

  Future<List<FormationInserJeunes>> _chercher(String jeuDeDonnees, String filtre, {required bool apprentissage}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_jeuxDeDonnees/$jeuDeDonnees/records',
      queryParameters: {'where': filtre, 'order_by': 'annee desc', 'limit': 100},
    );
    final dejaVues = <String>{};
    final formations = <FormationInserJeunes>[];
    for (final json in response.data!['results'] as List<dynamic>) {
      final formation = FormationInserJeunes.fromJson(json, apprentissage: apprentissage);
      // Résultats du plus récent au plus ancien : on garde la dernière promotion connue de chaque formation.
      if (dejaVues.add(formation._cle)) formations.add(formation);
    }
    return formations;
  }
}
