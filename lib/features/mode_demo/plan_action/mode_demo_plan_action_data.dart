// Plan d'action du mode démo, recopié de l'export du Grist « Référentiel pour plan d'action » (table Solutions,
// 05/11/2026) : les tâches visibles pour un jeune de 21 ans en « Autre situation », dans l'ordre du Grist.
class DemoPlanTask {
  final String id;
  final String label;
  final String type;
  final String? url;
  final String? appScreen;
  final String? serviceName;
  final String? franceTravailTheme;
  final String? missionLocaleCategory;
  final bool doneAtStart;

  const DemoPlanTask({
    required this.id,
    required this.label,
    required this.type,
    this.url,
    this.appScreen,
    this.serviceName,
    this.franceTravailTheme,
    this.missionLocaleCategory,
    this.doneAtStart = false,
  });
}

class DemoPlanObjective {
  final String id;
  final String title;
  final String theme;
  final List<DemoPlanTask> tasks;

  const DemoPlanObjective({required this.id, required this.title, required this.theme, required this.tasks});
}

const demoPlanObjectives = [
  DemoPlanObjective(
    id: "demo-objectif-decouvrir-metiers",
    title: "Découvrir des métiers",
    theme: "DECOUVRIR_METIERS",
    tasks: [
      DemoPlanTask(
        id: "demo-tache-26",
        label: "Je consulte des fiches métiers",
        type: "LIEN",
        url: "https://candidat.francetravail.fr/metierscope/",
        serviceName: "MétierScope - Recherche métier",
        franceTravailTheme: "Mon (nouveau) métier",
        missionLocaleCategory: "Projet pro",
        doneAtStart: true,
      ),
      DemoPlanTask(
        id: "demo-tache-27",
        label: "Je consulte des vidéos pour découvrir des métiers",
        type: "LIEN",
        url: "https://parcoursmetiers.tv/",
        serviceName: "Parcoursmétiers.tv",
        franceTravailTheme: "Mon (nouveau) métier",
        missionLocaleCategory: "Projet pro",
        doneAtStart: true,
      ),
      DemoPlanTask(
        id: "demo-tache-28",
        label: "J'échange avec des professionnels du secteur d'activité qui m'intéresse",
        type: "LIEN",
        url: "https://www.myjobglasses.com/",
        serviceName: "My Job Glasses",
        franceTravailTheme: "Mon (nouveau) métier",
        missionLocaleCategory: "Projet pro",
      ),
      DemoPlanTask(
        id: "demo-tache-29",
        label: "Je recherche une entreprise qui pourrait m'intéresser",
        type: "LIEN",
        url: "https://labonneboite.francetravail.fr/",
        serviceName: "La Bonne Boîte",
        franceTravailTheme: "Mon (nouveau) métier",
        missionLocaleCategory: "Projet pro",
      ),
      DemoPlanTask(
        id: "demo-tache-30",
        label: "Je consulte les offres d'immersion en entreprise pour découvrir un métier",
        type: "NAVIGATION",
        appScreen: "OFFRES_IMMERSIONS",
        franceTravailTheme: "Mon (nouveau) métier",
        missionLocaleCategory: "Projet pro",
      ),
      DemoPlanTask(
        id: "demo-tache-31",
        label: "Je me renseigne sur l'alternance",
        type: "LIEN",
        url: "https://labonnealternance.apprentissage.beta.gouv.fr/guide-alternant",
        serviceName: "La bonne alternance - Guide alternant",
        franceTravailTheme: "Ma formation professionnelle",
        missionLocaleCategory: "Projet pro",
      ),
      DemoPlanTask(
        id: "demo-tache-32",
        label: "Je consulte les offres d'emploi en alternance",
        type: "NAVIGATION",
        appScreen: "OFFRES_ALTERNANCE",
        franceTravailTheme: "Mes candidatures",
        missionLocaleCategory: "Projet pro",
      ),
      DemoPlanTask(
        id: "demo-tache-33",
        label: "Je recherche si un forum d'orientation est organisé près de chez moi",
        type: "NAVIGATION",
        appScreen: "EVENEMENTS",
        franceTravailTheme: "Ma formation professionnelle",
        missionLocaleCategory: "Formation",
      ),
    ],
  ),
  DemoPlanObjective(
    id: "demo-objectif-engager",
    title: "M'engager",
    theme: "ENGAGER",
    tasks: [
      DemoPlanTask(
        id: "demo-tache-123",
        label: "Je consulte les offres de bénévolat",
        type: "LIEN",
        url: "https://www.jeveuxaider.gouv.fr/",
        serviceName: "JeVeuxAider",
        franceTravailTheme: "Mon (nouveau) métier",
        missionLocaleCategory: "Citoyenneté",
        doneAtStart: true,
      ),
      DemoPlanTask(
        id: "demo-tache-124",
        label: "Je consulte les offres de service civique",
        type: "NAVIGATION",
        appScreen: "OFFRES_SERVICE_CIVIQUE",
        franceTravailTheme: "Mes candidatures",
        missionLocaleCategory: "Citoyenneté",
      ),
      DemoPlanTask(
        id: "demo-tache-127",
        label: "Je recherche une mission pour m'engager (service-civique, volontariat, bénévolat)",
        type: "LIEN",
        url: "https://trouvetamission.gouv.fr/",
        serviceName: "Trouve ta mission",
        missionLocaleCategory: "Citoyenneté",
      ),
    ],
  ),
  DemoPlanObjective(
    id: "demo-objectif-permis",
    title: "Passer mon permis",
    theme: "PAS_DE_PERMIS",
    tasks: [
      DemoPlanTask(
        id: "demo-tache-178",
        label: "Je me renseigne sur les aides au permis",
        type: "LIEN",
        url: "https://mes-aides.francetravail.fr/mobilite/financer-vos-permis",
        serviceName: "Mes aides France Travail - Permis",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Citoyenneté",
      ),
      DemoPlanTask(
        id: "demo-tache-179",
        label: "Je recherche une auto-école proche de mon domicile",
        type: "LIEN",
        url: "https://autoecoles.securite-routiere.gouv.fr/#/",
        serviceName: "Sécurité routière",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Citoyenneté",
      ),
      DemoPlanTask(
        id: "demo-tache-180",
        label: "Je fais une demande de devis dans une auto-école",
        type: "CONSEIL",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Citoyenneté",
      ),
      DemoPlanTask(
        id: "demo-tache-181",
        label: "Je me renseigne sur le permis à 1 euro",
        type: "LIEN",
        url: "https://www.securite-routiere.gouv.fr/passer-son-permis-de-conduire/financement-du-permis-de-conduire/permis-1-eu-par-jour/definition-du-permis-1-eu-par-jour",
        serviceName: "Permis à 1 euro",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Citoyenneté",
      ),
      DemoPlanTask(
        id: "demo-tache-182",
        label: "Je prépare le code la route",
        type: "CONSEIL",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Citoyenneté",
      ),
      DemoPlanTask(
        id: "demo-tache-183",
        label: "Je me prépare à l'examen du permis de conduire",
        type: "CONSEIL",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Citoyenneté",
      ),
    ],
  ),
  DemoPlanObjective(
    id: "demo-objectif-fin-de-mois",
    title: "Boucler mes fins de mois",
    theme: "FIN_DE_MOIS",
    tasks: [
      DemoPlanTask(
        id: "demo-tache-204",
        label: "Je découvre l'ensemble des aides auxquelles je peux prétendre",
        type: "LIEN",
        url: "https://mes-aides.1jeune1solution.beta.gouv.fr/",
        serviceName: "Aides Jeunes",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Citoyenneté",
        doneAtStart: true,
      ),
      DemoPlanTask(
        id: "demo-tache-205",
        label: "Je me rapproche d'une association pour bénéficier d'une aide alimentaire",
        type: "LIEN",
        url: "https://episol.net",
        serviceName: "Epiceries solidaires",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Citoyenneté",
      ),
      DemoPlanTask(
        id: "demo-tache-206",
        label: "Je me rapproche d'une association pour bénéficier d'une aide alimentaire",
        type: "LIEN",
        url: "https://banquealimentaire.fr",
        serviceName: "Banques alimentaires",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Citoyenneté",
      ),
      DemoPlanTask(
        id: "demo-tache-207",
        label: "Je me rapproche d'une association pour bénéficier d'une aide alimentaire",
        type: "LIEN",
        url: "https://restoducoeur.org",
        serviceName: "Resto du cœur",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Citoyenneté",
      ),
      DemoPlanTask(
        id: "demo-tache-208",
        label: "Je me rapproche d'une assistante sociale",
        type: "CONSEIL",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Citoyenneté",
      ),
    ],
  ),
  DemoPlanObjective(
    id: "demo-objectif-sante",
    title: "Prendre soin de ma santé",
    theme: "SANTE",
    tasks: [
      DemoPlanTask(
        id: "demo-tache-218",
        label: "Je veille sur ma santé",
        type: "LIEN",
        url: "https://www.filsantejeunes.com/",
        serviceName: "Fil Santé Jeunes - Santé",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Santé",
      ),
      DemoPlanTask(
        id: "demo-tache-219",
        label: "Je me libère de mes addictions",
        type: "LIEN",
        url: "https://www.filsantejeunes.com/ta-sante/drogues-et-addictions",
        serviceName: "Fil Santé Jeunes - Addictions",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Santé",
      ),
      DemoPlanTask(
        id: "demo-tache-221",
        label: "Je me renseigne sur la complémentaire santé universelle",
        type: "LIEN",
        url: "https://www.complementaire-sante-solidaire.gouv.fr/ma-situation/vous-etes-etudiant-ou-jeune-de-moins-de-25-ans",
        serviceName: "Complémentaire santé universelle",
        franceTravailTheme: "Mes contraintes personnelles",
        missionLocaleCategory: "Santé",
      ),
    ],
  ),
];

// Réponses du jeune fictif, au format de GET /jeunes/:id/questionnaire : elles rendent le questionnaire complet
// (sous-titre et bouton « Modifier » de l'accueil) et le préremplissent quand on le rouvre.
const Map<String, dynamic> demoQuestionnaire = {
  "dateNaissance": "2005-03-14",
  "habitation": {"codeInsee": "59350", "nom": "Lille"},
  "situation": "AUTRE",
  "goals": ["DECOUVRIR_METIERS", "ENGAGER"],
  "domaineInconnu": true,
  "villeRecherche": {"codeInsee": "59350", "nom": "Lille"},
  "rayonKm": 20,
  "obstacles": ["PAS_DE_PERMIS", "FIN_DE_MOIS", "SANTE"],
};
