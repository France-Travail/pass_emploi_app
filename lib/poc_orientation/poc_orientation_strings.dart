import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';

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
  static String hubMetierDemo = "Démo : seul ce métier est disponible";
  static String hubPasEncore = "Tu ne sais pas encore ?";
  static String hubTestTitre = "Faire le test RIASEC";
  static String hubTestDescription = "30 questions, environ 4 minutes, pour découvrir ton profil";
  static String hubCentresTitre = "Partir de mes centres d’intérêt";
  static String hubCentresDescription = "Choisis ce que tu aimes, on te propose des métiers";
  static String hubMesPistes = "Mes pistes de métiers";
  static String hubMesPistesVide =
      "Quand un métier te tente, dis-le depuis sa fiche : il arrive ici. On t’aide ensuite à le découvrir, à le tester puis à t’y former, étape par étape.";
  static String hubMisDeCote(int nombre) => "Mis de côté ($nombre)";
  static String hubTonProfil(List<String> noms) => "Ton profil au test : ${_liste(noms)}";
  static String hubRevoirResultats = "Revoir mes résultats";
  static String hubPartager = "Partager à mon conseiller";

  static String pisteOuJenSuis(EtapePiste? etape) => switch (etape) {
        EtapePiste.decouvrir => "Tu le découvres",
        EtapePiste.tester => "Tu le testes",
        EtapePiste.seFormer => "Tu regardes les formations",
        null => "Toutes les étapes sont faites",
      };
  static String pisteProgression(int faites, int total) => "$faites étape${faites > 1 ? "s" : ""} sur $total";
  static String pisteProchaineEtape(ActionPiste action) => "Prochaine étape : ${actionTitre(action).toLowerCase()}";
  static String pisteALancer = "Prochaine étape : te lancer, avec les offres d’emploi ou d’alternance";
  static String pisteDansMesPistes = "Dans mes pistes";
  static String pisteMiseDeCote = "Mis de côté";
  static String pisteRaisons(Set<RaisonPasPourMoi> raisons) => raisons.map((raison) => raison.libelle).join(" · ");

  static String avisTitre = "Ce métier te tente ?";
  static String avisMeTente = "Ça me tente";
  static String avisPasPourMoi = "Pas pour moi";
  static String avisDansMesPistes = "Il est dans tes pistes. Suis les étapes plus bas pour avancer.";
  static String avisMisDeCote = "Tu l’as mis de côté.";
  static String avisMisDeCoteRaisons(Set<RaisonPasPourMoi> raisons) =>
      "Tu l’as mis de côté : ${pisteRaisons(raisons).toLowerCase()}.";

  static String raisonsTitre = "Pas pour toi ?";
  static String raisonsQuestion = "Qu’est-ce qui ne te convient pas ?";
  static String raisonsIntro = "Facultatif. Tu peux en choisir plusieurs : ça t’aidera à mieux cibler tes pistes.";
  static String raisonsValider = "Mettre de côté";
  static String raisonsAnnuler = "Annuler";

  static String apresTestTitre = "Alors ?";
  static String apresTestQuestion(String metier) => "Après ce test, le métier « $metier » te tente toujours ?";
  static String apresTestOui = "Oui, je continue";
  static String apresTestNon = "Non, plus vraiment";

  static String etapesTitre = "Avancer sur ce métier";
  static String etapesHorsPiste = "Dis « Ça me tente » plus haut pour suivre tes étapes et les retrouver dans tes pistes.";
  static String etapesProgression(int faites, int total) => "Tu as fait ${pisteProgression(faites, total)}.";
  static String etapeTitre(EtapePiste etape) => switch (etape) {
        EtapePiste.decouvrir => "1. Découvrir",
        EtapePiste.tester => "2. Tester",
        EtapePiste.seFormer => "3. Se former",
      };
  static String etapeSeLancer = "4. Se lancer";
  static String actionTitre(ActionPiste action) => switch (action) {
        ActionPiste.lireFiche => "Lire la fiche métier",
        ActionPiste.voirVideo => "Voir le métier en vidéo",
        ActionPiste.echangerAvecUnPro => "Échanger avec un pro",
        ActionPiste.faireUneImmersion => "Faire une immersion",
        ActionPiste.regarderLesFormations => "Regarder les formations",
      };
  static String actionDescription(ActionPiste action) => switch (action) {
        ActionPiste.lireFiche => "Tu es dessus !",
        ActionPiste.voirVideo => "Des pros te montrent leur métier, sur Parcoursmétiers.tv",
        ActionPiste.echangerAvecUnPro =>
          "Pose tes questions à un pro, sur My Job Glasses (compte gratuit, connexion possible avec France Travail)",
        ActionPiste.faireUneImmersion => "Essaie le métier quelques jours dans une entreprise",
        ActionPiste.regarderLesFormations => "Près de chez toi, avec ce que deviennent les jeunes après",
      };
  static String actionFaite(ActionPiste action) => switch (action) {
        ActionPiste.lireFiche => "J’ai lu la fiche métier",
        ActionPiste.voirVideo => "J’ai regardé une vidéo",
        ActionPiste.echangerAvecUnPro => "J’ai échangé avec un pro",
        ActionPiste.faireUneImmersion => "J’ai fait une immersion",
        ActionPiste.regarderLesFormations => "J’ai regardé les formations",
      };

  static String partagerTitre = "Partager à mon conseiller";
  static String partagerIntro = "Ton conseiller recevra ce message dans ta messagerie :";
  static String partagerEnvoyer = "Envoyer";
  static String partagerDemo = "Démo : le message s’ajoute à la messagerie de la démo, rien n’est envoyé.";
  static String partagerSucces = "Message envoyé à ton conseiller";

  // Écrit au nom du jeune et lu par le conseiller : on vouvoie le conseiller.
  static String messageIntro = "Bonjour, je vous partage où j’en suis dans mes pistes de métiers.";
  static String messageQuiTentent = "Les métiers qui me tentent :";
  static String messageMisDeCote = "Les métiers que j’ai mis de côté :";
  static String messageOuJenSuis(EtapePiste? etape, int faites, int total) {
    final ouJenSuis = switch (etape) {
      EtapePiste.decouvrir => "je le découvre",
      EtapePiste.tester => "je le teste",
      EtapePiste.seFormer => "je regarde les formations",
      null => "j’ai fait toutes les étapes",
    };
    return "$ouJenSuis (${pisteProgression(faites, total)})";
  }

  static String messageProfil(List<String> noms) => "Mon profil au test RIASEC : ${_liste(noms)}.";

  // « Social et Réaliste », ou « Social, Réaliste et Artiste » quand trois profils sont à égalité.
  static String _liste(List<String> noms) {
    if (noms.length < 2) return noms.join();
    return "${noms.take(noms.length - 1).join(", ")} et ${noms.last}";
  }
  static String messageCentres(List<String> centres) => "Mes centres d’intérêt : ${centres.join(", ")}.";
  static String messageConclusion = "Pourrons-nous en parler ensemble ?";

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

  static String pistesPourToiTitre = "Des pistes pour toi";
  static String pistesPourToiIntro = "D’après ce que tu as déjà fait dans l’app. Dis-nous ce qui te tente.";
  static String pistesPourToiVoirPlus(int nombre) => nombre > 1 ? "Voir les $nombre autres pistes" : "Voir l’autre piste";
  static String pistesPourToiVoirMoins = "Voir moins de pistes";
  static String pistesProchesTitre = "Des métiers proches de tes pistes";
  static String caRecrute = "Ça recrute près de chez toi";
  static String hubPasEncoreQuestionnaire =
      "C’est ce que tu as répondu au questionnaire : commence par le test ou par tes centres d’intérêt.";

  static String raisonConseiller = "Ton conseiller te le suggère";
  static String raisonFranceTravail = "Tu l’as indiqué à France Travail";
  static String raisonParcoursDetail(String intitule, int? mois) => mois == null ? intitule : "$intitule, $mois mois";
  static String raisonParcours(String detail) => "Ton parcours France Travail : $detail";
  static String raisonQuestionnaire(String domaine) => "Tu as écrit « $domaine » dans ton questionnaire";
  static String raisonFavori(int nombre) => nombre > 1 ? "Tu as mis $nombre offres en favori" : "Tu as mis une offre en favori";
  static String raisonRecherche(int nombre) =>
      nombre > 1 ? "Tu as enregistré $nombre recherches" : "Tu as enregistré une recherche";
  static String raisonDiagoriente = "Tu l’avais aimé sur Diagoriente";
  static String raisonProche(String metiers) => "Proche de « $metiers », qui te tente";

  static String presTitre = "Près de chez toi";
  static String presTerritoire(String ville, String territoire) => "Autour de $ville ($territoire)";
  static String presOffres(String nombre) => "$nombre offres d’emploi en un an";
  static String presDemandeurs(String nombre) => "$nombre demandeurs d’emploi cherchent ce métier";
  static String presCdi(int pourcentage) => "$pourcentage % des embauches se font en CDI";
  static String presSalaire(String min, String max) => "Salaire proposé : souvent entre $min € et $max € brut par mois";
  static String presAcces(int pourcentage) =>
      "$pourcentage % des demandeurs d’emploi de ce métier retrouvent un emploi en moins de 6 mois";
  static String presDifficulte(DifficulteRecrutement difficulte) => switch (difficulte) {
        DifficulteRecrutement.tresFaible ||
        DifficulteRecrutement.faible =>
          "Les entreprises trouvent facilement des candidats : il faudra te démarquer.",
        DifficulteRecrutement.moyenne => "Les entreprises ont parfois du mal à recruter.",
        DifficulteRecrutement.elevee ||
        DifficulteRecrutement.tresElevee =>
          "Les entreprises ont du mal à recruter : c’est une vraie opportunité.",
      };
  static String presOrigines(List<String> origines) =>
      "Surtout à cause ${origines.map(_origineLisible).join(" et ")}.";
  static String _origineLisible(String origine) => switch (origine) {
        "Conditions de travail" => "des conditions de travail",
        "Lien formation - métier" => "de la formation demandée",
        "Intensité d'embauche" => "des nombreux postes à pourvoir",
        "Manque de main d'oeuvre" => "du manque de candidats",
        "Attractivité Salariale" => "des salaires",
        "Inadéquation géographique" => "de la distance entre les emplois et les candidats",
        "Durabilité de l'emploi" => "des contrats souvent courts",
        _ => "de : ${origine.toLowerCase()}",
      };
  static String presVoirDataEmploi = "Voir tous les chiffres sur Data Emploi";
  static String presSansChiffres = "Regarde si ce métier recrute près de chez toi, avec les chiffres de France Travail.";
  static String presSource(String periode, String territoire) =>
      "Source : France Travail, Data Emploi (offres et demandeurs : $periode), $territoire.";
  static String presDemo = "Démo : chiffres relevés sur Data Emploi le 18/11/2026.";

  static String conseilPourLecteur(String conseil) => "Conseil : $conseil";
  static String conseilSante = "Pense à ta santé : regarde bien les conditions de travail plus haut, et parles-en à ton conseiller.";
  static String conseilTransport(String? ville, int rayonKm) => ville == null
      ? "Sans permis ou sans voiture : cherche une immersion près de chez toi, proche des transports en commun."
      : "Sans permis ou sans voiture : cherche une immersion à moins de $rayonKm km de $ville, proche des transports en commun.";
  static String conseilExperience = "Une immersion compte comme une première expérience sur ton CV.";
  static String conseilConfiance = "Un échange avec un pro, c’est sans engagement : tu peux poser toutes tes questions.";
  static String conseilFinDeMois = "En alternance, tu es payé pendant ta formation.";
  static String conseilSansDiplome = "Bonne nouvelle : ce métier est accessible sans diplôme.";
  static String conseilFormationCourte =
      "Pas de diplôme ? Des formations courtes existent, comme le CAP en 1 ou 2 ans, souvent en alternance.";
}
