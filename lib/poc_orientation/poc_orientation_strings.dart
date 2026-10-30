class PocOrientationStrings {
  static String prototype = "Prototype";
  static String sourceRome = "Source : ROME 4.0, France Travail";
  static String chargement = "Chargement";
  static String erreur = "Impossible de joindre le service. Vérifie ta connexion et réessaie.";
  static String reessayer = "Réessayer";
  static String voirPlus = "Voir plus de métiers";
  static String nombreMetiers(int nombre) => nombre > 1 ? "$nombre métiers" : "$nombre métier";

  static String carteTitre = "Explorer les métiers";
  static String carteDescription = "Trouve des idées, découvre un métier et teste-le";

  static String hubTitre = "Explorer les métiers";
  static String hubIntro =
      "Trouve des idées de métiers, découvre en quoi ils consistent, puis teste-les en immersion ou trouve une formation.";
  static String hubMetierEnTete = "Tu as déjà un métier en tête ?";
  static String hubMetierChamp = "Métier";
  static String hubMetierAide = "Exemple : boulanger, aide-soignant, développeur";
  static String hubPasEncore = "Tu ne sais pas encore ?";
  static String hubTestTitre = "Faire le test RIASEC";
  static String hubTestDescription = "30 questions, environ 4 minutes, pour découvrir ton profil";
  static String hubCentresTitre = "Partir de mes centres d’intérêt";
  static String hubCentresDescription = "Choisis ce que tu aimes, on te propose des métiers";
  static String hubMesMetiers = "Mes métiers";
  static String hubMesMetiersVide = "Ajoute des métiers depuis leur fiche pour les retrouver ici.";

  static String centresTitre = "Mes centres d’intérêt";
  static String centresIntro = "Choisis jusqu’à 3 centres d’intérêt.";
  static String centresSelection(int nombre) => "$nombre sur 3 choisis";
  static String centresVoirMetiers = "Voir les métiers";
  static String centresMetiersTitre = "Métiers pour toi";
  static String centresMetiersIntro(List<String> centres) => "Si tu aimes : ${centres.join(", ")}.";
  static String centresEnCommun(int nombre) =>
      nombre > 1 ? "$nombre de tes centres d’intérêt" : "1 de tes centres d’intérêt";

  static String testTitre = "Test RIASEC";
  static String testIntroTitre = "Découvre ton profil";
  static List<String> testIntroPoints = [
    "30 questions, environ 4 minutes.",
    "Il n’y a pas de bonne ou de mauvaise réponse.",
    "Réponds selon ce que tu aimerais faire, pas selon ce que tu sais déjà faire.",
    "Tu obtiens des pistes de métiers à explorer, et à discuter avec ton conseiller si tu en as un.",
  ];
  static String testCommencer = "Commencer le test";
  static String testConsigne = "Est-ce que tu aimerais…";
  static String testJaime = "J’aime";
  static String testCaDepend = "Ça dépend";
  static String testJaimePas = "Je n’aime pas";
  static String testPrecedente = "Question précédente";
  static String testAvertissement =
      "Test de démonstration : les questions sont à faire valider par des professionnels de l’orientation.";

  static String resultatTitre = "Ton profil";
  static String resultatProfil(List<String> noms, {required bool egaliteEnTete}) {
    if (egaliteEnTete) return "Tu es autant ${_enumeration(noms)}";
    if (noms.length > 2) return "Tu es plutôt ${noms.first}, puis ${noms.skip(1).join(" ou ")}";
    return "Tu es plutôt ${noms.join(" et ")}";
  }

  static String _enumeration(List<String> noms) {
    if (noms.length == 2) return "${noms.first} que ${noms.last}";
    return "${noms.take(noms.length - 1).join(", ")} que ${noms.last}";
  }

  static String resultatPlatTitre = "Aucun profil ne ressort vraiment";
  static String resultatPlatTexte =
      "Tes réponses sont très proches d’un profil à l’autre. Ce n’est pas grave : pars plutôt de tes centres d’intérêt, ou parles-en avec ton conseiller.";
  static String resultatScores = "Tes réponses";
  static String resultatMetiersTitre = "Des métiers qui te ressemblent";
  static String resultatExplication =
      "France Travail donne un profil RIASEC à chaque métier. Les plus proches du tien sont en premier.";
  static String resultatTousLesDomaines(int nombre) => "Tous ($nombre)";
  static String resultatDomaine(String domaine, int nombre) => "$domaine ($nombre)";
  static String resultatRefaire = "Refaire le test";
  static String profilDuMetier(List<String> noms) => "Profil ${noms.join(" et ")}";

  static String ficheTitre = "Fiche métier";
  static String ficheEnBref = "En bref";
  static String ficheQuotidien = "Au quotidien";
  static String ficheCompetences = "Les compétences clés";
  static String ficheQualites = "Les qualités utiles";
  static String ficheAcces = "Pour y accéder";
  static String ficheConditions = "Conditions de travail";
  static String ficheCentresInteret = "Si tu aimes…";
  static String ficheProfil = "Profil RIASEC";
  static String ficheAussiAppele = "Aussi appelé";
  static String ficheEtMaintenant = "Et maintenant ?";
  static String ficheVoirOffres = "Voir les offres d’emploi";
  static String ficheImmersion = "Tester ce métier en immersion";
  static String ficheAlternance = "Chercher une alternance";
  static String ficheSeFormer = "Se former à ce métier";
  static String ficheVoirFormations = "Voir les formations près de chez moi";
  static String ficheAutresSources = "Ailleurs sur internet";
  static String ficheFormationAlternance = "Formations en alternance (La bonne alternance)";
  static String ficheFormationContinue = "Formations pour demandeurs d’emploi (France Travail)";
  static String ficheFormationInitiale = "Études et formations initiales (Onisep)";
  static String ficheAjouter = "Ajouter à mes métiers";
  static String ficheRetirer = "Retirer de mes métiers";
  static String ficheReglemente = "Métier réglementé";
  static String ficheTransitionEcologique = "Transition écologique";
  static String ficheTransitionNumerique = "Numérique";
  static String ficheSource(String code) => "Source : fiche ROME $code, France Travail";

  static String formationsTitre = "Se former";
  static String formationsIntro =
      "Les formations du CAP au bac+2, en lycée professionnel ou en apprentissage, et ce que deviennent les jeunes 6 mois après.";
  static String formationsLieu = "Où ?";
  static String formationsLieuAide = "Ville ou département";
  static String formationsChoisirLieu = "Choisis une ville ou un département pour voir les formations près de chez toi.";
  static String formationsToutLeTerritoire = "Chercher dans toute la France";
  static String formationsAucune =
      "Aucune formation trouvée près de chez toi pour ce métier. InserJeunes ne suit que le lycée professionnel et l’apprentissage : regarde aussi les liens de la fiche métier.";
  static String formationsApprentissage = "En apprentissage";
  static String formationsLyceePro = "En lycée professionnel";
  static String formationsEmploi(int pourcentage) =>
      "$pourcentage % en emploi 6 mois après, parmi ceux qui arrêtent leurs études";
  static String formationsPoursuite(int pourcentage) => "$pourcentage % continuent leurs études";
  static String formationsNonPublie = "Résultats non publiés : trop peu d’élèves";
  static String formationsSource(String annee) =>
      "Source : InserJeunes (ministère de l’Éducation nationale et Dares), sortants $annee. Formations trouvées par mots-clés du métier : à vérifier.";
}
