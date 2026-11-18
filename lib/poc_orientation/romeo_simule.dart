import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

// En vrai, l'API ROMEO de France Travail rapproche un intitulé libre (titre d'offre, recherche, « métier ou secteur »
// tapé au questionnaire) d'un métier ROME, avec un score. Le POC n'y est pas abonné : cette table faite à la main couvre
// les données de la démo et quelques mots courants. Un intitulé trop vague (« Vendeur ») ou inconnu n'est pas proposé,
// comme ROMEO l'écarterait faute de score suffisant.
const _libelles = {
  'A1101': 'Conducteur / Conductrice d\'engins agricoles',
  'C1201': 'Chargé / Chargée d\'accueil et de services clientèle bancaire',
  'D1102': 'Boulanger / Boulangère',
  'D1104': 'Pâtissier / Pâtissière',
  'D1202': 'Coiffeur / Coiffeuse',
  'D1212': 'Vendeur / Vendeuse en équipement de la maison',
  'D1401': 'Assistant commercial / Assistante commerciale',
  'D1502': 'Chef / Cheffe de rayon produits alimentaires',
  'D1507': 'Employé / Employée de rayon libre-service',
  'G1603': 'Equipier polyvalent / Equipière polyvalente de restauration rapide',
};

// Morceaux cherchés dans l'intitulé, sans accents ni majuscules.
const _correspondances = [
  ('libre-service', 'D1507'),
  ('libre service', 'D1507'),
  ('rayon produits alimentaires', 'D1502'),
  ('electromenager', 'D1212'),
  ('equipement de la maison', 'D1212'),
  ('banque', 'C1201'),
  ('bancaire', 'C1201'),
  ('assistant commercial', 'D1401'),
  ('assistante commerciale', 'D1401'),
  ('engins agricoles', 'A1101'),
  ('engins d\'exploitations agricoles', 'A1101'),
  ('coiffeu', 'D1202'),
  ('coiffure', 'D1202'),
  ('restauration rapide', 'G1603'),
  ('boulang', 'D1102'),
  ('patiss', 'D1104'),
];

RomeMetierResume? romeoSimule(String? intitule) {
  if (intitule == null) return null;
  final texte = _normaliser(intitule);
  for (final (morceau, code) in _correspondances) {
    if (texte.contains(morceau)) return metierConnu(code);
  }
  return null;
}

// Un code ROME déjà connu (recherche d'immersion, parcours France Travail) n'a pas besoin de ROMEO.
RomeMetierResume metierConnu(String code, {String? libelle}) {
  return RomeMetierResume(code: code, libelle: _libelles[code] ?? libelle ?? code);
}

const _sansAccents = {
  'à': 'a', 'â': 'a', 'ä': 'a', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'î': 'i', 'ï': 'i', //
  'ô': 'o', 'ö': 'o', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ç': 'c', 'œ': 'oe', '’': '\'',
};

String _normaliser(String texte) {
  final minuscules = texte.toLowerCase();
  final buffer = StringBuffer();
  for (final caractere in minuscules.split('')) {
    buffer.write(_sansAccents[caractere] ?? caractere);
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}
