import 'dart:math';

import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

enum Riasec {
  realiste('R', 'Réaliste', 'Tu aimes le concret : fabriquer, réparer, bouger, travailler dehors.'),
  investigateur('I', 'Investigateur', 'Tu aimes comprendre : chercher, analyser, résoudre des problèmes.'),
  artiste('A', 'Artiste', 'Tu aimes créer : imaginer, dessiner, t’exprimer, inventer.'),
  social('S', 'Social', 'Tu aimes les autres : aider, soigner, expliquer, accompagner.'),
  entreprenant('E', 'Entreprenant', 'Tu aimes agir : convaincre, décider, vendre, lancer des projets.'),
  conventionnel('C', 'Conventionnel', 'Tu aimes que ce soit carré : organiser, classer, compter, suivre des règles.');

  const Riasec(this.lettre, this.nom, this.description);

  final String lettre;
  final String nom;
  final String description;

  static Riasec? deLettre(String? lettre) => values.where((type) => type.lettre == lettre).firstOrNull;
}

class RiasecQuestion {
  const RiasecQuestion(this.texte, this.type);

  final String texte;
  final Riasec type;
}

// 5 questions par profil, une seule activité par question, profils mélangés.
const riasecQuestions = [
  RiasecQuestion('Réparer un vélo ou un scooter', Riasec.realiste),
  RiasecQuestion('Comprendre comment marche le corps humain', Riasec.investigateur),
  RiasecQuestion('Dessiner ou peindre', Riasec.artiste),
  RiasecQuestion('Aider quelqu’un qui traverse une période difficile', Riasec.social),
  RiasecQuestion('Convaincre les autres de te suivre dans un projet', Riasec.entreprenant),
  RiasecQuestion('Ranger et classer des documents', Riasec.conventionnel),
  RiasecQuestion('Travailler dehors, quel que soit le temps', Riasec.realiste),
  RiasecQuestion('Faire des expériences scientifiques', Riasec.investigateur),
  RiasecQuestion('Faire de la musique ou chanter', Riasec.artiste),
  RiasecQuestion('Expliquer une leçon à quelqu’un', Riasec.social),
  RiasecQuestion('Vendre un produit à un client', Riasec.entreprenant),
  RiasecQuestion('Tenir un budget ou des comptes', Riasec.conventionnel),
  RiasecQuestion('Construire ou monter un meuble', Riasec.realiste),
  RiasecQuestion('Chercher la cause d’une panne', Riasec.investigateur),
  RiasecQuestion('Prendre des photos ou monter des vidéos', Riasec.artiste),
  RiasecQuestion('T’occuper d’enfants', Riasec.social),
  RiasecQuestion('Diriger une équipe', Riasec.entreprenant),
  RiasecQuestion('Remplir des tableaux avec soin', Riasec.conventionnel),
  RiasecQuestion('Conduire un engin ou une machine', Riasec.realiste),
  RiasecQuestion('Résoudre des énigmes ou des casse-têtes', Riasec.investigateur),
  RiasecQuestion('Écrire des histoires, des textes ou des chansons', Riasec.artiste),
  RiasecQuestion('Prendre soin de personnes âgées ou malades', Riasec.social),
  RiasecQuestion('Lancer ton propre projet ou ton entreprise', Riasec.entreprenant),
  RiasecQuestion('Suivre une procédure précise, étape par étape', Riasec.conventionnel),
  RiasecQuestion('Travailler de tes mains avec des outils', Riasec.realiste),
  RiasecQuestion('Te renseigner à fond sur un sujet qui t’intéresse', Riasec.investigateur),
  RiasecQuestion('Décorer un lieu ou créer des vêtements', Riasec.artiste),
  RiasecQuestion('Accueillir et renseigner des gens', Riasec.social),
  RiasecQuestion('Négocier un prix ou un accord', Riasec.entreprenant),
  RiasecQuestion('Vérifier qu’il n’y a pas d’erreur dans un travail', Riasec.conventionnel),
];

enum RiasecReponse {
  jaime(2),
  caDepend(1),
  jaimePas(0);

  const RiasecReponse(this.points);

  final int points;
}

class RiasecProfil {
  RiasecProfil._(this.scores, this.ordre);

  static const scoreMaximum = 10;

  // Un métier est retenu s'il atteint 85 % de la meilleure adéquation trouvée pour ce profil.
  static const _seuilAdequation = 0.85;

  final Map<Riasec, int> scores;
  final List<Riasec> ordre;

  factory RiasecProfil.depuis(List<RiasecReponse?> reponses) {
    final scores = {for (final type in Riasec.values) type: 0};
    for (var i = 0; i < riasecQuestions.length; i++) {
      final type = riasecQuestions[i].type;
      scores[type] = scores[type]! + (reponses[i]?.points ?? 0);
    }
    final ordre = [...Riasec.values]
      ..sort((a, b) {
        final ecart = scores[b]!.compareTo(scores[a]!);
        return ecart != 0 ? ecart : a.index.compareTo(b.index);
      });
    return RiasecProfil._(scores, ordre);
  }

  // Aucun profil ne se détache : tout bas (rien ne plaît) ou tout haut (tout plaît).
  bool get estPlat => scores[ordre.first]! - scores[ordre.last]! <= 2;

  // Les 2 profils dominants, plus un 3e s'il est à égalité avec le 2e.
  List<Riasec> get dominants {
    final deuxieme = scores[ordre[1]]!;
    return [ordre[0], ordre[1], if (scores[ordre[2]] == deuxieme) ordre[2]];
  }

  bool get egaliteEnTete => scores[ordre[0]] == scores[ordre[1]];

  // Proximité (cosinus) entre le profil du jeune et celui du métier, où la lettre principale compte double :
  // un métier qui partage les deux dominantes du jeune passe devant un métier qui n'en partage qu'une.
  double adequation(RomeMetierResume metier) {
    final majeur = Riasec.deLettre(metier.riasecMajeur);
    if (majeur == null) return 0;
    final mineur = Riasec.deLettre(metier.riasecMineur);
    final poids = {majeur: 2, if (mineur != null && mineur != majeur) mineur: 1};
    final produit = poids.entries.fold<int>(0, (somme, entree) => somme + entree.value * scores[entree.key]!);
    final normeProfil = sqrt(scores.values.fold<int>(0, (somme, score) => somme + score * score));
    final normeMetier = sqrt(poids.values.fold<int>(0, (somme, valeur) => somme + valeur * valeur));
    return normeProfil == 0 ? 0 : produit / (normeProfil * normeMetier);
  }

  // Les meilleurs métiers d'abord ; à adéquation égale, les domaines alternent pour éviter 20 métiers voisins.
  List<RomeMetierResume> metiersCorrespondants(List<RomeMetierResume> metiers) {
    final adequations = {for (final metier in metiers) metier.code: adequation(metier)};
    final meilleure = adequations.values.fold<double>(0, max);
    if (meilleure == 0) return [];
    final notes = {for (final entree in adequations.entries) entree.key: entree.value / meilleure};
    final retenus = metiers.where((metier) => notes[metier.code]! >= _seuilAdequation).toList()
      ..sort((a, b) {
        final ecart = notes[b.code]!.compareTo(notes[a.code]!);
        return ecart != 0 ? ecart : a.libelle.compareTo(b.libelle);
      });
    return _alternerLesDomaines(retenus, notes);
  }

  static List<RomeMetierResume> _alternerLesDomaines(List<RomeMetierResume> tries, Map<String, double> notes) {
    final resultat = <RomeMetierResume>[];
    var debut = 0;
    while (debut < tries.length) {
      final palier = (notes[tries[debut].code]! * 20).round();
      var fin = debut;
      while (fin < tries.length && (notes[tries[fin].code]! * 20).round() == palier) {
        fin++;
      }
      final parDomaine = <String?, List<RomeMetierResume>>{};
      for (final metier in tries.sublist(debut, fin)) {
        parDomaine.putIfAbsent(metier.grandDomaine, () => []).add(metier);
      }
      final files = parDomaine.values.toList();
      for (var rang = 0; files.any((file) => rang < file.length); rang++) {
        for (final file in files) {
          if (rang < file.length) resultat.add(file[rang]);
        }
      }
      debut = fin;
    }
    return resultat;
  }
}
