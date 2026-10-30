class PocOffresStrings {
  // Tuiles de « Explorer par type », visibles en mode démo seulement.
  static String tuileAlternanceEmoji = "🛠️";
  static String tuileAlternanceTitre = "Alternance LBA";
  static String tuileAlternanceSousTitre = "Offres et entreprises";
  static String tuileBenevolatEmoji = "❤️";
  static String tuileBenevolatTitre = "Bénévolat";
  static String tuileBenevolatSousTitre = "Missions ponctuelles";
  static String tuileFormationEmoji = "🎓";
  static String tuileFormationTitre = "Formation en alternance";
  static String tuileFormationSousTitre = "Apprentissage & contrat pro";

  // Critères
  static String benevolatTitre = "Bénévolat";
  static String alternanceTitre = "Offres d’alternance";
  static String formationTitre = "Formation en alternance";
  static String activite = "Activité";
  static String toutesLesActivites = "Toutes";
  static String lieuMission = "Lieu de la mission";
  static String lieuFormation = "Lieu de la formation";
  static String lieu = "Lieu";
  static String lieuAide = "Ville ou code postal";
  static String metier = "Métier";
  static String metierAide = "Choisis un métier dans la liste. Exemple : boulanger, vendeur";
  static String metierAucun = "Aucun métier ne correspond. Essaie un autre mot.";
  static String communeAucune = "Aucune ville ne correspond. En mode démo, la liste est courte : essaie Lille.";
  static String metierSuppression = "Supprimer le métier";
  static String communeSuppression = "Supprimer la ville";
  static String voirLesOffres = "Voir les offres";
  static String voirLesMissions = "Voir les missions";
  static String voirLesFormations = "Voir les formations";

  // Résultats
  static String nombreMissions(int n) => n > 1 ? "$n missions" : "$n mission";
  static String nombreOffres(int n) => n > 1 ? "$n offres" : "$n offre";
  static String nombreFormations(int n) => n > 1 ? "$n formations" : "$n formation";
  static String nombreEntreprises(int n) => n > 1 ? "$n entreprises qui recrutent" : "1 entreprise qui recrute";
  static String entreprisesExplication =
      "Elles n’ont pas publié d’offre, mais recrutent souvent des alternants pour ce métier. Tu peux leur envoyer une candidature spontanée.";
  static String candidatureSpontanee = "Candidature spontanée";
  static String missionADistance = "Mission à distance";
  static String aucunResultatTitre = "Aucun résultat";
  static String aucunResultatMetier = "Aucun résultat ne correspond à tes filtres. Essaie avec moins de filtres ou un rayon plus grand.";
  static String aucunResultatBenevolat = "Aucune mission ne correspond à ta recherche. Essaie une autre activité ou moins de filtres.";

  // Filtres
  static String filtrerMissions = "Filtrer les missions";
  static String filtrerAnnonces = "Filtrer les annonces";
  static String filtrerFormations = "Filtrer les formations";
  static String typeDeMissions = "Type de missions";
  static String presDeChezMoi = "Près de chez moi";
  static String depuisChezMoi = "Depuis chez moi";
  static String domaines = "Domaines";
  static String typeDePublic = "Type de public";
  static String ouvertAuxMineurs = "Ouvert aux mineurs";
  static String accessiblePmr = "Accessible PMR";
  static String periode = "Période";
  static String aPartirDe = "À partir de";
  static String niveauEtudes = "Niveau d’études visé";

  // Fiches
  static String detailsMission = "Détails de la mission";
  static String detailsOffre = "Détails de l’offre";
  static String detailsEntreprise = "Détails de l’entreprise";
  static String detailsFormation = "Détails de la formation";
  static String aPartirDu(String date) => "À partir du $date";
  static String jusquAu(String date) => "Jusqu’au $date";
  static String benevolesRecherches(int n) => n > 1 ? "$n bénévoles recherchés" : "1 bénévole recherché";
  static String prerequis = "Prérequis pour réaliser cette mission";
  static String publicAide = "Public aidé";
  static String missionOuverte = "Mission ouverte";
  static String auxMajeurs = "Aux bénévoles majeurs";
  static String auxMineurs = "Aux bénévoles mineurs, dès 16 ans";
  static String presentationMission = "Présentation de la mission";
  static String laStructure = "La structure";
  static String decouvrez(String organisation) => "Découvrez $organisation";
  static String jeProposeMonAide = "Je propose mon aide";
  static String description = "Description";
  static String profilSouhaite = "Profil souhaité";
  static String qualites = "Qualités souhaitées pour ce métier";
  static String competencesAcquises = "Compétences acquises durant l’alternance";
  static String domainesTechniques = "Domaines et techniques de travail";
  static String accessibleA = "À qui ce métier est-il accessible ?";
  static String presentationEntreprise = "Présentation de l’entreprise";
  static String renseigneToi =
      "Renseigne-toi sur l’entreprise, ses activités et ses valeurs pour préparer ta candidature. Tu peux chercher son site internet et sa présence sur les réseaux sociaux.";
  static String adresse = "Adresse";
  static String voirSurUneCarte = "Voir sur une carte";
  static String informationsComplementaires = "Informations complémentaires";
  static String tailleEntreprise(String taille) => "Taille de l’entreprise : $taille";
  static String secteurActivite(String secteur) => "Secteur d’activité : $secteur";
  static String siteWeb = "Site web";
  static String jePostuleIci = "Je postule ici";
  static String jePostule = "Je postule";
  static String partagerAuConseiller = "Partager à mon conseiller";
  static String partageTitre = "Partage à ton conseiller";
  static String partageEffectue = "C’est partagé avec ton conseiller sur la messagerie de l’application.";
  static String pourquoiEntreprise = "Pourquoi cette entreprise ?";
  static String pourquoiEntrepriseTexte(String metier) =>
      "Elle n’a pas publié d’offre, mais recrute souvent des alternants pour le métier « $metier ». Une candidature spontanée a de bonnes chances d’être lue.";
  static String envoyerCandidatureSpontanee = "Envoyer une candidature spontanée";
  static String appelerEntreprise = "Appeler l’entreprise";
  static String descriptionFormation = "Description de la formation";
  static String competences = "Compétences";
  static String objectifs = "Objectifs";
  static String informationsEtablissement = "Informations sur l’établissement";
  static String telephone(String numero) => "Téléphone : $numero";
  static String rechercheGoogle = "Lancer une recherche Google :";
  static String demanderRendezVous = "Demander un rendez-vous";
  static String contacterCfa = "Contacter le CFA";
  static String contacterCfaTexte = "Ce CFA ne prend pas de rendez-vous en ligne. Contacte-le directement.";
  static String appelerCfa = "Appeler le CFA";
  static String ecrireCfa = "Écrire au CFA";
  static String emailCfa(String email) => "E-mail : $email";

  // Candidature
  static String envoyerMaCandidature = "Envoyer ma candidature";
  static String envoyerMaCandidatureSpontanee = "Envoyer ma candidature spontanée";
  static String nom = "Nom *";
  static String prenom = "Prénom *";
  static String email = "E-mail *";
  static String telephoneChamp = "Téléphone *";
  static String telephoneAide = "Exemple : 06 12 34 56 78";
  static String tonCv = "Ton CV *";
  static String tonCvFranceTravail = "Ton CV France Travail *";
  static String cvFormat = "Le CV doit être au format PDF ou Word (.docx) et ne doit pas dépasser 3 Mo.";
  static String ajouterMonCv = "Ajouter mon CV";
  static String consulter = "Consulter";
  static String modifier = "Modifier";
  static String retirer = "Retirer";
  static String choisirCv = "Choisir mon CV";
  static String cvFranceTravailListe = "Tes CV France Travail";
  static String cvDuTelephone = "Prendre un autre fichier";
  static String cvApercuDemo = "En mode démo, le CV ne s’ouvre pas.";
  static String messageRecruteur = "Un message pour le recruteur";
  static String messageAide = "Un message personnalisé augmente tes chances d’obtenir un contact avec le recruteur.";
  static String jEnvoieMaCandidature = "J’envoie ma candidature";
  static String erreurNom = "Renseigne ton nom.";
  static String erreurPrenom = "Renseigne ton prénom.";
  static String erreurEmail = "Renseigne une adresse e-mail valide, par exemple nom@domaine.fr.";
  static String erreurTelephone = "Renseigne un numéro de téléphone à 10 chiffres.";
  static String erreurCvAbsent = "Ajoute ton CV.";
  static String erreurCvTropLourd = "Ton CV dépasse 3 Mo. Choisis un fichier plus léger.";
  static String erreurCvFormat = "Ton CV doit être au format PDF ou Word (.docx).";
  static String erreurCvLecture = "Impossible de lire ce fichier. Réessaie avec un autre.";

  // Confirmation
  static String candidatureEnvoyee = "Candidature envoyée";
  static String bravo(String prenom) => prenom.isEmpty ? "Bravo ! 🎉" : "Bravo, $prenom ! 🎉";
  static String confirmationTexte =
      "Le recruteur a reçu ta candidature par e-mail.\n\nS’il est intéressé, il te répondra par e-mail ou par téléphone. Pense à regarder tes messages.";
  static String voirAutresOffres = "Voir d’autres offres";
  static String monSuiviDesOffres = "Mon suivi des offres";

  // Accessibilité
  static String ajouterAuSuivi(String titre) => "Suivre $titre";
  static String retirerDuSuivi(String titre) => "Ne plus suivre $titre";
}
