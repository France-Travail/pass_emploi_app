import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

// Le résumé pour décider, tiré de la fiche ROME : une phrase sur ce qu'on fait, les conditions qui comptent, l'accès.

// La première ligne du « au quotidien » parle mieux qu'une définition générale.
String? phraseDuMetier(RomeFicheMetier fiche) => fiche.auQuotidien.firstOrNull ?? fiche.enBref;

// Du plus précis au plus général : « accessible avec un CAP » donne « un CAP », « accessible sans diplôme » donne
// « sans diplôme ».
const _debutsAcces = [
  'Cet emploi est accessible avec ',
  'Ce métier est accessible avec ',
  'Cet emploi est accessible à partir d\'',
  'Ce métier est accessible à partir d\'',
  'Cet emploi est accessible à partir d’',
  'Ce métier est accessible à partir d’',
  'Cet emploi est accessible ',
  'Ce métier est accessible ',
];

// « Cet emploi est accessible avec un CAP Boulanger ou un Brevet Professionnel Boulanger. Des … » donne
// « un CAP Boulanger ou un Brevet Professionnel Boulanger », à lire après « Accès : ».
String? resumeAcces(RomeFicheMetier fiche) {
  final premiere = fiche.acces.firstOrNull;
  if (premiere == null) return null;
  var phrase = premiere.split(RegExp(r'(?<=\.)\s+')).first.trim();
  for (final debut in _debutsAcces) {
    if (phrase.startsWith(debut)) {
      phrase = phrase.substring(debut.length);
      break;
    }
  }
  phrase = phrase.replaceAll(RegExp(r'\s+'), ' ').replaceAll(' ,', ',').replaceFirst(RegExp(r'\.$'), '').trim();
  if (phrase.isEmpty) return null;
  // Minuscule après les deux-points, sauf pour un sigle (« CAP ou BP »).
  final sigle = phrase.length > 1 && phrase[1] == phrase[1].toUpperCase() && phrase[1] != phrase[1].toLowerCase();
  return sigle ? phrase : phrase[0].toLowerCase() + phrase.substring(1);
}

// Libellés ROME des conditions de travail, raccourcis, des plus exigeantes aux plus douces.
const _conditions = [
  ('Travail de nuit', 'Travail de nuit'),
  ('Travail les week-ends et jours fériés', 'Week-ends et jours fériés'),
  ('Travail en horaires décalés', 'Horaires décalés'),
  ('Port et manipulation de charges lourdes ou encombrantes', 'Charges lourdes'),
  ('Station debout prolongée', 'Debout longtemps'),
  ('En zone frigorifique', 'Au froid'),
  ('Travail en extérieur', 'Dehors'),
  ('Déplacements professionnels', 'Déplacements'),
  ('Station assise prolongée', 'Assis longtemps'),
  ('Possibilité de télétravail', 'Télétravail possible'),
  ('Travail en journée', 'En journée'),
];

// Ce que le corps encaisse, dit simplement : pour relier le frein « santé » aux vraies conditions du métier.
const _effortsPhysiques = {
  'Port et manipulation de charges lourdes ou encombrantes': 'porter des charges lourdes',
  'Station debout prolongée': 'rester debout longtemps',
  'Travail de nuit': 'travailler la nuit',
  'En zone frigorifique': 'travailler au froid',
  'Travail en extérieur': 'travailler dehors',
};

List<String> _libellesDesConditions(RomeFicheMetier fiche) => [
  for (final groupe in fiche.contextes) ...groupe.libelles,
];

List<String> conditionsMarquantes(RomeFicheMetier fiche, {int maximum = 3}) {
  final libelles = _libellesDesConditions(fiche).toSet();
  return [
    for (final (libelle, court) in _conditions)
      if (libelles.contains(libelle)) court,
  ].take(maximum).toList();
}

List<String> effortsPhysiques(RomeFicheMetier fiche) {
  final libelles = _libellesDesConditions(fiche).toSet();
  return [
    for (final entree in _effortsPhysiques.entries)
      if (libelles.contains(entree.key)) entree.value,
  ];
}
