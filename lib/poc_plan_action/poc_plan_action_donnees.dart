// Plan des captures de Steph (05/11/2026), recopié de l'export du Grist « Référentiel pour plan d'action »
// (table Solutions) : tâches visibles d'un jeune de 21 ans en « Autre situation », dans l'ordre du Grist.
// « M'engager » n'a pas les 2 tâches « mentor », comme sur la 3e capture.
class PocPlanTache {
  final String id;
  final String libelle;
  final String type;
  final String? url;
  final String? ecranApp;
  final String? nomService;
  final String? thematiqueFranceTravail;
  final String? categorieMissionLocale;
  final bool termineeAuDepart;

  const PocPlanTache({
    required this.id,
    required this.libelle,
    required this.type,
    this.url,
    this.ecranApp,
    this.nomService,
    this.thematiqueFranceTravail,
    this.categorieMissionLocale,
    this.termineeAuDepart = false,
  });
}

class PocPlanObjectif {
  final String id;
  final String titre;
  final String theme;
  final List<PocPlanTache> taches;

  const PocPlanObjectif({
    required this.id,
    required this.titre,
    required this.theme,
    required this.taches,
  });
}

const pocPlanActionObjectifs = [
  PocPlanObjectif(
    id: "poc-plan-objectif-decouvrir-metiers",
    titre: "Découvrir des métiers",
    theme: "DECOUVRIR_METIERS",
    taches: [
      PocPlanTache(
        id: "poc-plan-tache-26",
        libelle: "Je consulte des fiches métiers",
        type: "LIEN",
        url: "https://candidat.francetravail.fr/metierscope/",
        nomService: "MétierScope - Recherche métier",
        thematiqueFranceTravail: "Mon (nouveau) métier",
        categorieMissionLocale: "Projet pro",
        termineeAuDepart: true,
      ),
      PocPlanTache(
        id: "poc-plan-tache-27",
        libelle: "Je consulte des vidéos pour découvrir des métiers",
        type: "LIEN",
        url: "https://parcoursmetiers.tv/",
        nomService: "Parcoursmétiers.tv",
        thematiqueFranceTravail: "Mon (nouveau) métier",
        categorieMissionLocale: "Projet pro",
        termineeAuDepart: true,
      ),
      PocPlanTache(
        id: "poc-plan-tache-28",
        libelle:
            "J'échange avec des professionnels du secteur d'activité qui m'intéresse",
        type: "LIEN",
        url: "https://www.myjobglasses.com/",
        nomService: "My Job Glasses",
        thematiqueFranceTravail: "Mon (nouveau) métier",
        categorieMissionLocale: "Projet pro",
      ),
      PocPlanTache(
        id: "poc-plan-tache-29",
        libelle: "Je recherche une entreprise qui pourrait m'intéresser",
        type: "LIEN",
        url: "https://labonneboite.francetravail.fr/",
        nomService: "La Bonne Boîte",
        thematiqueFranceTravail: "Mon (nouveau) métier",
        categorieMissionLocale: "Projet pro",
      ),
      PocPlanTache(
        id: "poc-plan-tache-30",
        libelle:
            "Je consulte les offres d'immersion en entreprise pour découvrir un métier",
        type: "NAVIGATION",
        ecranApp: "OFFRES_IMMERSIONS",
        thematiqueFranceTravail: "Mon (nouveau) métier",
        categorieMissionLocale: "Projet pro",
      ),
      PocPlanTache(
        id: "poc-plan-tache-31",
        libelle: "Je me renseigne sur l'alternance",
        type: "LIEN",
        url:
            "https://labonnealternance.apprentissage.beta.gouv.fr/guide-alternant",
        nomService: "La bonne alternance - Guide alternant",
        thematiqueFranceTravail: "Ma formation professionnelle",
        categorieMissionLocale: "Projet pro",
      ),
      PocPlanTache(
        id: "poc-plan-tache-32",
        libelle: "Je consulte les offres d'emploi en alternance",
        type: "NAVIGATION",
        ecranApp: "OFFRES_ALTERNANCE",
        thematiqueFranceTravail: "Mes candidatures",
        categorieMissionLocale: "Projet pro",
      ),
      PocPlanTache(
        id: "poc-plan-tache-33",
        libelle:
            "Je recherche si un forum d'orientation est organisé près de chez moi",
        type: "NAVIGATION",
        ecranApp: "EVENEMENTS",
        thematiqueFranceTravail: "Ma formation professionnelle",
        categorieMissionLocale: "Formation",
      ),
    ],
  ),
  PocPlanObjectif(
    id: "poc-plan-objectif-engager",
    titre: "M'engager",
    theme: "ENGAGER",
    taches: [
      PocPlanTache(
        id: "poc-plan-tache-123",
        libelle: "Je consulte les offres de bénévolat",
        type: "LIEN",
        url: "https://www.jeveuxaider.gouv.fr/",
        nomService: "JeVeuxAider",
        thematiqueFranceTravail: "Mon (nouveau) métier",
        categorieMissionLocale: "Citoyenneté",
        termineeAuDepart: true,
      ),
      PocPlanTache(
        id: "poc-plan-tache-124",
        libelle: "Je consulte les offres de service civique",
        type: "NAVIGATION",
        ecranApp: "OFFRES_SERVICE_CIVIQUE",
        thematiqueFranceTravail: "Mes candidatures",
        categorieMissionLocale: "Citoyenneté",
      ),
      PocPlanTache(
        id: "poc-plan-tache-127",
        libelle:
            "Je recherche une mission pour m'engager (service-civique, volontariat, bénévolat)",
        type: "LIEN",
        url: "https://trouvetamission.gouv.fr/",
        nomService: "Trouve ta mission",
        categorieMissionLocale: "Citoyenneté",
      ),
    ],
  ),
  PocPlanObjectif(
    id: "poc-plan-objectif-permis",
    titre: "Passer mon permis",
    theme: "PAS_DE_PERMIS",
    taches: [
      PocPlanTache(
        id: "poc-plan-tache-178",
        libelle: "Je me renseigne sur les aides au permis",
        type: "LIEN",
        url: "https://mes-aides.francetravail.fr/mobilite/financer-vos-permis",
        nomService: "Mes aides France Travail - Permis",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Citoyenneté",
      ),
      PocPlanTache(
        id: "poc-plan-tache-179",
        libelle: "Je recherche une auto-école proche de mon domicile",
        type: "LIEN",
        url: "https://autoecoles.securite-routiere.gouv.fr/#/",
        nomService: "Sécurité routière",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Citoyenneté",
      ),
      PocPlanTache(
        id: "poc-plan-tache-180",
        libelle: "Je fais une demande de devis dans une auto-école",
        type: "CONSEIL",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Citoyenneté",
      ),
      PocPlanTache(
        id: "poc-plan-tache-181",
        libelle: "Je me renseigne sur le permis à 1 euro",
        type: "LIEN",
        url:
            "https://www.securite-routiere.gouv.fr/passer-son-permis-de-conduire/financement-du-permis-de-conduire/permis-1-eu-par-jour/definition-du-permis-1-eu-par-jour",
        nomService: "Permis à 1 euro",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Citoyenneté",
      ),
      PocPlanTache(
        id: "poc-plan-tache-182",
        libelle: "Je prépare le code la route",
        type: "CONSEIL",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Citoyenneté",
      ),
      PocPlanTache(
        id: "poc-plan-tache-183",
        libelle: "Je me prépare à l'examen du permis de conduire",
        type: "CONSEIL",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Citoyenneté",
      ),
    ],
  ),
  PocPlanObjectif(
    id: "poc-plan-objectif-fin-de-mois",
    titre: "Boucler mes fins de mois",
    theme: "FIN_DE_MOIS",
    taches: [
      PocPlanTache(
        id: "poc-plan-tache-204",
        libelle:
            "Je découvre l'ensemble des aides auxquelles je peux prétendre",
        type: "LIEN",
        url: "https://mes-aides.1jeune1solution.beta.gouv.fr/",
        nomService: "Aides Jeunes",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Citoyenneté",
        termineeAuDepart: true,
      ),
      PocPlanTache(
        id: "poc-plan-tache-205",
        libelle:
            "Je me rapproche d'une association pour bénéficier d'une aide alimentaire",
        type: "LIEN",
        url: "https://episol.net",
        nomService: "Epiceries solidaires",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Citoyenneté",
      ),
      PocPlanTache(
        id: "poc-plan-tache-206",
        libelle:
            "Je me rapproche d'une association pour bénéficier d'une aide alimentaire",
        type: "LIEN",
        url: "https://banquealimentaire.fr",
        nomService: "Banques alimentaires",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Citoyenneté",
      ),
      PocPlanTache(
        id: "poc-plan-tache-207",
        libelle:
            "Je me rapproche d'une association pour bénéficier d'une aide alimentaire",
        type: "LIEN",
        url: "https://restoducoeur.org",
        nomService: "Resto du cœur",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Citoyenneté",
      ),
      PocPlanTache(
        id: "poc-plan-tache-208",
        libelle: "Je me rapproche d'une assistante sociale",
        type: "CONSEIL",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Citoyenneté",
      ),
    ],
  ),
  PocPlanObjectif(
    id: "poc-plan-objectif-sante",
    titre: "Prendre soin de ma santé",
    theme: "SANTE",
    taches: [
      PocPlanTache(
        id: "poc-plan-tache-218",
        libelle: "Je veille sur ma santé",
        type: "LIEN",
        url: "https://www.filsantejeunes.com/",
        nomService: "Fil Santé Jeunes - Santé",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Santé",
      ),
      PocPlanTache(
        id: "poc-plan-tache-219",
        libelle: "Je me libère de mes addictions",
        type: "LIEN",
        url: "https://www.filsantejeunes.com/ta-sante/drogues-et-addictions",
        nomService: "Fil Santé Jeunes - Addictions",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Santé",
      ),
      PocPlanTache(
        id: "poc-plan-tache-221",
        libelle: "Je me renseigne sur la complémentaire santé universelle",
        type: "LIEN",
        url:
            "https://www.complementaire-sante-solidaire.gouv.fr/ma-situation/vous-etes-etudiant-ou-jeune-de-moins-de-25-ans",
        nomService: "Complémentaire santé universelle",
        thematiqueFranceTravail: "Mes contraintes personnelles",
        categorieMissionLocale: "Santé",
      ),
    ],
  ),
];

// Réponses du jeune fictif, au format de GET /jeunes/:id/questionnaire : elles rendent le questionnaire complet
// (sous-titre et bouton « Modifier » des captures) et le préremplissent quand on le rouvre.
const Map<String, dynamic> pocPlanActionQuestionnaire = {
  "dateNaissance": "2005-03-14",
  "habitation": {"codeInsee": "59350", "nom": "Lille"},
  "situation": "AUTRE",
  "goals": ["DECOUVRIR_METIERS", "ENGAGER"],
  "domaineInconnu": true,
  "villeRecherche": {"codeInsee": "59350", "nom": "Lille"},
  "rayonKm": 20,
  "obstacles": ["PAS_DE_PERMIS", "FIN_DE_MOIS", "SANTE"],
};
