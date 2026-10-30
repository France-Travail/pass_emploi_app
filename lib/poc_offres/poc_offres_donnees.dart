import 'dart:math' as math;

import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_modeles.dart';

// Tout est en dur, autour de Lille : aucune donnée ne vient d'une API, même en connexion.
// Les noms d'entreprise de la maquette de Steph sont repris ; les autres sont inventés.
// Les numéros de téléphone sont dans la plage réservée à la fiction par l'Arcep (03 53 01 xx xx).

const pocRayonBenevolatKm = 30;
const pocRayonParDefautKm = 30;

// Les mêmes CV France Travail que le reste du mode démo (assets/mode_demo/cv_pole_emploi.json).
const pocCvFranceTravail = ["boulanger-2023.pdf", "patissier-2023.pdf"];

final pocCommunes = <Location>[
  _commune("Lille", "59350", "59000", 50.6292, 3.0573),
  _commune("Roubaix", "59512", "59100", 50.6942, 3.1746),
  _commune("Tourcoing", "59599", "59200", 50.7239, 3.1612),
  _commune("Villeneuve-d’Ascq", "59009", "59650", 50.6233, 3.1450),
  _commune("Armentières", "59017", "59280", 50.6880, 2.8810),
  _commune("Wattignies", "59648", "59139", 50.5864, 3.0436),
  _commune("Lens", "62498", "62300", 50.4322, 2.8333),
  _commune("Arras", "62041", "62000", 50.2910, 2.7775),
  _commune("Amiens", "80021", "80000", 49.8941, 2.2958),
  _commune("Rouen", "76540", "76000", 49.4432, 1.0999),
  _commune("Paris", "75056", "75001", 48.8566, 2.3522),
  _commune("Lyon", "69123", "69001", 45.7640, 4.8357),
  _commune("Marseille", "13055", "13001", 43.2965, 5.3698),
  _commune("Nantes", "44109", "44000", 47.2184, -1.5536),
  _commune("Bordeaux", "33063", "33000", 44.8378, -0.5792),
  _commune("Toulouse", "31555", "31000", 43.6047, 1.4442),
  _commune("Rennes", "35238", "35000", 48.1173, -1.6778),
  _commune("Strasbourg", "67482", "67000", 48.5734, 7.7521),
  _commune("Montpellier", "34172", "34000", 43.6108, 3.8767),
  _commune("Nice", "06088", "06000", 43.7102, 7.2620),
];

Location _commune(String nom, String codeInsee, String codePostal, double latitude, double longitude) {
  return Location(
    libelle: nom,
    code: codeInsee,
    type: LocationType.COMMUNE,
    codePostal: codePostal,
    latitude: latitude,
    longitude: longitude,
  );
}

List<Location> pocCommunesCorrespondantes(String saisie) {
  final texte = sansAccents(saisie.trim());
  if (texte.isEmpty) return pocCommunes;
  return pocCommunes
      .where((commune) => sansAccents(commune.libelle).contains(texte) || (commune.codePostal ?? '').startsWith(texte))
      .toList();
}

const _alimentation = ["alimentation", "artisan"];

const pocMetiers = <PocMetier>[
  PocMetier(codeRome: "D1102", libelle: "Boulanger / Boulangère", motsCles: ["boulangerie", "viennoiserie", "pain", ..._alimentation]),
  PocMetier(codeRome: "D1104", libelle: "Pâtissier / Pâtissière", motsCles: ["patisserie", "chocolatier", "glacier", ..._alimentation]),
  PocMetier(codeRome: "D1101", libelle: "Boucher / Bouchère", motsCles: ["boucherie", "viande", ..._alimentation]),
  PocMetier(
    codeRome: "D1106",
    libelle: "Vendeur / Vendeuse en alimentation",
    motsCles: ["vente", "commerce", "magasin", "boulangerie", "epicerie", "alimentation"],
  ),
  PocMetier(codeRome: "D1214", libelle: "Vendeur / Vendeuse en prêt-à-porter", motsCles: ["vente", "commerce", "magasin", "mode"]),
  PocMetier(codeRome: "D1507", libelle: "Employé / Employée de rayon", motsCles: ["commerce", "magasin", "supermarche"]),
  PocMetier(codeRome: "D1505", libelle: "Hôte / Hôtesse de caisse", motsCles: ["commerce", "caisse", "magasin", "supermarche"]),
  PocMetier(codeRome: "D1401", libelle: "Assistant / Assistante commercial(e)", motsCles: ["commerce", "vente", "bureau"]),
  PocMetier(codeRome: "G1602", libelle: "Cuisinier / Cuisinière", motsCles: ["cuisine", "restauration", "commis"]),
  PocMetier(codeRome: "G1803", libelle: "Serveur / Serveuse en restauration", motsCles: ["restauration", "salle", "cafe", "bar"]),
  PocMetier(codeRome: "G1703", libelle: "Réceptionniste en hôtellerie", motsCles: ["hotel", "accueil", "tourisme"]),
  PocMetier(codeRome: "D1202", libelle: "Coiffeur / Coiffeuse", motsCles: ["coiffure", "salon", "beaute"]),
  PocMetier(codeRome: "D1208", libelle: "Esthéticien / Esthéticienne", motsCles: ["esthetique", "beaute", "soins"]),
  PocMetier(codeRome: "I1604", libelle: "Mécanicien / Mécanicienne automobile", motsCles: ["mecanique", "garage", "voiture"]),
  PocMetier(codeRome: "F1603", libelle: "Plombier / Plombière", motsCles: ["plomberie", "chauffage", "batiment"]),
  PocMetier(codeRome: "F1602", libelle: "Électricien / Électricienne du bâtiment", motsCles: ["electricite", "batiment", "chantier"]),
  PocMetier(codeRome: "F1703", libelle: "Maçon / Maçonne", motsCles: ["maconnerie", "batiment", "chantier"]),
  PocMetier(codeRome: "J1501", libelle: "Aide-soignant / Aide-soignante", motsCles: ["sante", "hopital", "soins"]),
  PocMetier(codeRome: "K1302", libelle: "Auxiliaire de vie", motsCles: ["aide a domicile", "personnes agees", "social"]),
  PocMetier(codeRome: "M1607", libelle: "Secrétaire", motsCles: ["bureau", "administratif", "accueil"]),
  PocMetier(codeRome: "M1203", libelle: "Comptable", motsCles: ["comptabilite", "gestion", "bureau"]),
  PocMetier(codeRome: "M1805", libelle: "Développeur / Développeuse informatique", motsCles: ["informatique", "web", "numerique"]),
  PocMetier(codeRome: "N1103", libelle: "Préparateur / Préparatrice de commandes", motsCles: ["logistique", "entrepot", "magasinier"]),
  PocMetier(codeRome: "A1203", libelle: "Jardinier / Jardinière paysagiste", motsCles: ["espaces verts", "jardin", "paysage"]),
];

List<PocMetier> pocMetiersCorrespondants(String saisie) {
  if (saisie.trim().isEmpty) return pocMetiers;
  return pocMetiers.where((metier) => metier.correspond(saisie)).toList();
}

PocMetier? pocMetierParCode(String codeRome) {
  for (final metier in pocMetiers) {
    if (metier.codeRome == codeRome) return metier;
  }
  return null;
}

const pocActivites = [
  "Accompagnement",
  "Animation / Loisirs",
  "Collecte / Distribution",
  "Communication",
  "Environnement / Nature",
  "Formation / Transmission",
  "Soutien scolaire",
  "Sport",
];

const pocDomaines = [
  "Solidarité et insertion",
  "Éducation pour tous",
  "Art et culture pour tous",
  "Protection de la nature",
  "Bénévolat de compétences",
  "Sport pour tous",
  "Santé pour tous",
  "Prévention et protection",
  "Coopération internationale",
  "Mémoire et citoyenneté",
];

const _jeVeuxAider = "https://www.jeveuxaider.gouv.fr/missions-benevolat";

final pocMissions = <PocMission>[
  PocMission(
    id: "poc-mission-1",
    titre: "Je deviens conseiller chez France Bénévolat deux samedis par mois",
    organisation: "France Bénévolat Lille Métropole",
    organisationDescription:
        "Donner envie à chacun de s’engager auprès d’une association, aider de façon personnalisée toute personne qui le souhaite à trouver la mission qui lui convient, chercher les compétences bénévoles dont les associations du territoire ont besoin : ce sont nos principales actions au service de l’engagement bénévole associatif.",
    domaine: "Solidarité et insertion",
    activite: "Accompagnement",
    lieu: PocLieu(adresse: "Rue Nationale", codePostal: "59000", ville: "Lille", latitude: 50.6365, longitude: 3.0590),
    dateDebut: DateTime(2026, 11, 7),
    dateFin: DateTime(2027, 6, 26),
    engagement: "Engagement de 6 mois minimum",
    rythme: "2 jours par mois",
    rythmeDetail: "Deux samedis par mois, de 14 h à 17 h",
    places: 10,
    prerequis: [
      "De la bienveillance",
      "L’envie de partager, d’accompagner et de conseiller un groupe de jeunes",
      "Avoir plus de 18 ans",
    ],
    publicAide: ["Jeunes / Enfants"],
    ouverteAuxMineurs: false,
    accessiblePmr: true,
    description: [
      "France Bénévolat Lille Métropole recherche un ou une bénévole pour accueillir et conseiller les personnes qui veulent s’engager.",
      "Tu as le sens du contact ? Tu aimes écouter et orienter ? Rejoins-nous pour faire connaître l’engagement bénévole sur tout le territoire.",
      "Ta mission :",
      "• accueillir les futurs bénévoles et comprendre leurs envies ;",
      "• leur présenter les associations qui recrutent près de chez eux ;",
      "• les suivre après leurs premiers pas.",
    ],
    accroche: "Sautez le pas : une véritable aventure humaine pour toutes les parties prenantes.",
    url: _jeVeuxAider,
  ),
  PocMission(
    id: "poc-mission-2",
    titre: "Je forme des bénévoles à l’éducation populaire et à la justice sociale",
    organisation: "Frères des Hommes",
    organisationDescription:
        "Association de solidarité internationale, elle accompagne des mouvements qui luttent contre les inégalités et forme des bénévoles en France.",
    domaine: "Éducation pour tous",
    activite: "Formation / Transmission",
    lieu: PocLieu(adresse: "Boulevard de la Liberté", codePostal: "59000", ville: "Lille", latitude: 50.6315, longitude: 3.0560),
    dateDebut: DateTime(2026, 11, 14),
    dateFin: DateTime(2027, 5, 31),
    engagement: "Engagement de 3 mois minimum",
    rythme: "2 jours par mois",
    places: 4,
    prerequis: ["Aimer prendre la parole devant un groupe", "Avoir envie d’apprendre en équipe"],
    publicAide: ["Adultes", "Jeunes / Enfants"],
    ouverteAuxMineurs: false,
    accessiblePmr: true,
    description: [
      "Tu animes des ateliers pour former de nouveaux bénévoles : jeux, débats, mises en situation.",
      "Tu es accompagné par un binôme expérimenté pour tes premières sessions.",
    ],
    url: _jeVeuxAider,
  ),
  PocMission(
    id: "poc-mission-3",
    titre: "Je participe à un prix littéraire pour les jeunes",
    organisation: "Le Compagnon Laïque",
    organisationDescription: "L’association fait découvrir la lecture et l’écriture aux enfants et aux adolescents.",
    domaine: "Art et culture pour tous",
    activite: "Animation / Loisirs",
    lieu: null,
    dateDebut: DateTime(2026, 11, 2),
    dateFin: DateTime(2027, 3, 31),
    rythme: "2 jours par semaine",
    places: 15,
    publicAide: ["Jeunes / Enfants"],
    ouverteAuxMineurs: true,
    accessiblePmr: true,
    description: [
      "Tu lis une sélection de romans jeunesse, puis tu donnes ton avis en ligne avec les autres membres du jury.",
      "Les échanges ont lieu en visioconférence : tu participes depuis chez toi.",
    ],
    url: _jeVeuxAider,
  ),
  PocMission(
    id: "poc-mission-4",
    titre: "Je forme des bénévoles à l’éducation populaire et à la justice sociale",
    organisation: "La Fabrique des Communs pédagogiques",
    organisationDescription: "Un collectif qui partage gratuitement des outils pour apprendre ensemble.",
    domaine: "Éducation pour tous",
    activite: "Formation / Transmission",
    lieu: null,
    dateDebut: DateTime(2026, 12, 1),
    rythme: "Une demi-journée par mois",
    places: 6,
    publicAide: ["Adultes"],
    ouverteAuxMineurs: false,
    accessiblePmr: true,
    description: ["Tu co-animes des ateliers en ligne et tu aides à améliorer les fiches pédagogiques du collectif."],
    url: _jeVeuxAider,
  ),
  PocMission(
    id: "poc-mission-5",
    titre: "Je tiens l’accueil d’une épicerie solidaire",
    organisation: "Épicerie solidaire de Fives",
    organisationDescription: "L’épicerie permet à des familles de faire leurs courses à petit prix, dans un lieu convivial.",
    domaine: "Solidarité et insertion",
    activite: "Collecte / Distribution",
    lieu: PocLieu(adresse: "Rue Pierre Legrand", codePostal: "59800", ville: "Lille", latitude: 50.6309, longitude: 3.0889),
    dateDebut: DateTime(2026, 11, 5),
    rythme: "Le samedi matin",
    places: 3,
    prerequis: ["Le sens de l’accueil"],
    publicAide: ["Familles", "Personnes en difficulté"],
    ouverteAuxMineurs: true,
    accessiblePmr: true,
    description: [
      "Tu accueilles les familles, tu les aides à trouver les produits et tu ranges les rayons avec l’équipe.",
    ],
    url: _jeVeuxAider,
  ),
  PocMission(
    id: "poc-mission-6",
    titre: "J’entretiens un jardin partagé avec les habitants",
    organisation: "Les Jardins de Wazemmes",
    organisationDescription: "L’association fait vivre un jardin partagé ouvert à tous les habitants du quartier.",
    domaine: "Protection de la nature",
    activite: "Environnement / Nature",
    lieu: PocLieu(adresse: "Rue des Sarrazins", codePostal: "59000", ville: "Lille", latitude: 50.6247, longitude: 3.0466),
    dateDebut: DateTime(2027, 3, 1),
    dateFin: DateTime(2027, 9, 30),
    rythme: "Une demi-journée par semaine",
    places: 8,
    publicAide: ["Tous publics"],
    ouverteAuxMineurs: true,
    accessiblePmr: false,
    description: ["Tu sèmes, tu arroses et tu récoltes avec les habitants, puis tu participes aux fêtes du jardin."],
    url: _jeVeuxAider,
  ),
  PocMission(
    id: "poc-mission-7",
    titre: "J’encadre des matchs de foot pour les 8-12 ans",
    organisation: "Union sportive de Roubaix",
    organisationDescription: "Le club accueille plus de 200 enfants chaque saison.",
    domaine: "Sport pour tous",
    activite: "Sport",
    lieu: PocLieu(adresse: "Avenue Jean Lebas", codePostal: "59100", ville: "Roubaix", latitude: 50.6890, longitude: 3.1730),
    dateDebut: DateTime(2026, 11, 4),
    dateFin: DateTime(2027, 6, 30),
    rythme: "Le mercredi après-midi",
    places: 5,
    prerequis: ["Aimer le football", "Être patient avec les enfants"],
    publicAide: ["Jeunes / Enfants"],
    ouverteAuxMineurs: true,
    accessiblePmr: false,
    description: ["Tu aides l’entraîneur à encadrer les matchs et tu arbitres des rencontres amicales."],
    url: _jeVeuxAider,
  ),
  PocMission(
    id: "poc-mission-8",
    titre: "J’aide des collégiens à faire leurs devoirs",
    organisation: "Coup de pouce Tourcoing",
    organisationDescription: "L’association propose de l’aide aux devoirs gratuite dans trois quartiers de Tourcoing.",
    domaine: "Éducation pour tous",
    activite: "Soutien scolaire",
    lieu: PocLieu(adresse: "Rue de Lille", codePostal: "59200", ville: "Tourcoing", latitude: 50.7210, longitude: 3.1580),
    dateDebut: DateTime(2026, 11, 9),
    dateFin: DateTime(2027, 6, 18),
    engagement: "Engagement jusqu’à la fin de l’année scolaire",
    rythme: "2 heures par semaine",
    places: 6,
    prerequis: ["Être à l’aise en français ou en mathématiques"],
    publicAide: ["Jeunes / Enfants"],
    ouverteAuxMineurs: false,
    accessiblePmr: true,
    description: ["Tu accompagnes un petit groupe de collégiens pendant leurs devoirs, après les cours."],
    url: _jeVeuxAider,
  ),
  PocMission(
    id: "poc-mission-9",
    titre: "J’anime des jeux de société avec des personnes âgées",
    organisation: "Résidence Les Tilleuls",
    organisationDescription: "La résidence accueille 60 personnes âgées et ouvre ses portes aux bénévoles du quartier.",
    domaine: "Solidarité et insertion",
    activite: "Animation / Loisirs",
    lieu: PocLieu(adresse: "Rue Saint-Gabriel", codePostal: "59800", ville: "Lille", latitude: 50.6380, longitude: 3.0850),
    dateDebut: DateTime(2026, 11, 8),
    rythme: "Le dimanche après-midi",
    places: 4,
    publicAide: ["Personnes âgées"],
    ouverteAuxMineurs: true,
    accessiblePmr: true,
    description: ["Tu proposes des jeux de cartes et de société, et tu partages un goûter avec les résidents."],
    url: _jeVeuxAider,
  ),
  PocMission(
    id: "poc-mission-10",
    titre: "Je fais connaître les actions de l’association sur les réseaux sociaux",
    organisation: "Collectif Lille Solidaire",
    organisationDescription: "Le collectif relaie les besoins de 40 associations de la métropole lilloise.",
    domaine: "Bénévolat de compétences",
    activite: "Communication",
    lieu: null,
    dateDebut: DateTime(2026, 11, 16),
    rythme: "2 heures par semaine",
    places: 2,
    prerequis: ["Être à l’aise avec les réseaux sociaux"],
    publicAide: ["Tous publics"],
    ouverteAuxMineurs: true,
    accessiblePmr: true,
    description: ["Tu rédiges les publications de la semaine et tu prépares des visuels simples avec l’équipe."],
    url: _jeVeuxAider,
  ),
];

const _qualitesBoulanger = [
  "Être force de proposition",
  "Faire preuve d’autonomie",
  "Faire preuve de rigueur et de précision",
  "Organiser son travail selon les priorités et les objectifs",
];

const _competencesBoulanger = [
  "Pétrir, façonner et cuire les pains courants et spéciaux",
  "Préparer les pâtes levées et feuilletées",
  "Appliquer les règles d’hygiène et de sécurité alimentaire",
  "Gérer les stocks et les commandes de matières premières",
];

const _descriptionBoulanger = [
  "Le boulanger, artisan essentiel de notre quotidien, transforme et valorise les matières premières pour régaler nos papilles.",
  "Tu prépares et réalises les produits de boulangerie et de viennoiserie selon les règles d’hygiène et de sécurité alimentaires.",
  "Tu conçois de nouvelles recettes de pains et de viennoiseries, tu gères les stocks de matières premières et tu veilles à la cuisson de chaque produit.",
  "Tu peux aussi participer à la vente en boutique.",
];

const _accessibleCap =
    "Ce métier est accessible avec un CAP, préparé ici en alternance. Aucune expérience n’est exigée : l’entreprise te forme.";

const _secteurBoulangerie = "Boulangerie et boulangerie-pâtisserie";

const _offresFranceTravail = "https://candidat.francetravail.fr/offres/recherche?motsCles=";

final pocOffres = <PocOffreAlternance>[
  PocOffreAlternance(
    id: "poc-offre-1",
    codeRome: "D1102",
    titre: "Ouvrier boulanger / Ouvrière boulangère",
    entreprise: "BWL",
    lieu: PocLieu(adresse: "56 rue Faidherbe", codePostal: "59139", ville: "Wattignies", latitude: 50.5864, longitude: 3.0436),
    typeContrat: "Apprentissage",
    debut: "4 janvier 2027",
    duree: "12 mois",
    niveau: PocNiveau.cap,
    description: _descriptionBoulanger,
    qualites: _qualitesBoulanger,
    competencesAcquises: _competencesBoulanger,
    domainesTechniques: ["Boulangerie", "Viennoiserie", "Panification", "Hygiène alimentaire"],
    accessibleA: _accessibleCap,
    tailleEntreprise: "10 à 19 salariés",
    secteur: _secteurBoulangerie,
    candidatureSimplifiee: true,
  ),
  PocOffreAlternance(
    id: "poc-offre-2",
    codeRome: "D1102",
    titre: "Boulanger-viennoisier / Boulangère-viennoisière",
    entreprise: "La Boulange",
    lieu: PocLieu(adresse: "12 rue de Lille", codePostal: "59280", ville: "Armentières", latitude: 50.6880, longitude: 2.8810),
    typeContrat: "Apprentissage",
    debut: "2 novembre 2026",
    duree: "24 mois",
    niveau: PocNiveau.cap,
    description: _descriptionBoulanger,
    qualites: _qualitesBoulanger,
    competencesAcquises: _competencesBoulanger,
    domainesTechniques: ["Boulangerie", "Viennoiserie"],
    accessibleA: _accessibleCap,
    tailleEntreprise: "3 à 5 salariés",
    secteur: _secteurBoulangerie,
    candidatureSimplifiee: true,
  ),
  PocOffreAlternance(
    id: "poc-offre-3",
    codeRome: "D1102",
    titre: "Boulanger-viennoisier / Boulangère-viennoisière",
    entreprise: "Desher",
    lieu: PocLieu(adresse: "Grande Rue", codePostal: "59100", ville: "Roubaix", latitude: 50.6930, longitude: 3.1760),
    typeContrat: "Apprentissage",
    debut: "4 janvier 2027",
    duree: "24 mois",
    niveau: PocNiveau.cap,
    description: _descriptionBoulanger,
    qualites: _qualitesBoulanger,
    competencesAcquises: _competencesBoulanger,
    domainesTechniques: ["Boulangerie", "Viennoiserie"],
    accessibleA: _accessibleCap,
    tailleEntreprise: "6 à 9 salariés",
    secteur: _secteurBoulangerie,
    candidatureSimplifiee: false,
    urlPostulation: "${_offresFranceTravail}boulanger",
  ),
  PocOffreAlternance(
    id: "poc-offre-4",
    codeRome: "D1102",
    titre: "Apprenti boulanger / Apprentie boulangère",
    entreprise: "Le Fournil de l’Artois",
    lieu: PocLieu(adresse: "Place des Héros", codePostal: "62000", ville: "Arras", latitude: 50.2910, longitude: 2.7775),
    typeContrat: "Apprentissage",
    debut: "4 janvier 2027",
    duree: "24 mois",
    niveau: PocNiveau.cap,
    description: _descriptionBoulanger,
    qualites: _qualitesBoulanger,
    competencesAcquises: _competencesBoulanger,
    domainesTechniques: ["Boulangerie", "Panification"],
    accessibleA: _accessibleCap,
    tailleEntreprise: "10 à 19 salariés",
    secteur: _secteurBoulangerie,
    candidatureSimplifiee: true,
  ),
  PocOffreAlternance(
    id: "poc-offre-5",
    codeRome: "D1106",
    titre: "Vendeur / Vendeuse en boulangerie-pâtisserie",
    entreprise: "Maison Delattre",
    lieu: PocLieu(
      adresse: "Rue Jean Jaurès",
      codePostal: "59650",
      ville: "Villeneuve-d’Ascq",
      latitude: 50.6233,
      longitude: 3.1450,
    ),
    typeContrat: "Contrat de professionnalisation",
    debut: "16 novembre 2026",
    duree: "12 mois",
    niveau: PocNiveau.cap,
    description: [
      "Tu accueilles les clients, tu les conseilles et tu encaisses leurs achats.",
      "Tu mets en valeur les pains et les pâtisseries en vitrine et tu veilles à la propreté de la boutique.",
    ],
    qualites: ["Avoir le sens du contact", "Être souriant et dynamique", "Être ponctuel"],
    competencesAcquises: ["Accueillir et conseiller un client", "Tenir une caisse", "Présenter les produits en vitrine"],
    domainesTechniques: ["Vente", "Encaissement", "Hygiène alimentaire"],
    accessibleA: "Ce métier est accessible sans diplôme. Un CAP Équipier polyvalent du commerce est un plus.",
    tailleEntreprise: "6 à 9 salariés",
    secteur: _secteurBoulangerie,
    candidatureSimplifiee: true,
  ),
  PocOffreAlternance(
    id: "poc-offre-6",
    codeRome: "D1106",
    titre: "Employé / Employée de commerce en alimentation",
    entreprise: "Supérette du Vieux-Lille",
    lieu: PocLieu(adresse: "Rue de la Monnaie", codePostal: "59800", ville: "Lille", latitude: 50.6398, longitude: 3.0628),
    typeContrat: "Apprentissage",
    debut: "4 janvier 2027",
    duree: "24 mois",
    niveau: PocNiveau.bac,
    description: [
      "Tu réceptionnes les livraisons, tu mets en rayon et tu tiens la caisse.",
      "Tu prépares un Bac pro Métiers du commerce et de la vente en alternance.",
    ],
    qualites: ["Être organisé", "Avoir le sens du service"],
    competencesAcquises: ["Réceptionner une livraison", "Mettre en rayon", "Tenir une caisse"],
    domainesTechniques: ["Commerce", "Logistique de magasin"],
    accessibleA: "Ce métier est accessible avec un Bac pro, préparé ici en alternance.",
    tailleEntreprise: "10 à 19 salariés",
    secteur: "Commerce d’alimentation générale",
    candidatureSimplifiee: false,
    urlPostulation: "${_offresFranceTravail}vendeur",
  ),
];

final pocEntreprises = <PocEntreprise>[
  PocEntreprise(
    id: "poc-entreprise-1",
    codesRome: ["D1102"],
    nom: "Boulangerie Lemaire",
    secteur: _secteurBoulangerie,
    taille: "6 à 9 salariés",
    lieu: PocLieu(adresse: "12 rue Gambetta", codePostal: "59000", ville: "Lille", latitude: 50.6305, longitude: 3.0510),
    candidatureSimplifiee: true,
  ),
  PocEntreprise(
    id: "poc-entreprise-2",
    codesRome: ["D1102", "D1106"],
    nom: "Boulangerie Saint-Maurice",
    secteur: _secteurBoulangerie,
    taille: "1 ou 2 salariés",
    lieu: PocLieu(adresse: "Rue de Fives", codePostal: "59800", ville: "Lille", latitude: 50.6340, longitude: 3.0800),
    candidatureSimplifiee: true,
  ),
  PocEntreprise(
    id: "poc-entreprise-3",
    codesRome: ["D1102"],
    nom: "Au Pain Doré",
    secteur: _secteurBoulangerie,
    taille: "3 à 5 salariés",
    lieu: PocLieu(
      adresse: "Rue Jean Jaurès",
      codePostal: "59650",
      ville: "Villeneuve-d’Ascq",
      latitude: 50.6250,
      longitude: 3.1420,
    ),
    candidatureSimplifiee: true,
  ),
  PocEntreprise(
    id: "poc-entreprise-4",
    codesRome: ["D1102"],
    nom: "Fournil des Flandres",
    secteur: _secteurBoulangerie,
    taille: "10 à 19 salariés",
    lieu: PocLieu(adresse: "Rue de Roubaix", codePostal: "59200", ville: "Tourcoing", latitude: 50.7220, longitude: 3.1640),
    candidatureSimplifiee: false,
    telephone: "03 53 01 12 34",
  ),
  PocEntreprise(
    id: "poc-entreprise-5",
    codesRome: ["D1106"],
    nom: "Primeurs de Wazemmes",
    secteur: "Commerce de détail de fruits et légumes",
    taille: "3 à 5 salariés",
    lieu: PocLieu(
      adresse: "Place de la Nouvelle Aventure",
      codePostal: "59000",
      ville: "Lille",
      latitude: 50.6255,
      longitude: 3.0505,
    ),
    candidatureSimplifiee: true,
  ),
  PocEntreprise(
    id: "poc-entreprise-6",
    codesRome: ["D1106"],
    nom: "Épicerie fine Vauban",
    secteur: "Autres commerces de détail alimentaires",
    taille: "1 ou 2 salariés",
    lieu: PocLieu(adresse: "Rue Solférino", codePostal: "59000", ville: "Lille", latitude: 50.6330, longitude: 3.0490),
    candidatureSimplifiee: true,
  ),
];

const _competencesCapBoulanger = [
  "Approvisionnement, communication, sécurité alimentaire et hygiène en boulangerie.",
  "Organiser le rangement des produits réceptionnés. Réceptionner et stocker les marchandises d’une livraison.",
  "Appliquer les mesures d’hygiène, de santé et de sécurité des salariés et de sécurité alimentaire.",
  "Contrôler la conformité des produits réceptionnés et rendre compte des non-conformités.",
  "Production et présentation de produits de panification et de boulangerie.",
];

const _objectifsCapBoulanger = [
  "Tu veux préparer chaque jour les meilleures fournées de pains courants, spéciaux et de viennoiseries pour les clients.",
  "Pendant la formation, tu apprends à :",
  "• connaître les matières premières, les recettes et les modes opératoires ;",
  "• préparer les pâtons : malaxer et pétrir les pâtes des pains courants ou spéciaux ;",
  "• tourer et tourner les viennoiseries ;",
  "• enfourner les pâtons et défourner les pains chauds ;",
  "• faire découvrir de nouvelles saveurs à la clientèle,",
  "le tout dans le respect des règles d’hygiène, de santé et de sécurité au travail.",
];

const _campusLille = "Campus des métiers de Lille";
const _campusTelephone = "03 53 01 12 40";
const _campusEmail = "contact@campus-metiers-lille.example";
const _campusLieu = PocLieu(
  adresse: "Rue de l’Innovation, Hellemmes",
  codePostal: "59260",
  ville: "Lille",
  latitude: 50.6270,
  longitude: 3.1100,
);

final pocFormations = <PocFormation>[
  PocFormation(
    id: "poc-formation-1",
    codesRome: ["D1102"],
    intitule: "CAP Boulanger",
    diplome: "CAP · niveau 3",
    niveau: PocNiveau.cap,
    organisme: _campusLille,
    lieu: _campusLieu,
    debut: "4 janvier 2027",
    duree: "2 ans",
    competences: _competencesCapBoulanger,
    objectifs: _objectifsCapBoulanger,
    telephone: _campusTelephone,
    email: _campusEmail,
    rendezVousPossible: true,
  ),
  PocFormation(
    id: "poc-formation-2",
    codesRome: ["D1102"],
    intitule: "CAP Boulanger en 1 an",
    diplome: "CAP · niveau 3",
    niveau: PocNiveau.cap,
    organisme: "CFA de l’artisanat de Tourcoing",
    lieu: PocLieu(adresse: "Rue de Roubaix", codePostal: "59200", ville: "Tourcoing", latitude: 50.7250, longitude: 3.1650),
    debut: "6 septembre 2027",
    duree: "1 an",
    competences: _competencesCapBoulanger,
    objectifs: [
      "Cette formation courte s’adresse aux personnes qui ont déjà un premier diplôme de niveau CAP ou plus.",
      ..._objectifsCapBoulanger,
    ],
    telephone: "03 53 01 12 41",
    email: "cfa-tourcoing@artisanat.example",
    rendezVousPossible: false,
  ),
  PocFormation(
    id: "poc-formation-3",
    codesRome: ["D1102"],
    intitule: "Mention complémentaire Boulangerie spécialisée",
    diplome: "MC · niveau 3",
    niveau: PocNiveau.cap,
    organisme: _campusLille,
    lieu: _campusLieu,
    debut: "6 septembre 2027",
    duree: "1 an",
    competences: ["Fabriquer des pains spéciaux, des pains de tradition et des viennoiseries élaborées."],
    objectifs: ["Après un CAP Boulanger, tu te spécialises dans les pains de tradition et les produits régionaux."],
    telephone: _campusTelephone,
    email: _campusEmail,
    rendezVousPossible: true,
  ),
  PocFormation(
    id: "poc-formation-4",
    codesRome: ["D1102"],
    intitule: "BP Boulanger",
    diplome: "BP · niveau 4",
    niveau: PocNiveau.bac,
    organisme: _campusLille,
    lieu: _campusLieu,
    debut: "6 septembre 2027",
    duree: "2 ans",
    competences: ["Organiser une production, encadrer une petite équipe et gérer une boulangerie."],
    objectifs: ["Le brevet professionnel prépare à devenir ouvrier hautement qualifié, puis chef d’entreprise."],
    telephone: _campusTelephone,
    email: _campusEmail,
    rendezVousPossible: true,
  ),
  PocFormation(
    id: "poc-formation-5",
    codesRome: ["D1106", "D1507", "D1505"],
    intitule: "CAP Équipier polyvalent du commerce",
    diplome: "CAP · niveau 3",
    niveau: PocNiveau.cap,
    organisme: "CFA du commerce de Roubaix",
    lieu: PocLieu(adresse: "Boulevard Gambetta", codePostal: "59100", ville: "Roubaix", latitude: 50.6900, longitude: 3.1780),
    debut: "4 janvier 2027",
    duree: "2 ans",
    competences: ["Réceptionner et stocker les produits.", "Mettre en rayon.", "Accueillir et conseiller les clients."],
    objectifs: ["Devenir équipier ou équipière dans un commerce de proximité ou une grande surface."],
    telephone: "03 53 01 12 42",
    email: "accueil@cfa-commerce-roubaix.example",
    rendezVousPossible: true,
  ),
  PocFormation(
    id: "poc-formation-6",
    codesRome: ["D1106", "D1214", "D1401"],
    intitule: "Bac pro Métiers du commerce et de la vente",
    diplome: "Bac pro · niveau 4",
    niveau: PocNiveau.bac,
    organisme: "Lycée professionnel du Vieux-Lille, section apprentissage",
    lieu: PocLieu(adresse: "Rue Royale", codePostal: "59800", ville: "Lille", latitude: 50.6410, longitude: 3.0570),
    debut: "6 septembre 2027",
    duree: "3 ans",
    competences: ["Conseiller et vendre.", "Suivre les ventes.", "Animer et gérer un espace commercial."],
    objectifs: ["Devenir vendeur ou vendeuse qualifié(e), puis évoluer vers un poste d’adjoint ou de responsable."],
    telephone: "03 53 01 12 43",
    email: "apprentissage@lp-vieux-lille.example",
    rendezVousPossible: false,
  ),
];

// Comme le reste du mode démo (« les résultats sont donnés à titre d'exemples »), une recherche ne vide jamais
// la liste : une ville à plus de 60 km de Lille est remplacée par Lille, un métier sans données de démo par
// « Boulanger / Boulangère ». Les filtres et le rayon, eux, s'appliquent vraiment.
const _rayonAutourDeLilleKm = 60;
const _codeRomeParDefaut = "D1102";

Location _lieuDeDemo(Location lieu) {
  final lille = pocCommunes.first;
  final latitude = lieu.latitude;
  final longitude = lieu.longitude;
  if (latitude == null || longitude == null) return lille;
  final procheDeLille = distanceKm(latitude, longitude, lille.latitude!, lille.longitude!) <= _rayonAutourDeLilleKm;
  return procheDeLille ? lieu : lille;
}

String _codeRomeDeDemo(String codeRome, Iterable<List<String>> codesDisponibles) {
  return codesDisponibles.any((codes) => codes.contains(codeRome)) ? codeRome : _codeRomeParDefaut;
}

PocCriteresMetier _criteresDeDemo(PocCriteresMetier criteres, Iterable<List<String>> codesDisponibles) {
  final codeRome = _codeRomeDeDemo(criteres.metier.codeRome, codesDisponibles);
  return PocCriteresMetier(
    metier: PocMetier(codeRome: codeRome, libelle: criteres.metier.libelle),
    lieu: _lieuDeDemo(criteres.lieu),
    rayon: criteres.rayon,
  );
}

List<PocMission> pocRechercherMissions(PocCriteresBenevolat criteresSaisis, PocFiltresBenevolat filtres) {
  final criteres = PocCriteresBenevolat(activite: criteresSaisis.activite, lieu: _lieuDeDemo(criteresSaisis.lieu));
  final resultats = pocMissions.where((mission) {
    if (criteres.activite != null && mission.activite != criteres.activite) return false;
    if (filtres.domaines.isNotEmpty && !filtres.domaines.contains(mission.domaine)) return false;
    if (filtres.ouverteAuxMineurs && !mission.ouverteAuxMineurs) return false;
    if (filtres.accessiblePmr && !mission.accessiblePmr) return false;
    final aPartirDu = filtres.aPartirDu;
    if (aPartirDu != null && mission.dateDebut.isBefore(aPartirDu)) return false;
    final lieu = mission.lieu;
    if (lieu == null) return filtres.types.isEmpty || filtres.types.contains(PocTypeMission.depuisChezMoi);
    if (filtres.types.isNotEmpty && !filtres.types.contains(PocTypeMission.presDeChezMoi)) return false;
    return lieu.distanceDepuis(criteres.lieu) <= pocRayonBenevolatKm;
  }).toList();
  double distance(PocMission mission) => mission.lieu?.distanceDepuis(criteres.lieu) ?? double.infinity;
  resultats.sort((a, b) => distance(a).compareTo(distance(b)));
  return resultats;
}

List<PocOffreAlternance> pocRechercherOffres(PocCriteresMetier criteresSaisis, PocFiltresNiveau filtres) {
  final criteres = _criteresDeDemo(criteresSaisis, pocOffres.map((offre) => [offre.codeRome]));
  final offres = pocOffres.where((offre) => offre.codeRome == criteres.metier.codeRome && filtres.accepte(offre.niveau));
  return _lesPlusProches(offres, (offre) => offre.lieu, criteres);
}

List<PocEntreprise> pocRechercherEntreprises(PocCriteresMetier criteresSaisis) {
  final criteres = _criteresDeDemo(criteresSaisis, pocEntreprises.map((entreprise) => entreprise.codesRome));
  final entreprises = pocEntreprises.where((entreprise) => entreprise.codesRome.contains(criteres.metier.codeRome));
  return _lesPlusProches(entreprises, (entreprise) => entreprise.lieu, criteres);
}

List<PocFormation> pocRechercherFormations(PocCriteresMetier criteresSaisis, PocFiltresNiveau filtres) {
  final criteres = _criteresDeDemo(criteresSaisis, pocFormations.map((formation) => formation.codesRome));
  final formations = pocFormations.where(
    (formation) => formation.codesRome.contains(criteres.metier.codeRome) && filtres.accepte(formation.niveau),
  );
  return _lesPlusProches(formations, (formation) => formation.lieu, criteres);
}

// Un rayon de 0 km garde la ville elle-même : ses adresses ne sont jamais exactement au centre.
List<T> _lesPlusProches<T>(Iterable<T> elements, PocLieu Function(T) lieuDe, PocCriteresMetier criteres) {
  final rayon = math.max(criteres.rayon, 5);
  final proches = elements.where((element) => lieuDe(element).distanceDepuis(criteres.lieu) <= rayon).toList();
  proches.sort((a, b) => lieuDe(a).distanceDepuis(criteres.lieu).compareTo(lieuDe(b).distanceDepuis(criteres.lieu)));
  return proches;
}
