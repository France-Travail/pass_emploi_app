import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';

class _PassEmploiStrings {
  static String appName = "pass emploi";
  static String logoDescription = "Pass emploi";
  static String shouldInformConseiller =
      "En cas d’imprévu, il est important de prévenir votre conseiller. Vous pouvez le contacter via la messagerie de l’application";
  static String suppressionAccountLabel = "Supprimer mon compte de l’application pass emploi";
  static String warningInformationParagraph1 =
      "En supprimant votre compte de l’application pass emploi, vous perdrez définitivement toutes les données présentes sur l’application :";
  static String warningInformationParagraph2 =
      "La suppression de votre compte sur l’application pass emploi n'entraîne pas la suppression de votre accompagnement.";
  static String accountDeletionSuccess = "Votre compte a bien été supprimé de l’application pass emploi";
  static String modeDemoExplicationPremierPoint3 = " l’application pass emploi utilisée par vos bénéficiaires.";
  static String legalNoticeUrl = "https://doc.pass-emploi.beta.gouv.fr/legal/pass_emploi_mentions_legales";
  static String privacyPolicyUrl =
      "https://doc.pass-emploi.beta.gouv.fr/legal/mobile_pass_emploi_politique_de_confidentialite";
  static String termsOfServiceUrl =
      "https://doc.pass-emploi.beta.gouv.fr/legal/mobile_pass_emploi_conditions_generales";
  static String accessibilityUrl =
      "https://doc.pass-emploi.beta.gouv.fr/legal/mobile_pass_emploi_accessibilite_application";
}

class _CejStrings {
  static String appName = "CEJ";
  static String logoDescription = "Contrat d'Engagement Jeune";
  static String shouldInformConseiller =
      "En cas d’imprévu, il est important de prévenir ton conseiller. Tu peux le contacter via la messagerie de l’application";
  static String suppressionAccountLabel = "Supprimer mon compte de l’application CEJ";
  static String warningInformationParagraph1 =
      "En supprimant ton compte de l’application CEJ, tu perdras définitivement toutes les données présentes sur l’application :";
  static String warningInformationParagraph2 =
      "La suppression de ton compte sur l’application CEJ n'entraîne pas la suppression de ton accompagnement.";
  static String accountDeletionSuccess = "Ton compte a bien été supprimé de l’application CEJ";
  static String modeDemoExplicationPremierPoint3 = " l’application CEJ utilisée par tes bénéficiaires.";
  static String legalNoticeUrl = "https://doc.pass-emploi.beta.gouv.fr/legal/mobile_mentions_legales";
  static String privacyPolicyUrl =
      "https://travail-emploi.gouv.fr/application-contrat-dengagement-jeune-cej-traitement-des-donnees-personnelles";
  static String termsOfServiceUrl = "https://doc.pass-emploi.beta.gouv.fr/legal/mobile_conditions_generales";
  static String accessibilityUrl = "https://doc.pass-emploi.beta.gouv.fr/legal/mobile_accessibilite_application";
}

class Strings {
  Strings._();

  // Common
  static String appName = Brand.isCej() ? _CejStrings.appName : _PassEmploiStrings.appName;
  static String error = "Une erreur s’est produite";
  static String retry = "Réessayer";
  static String logoDescription = Brand.isCej() ? _CejStrings.logoDescription : _PassEmploiStrings.logoDescription;
  static String close = "Fermer";
  static String yes = "Oui";
  static String no = "Non";
  static String or = "ou";
  static String ajouter = "Ajouter";
  static String cancelLabel = "Annuler";
  static String confirmLabel = "Confirmer";
  static String suppressionLabel = "Supprimer";
  static String cacher = "Cacher";
  static String refuserLabel = "Refuser";
  static String consulter = "Consulter";
  static String copie = "Copié";
  static String notConnected = Brand.isPassEmploi() ? "Vous êtes hors connexion" : "Tu es hors connexion";
  static const String mandatoryFields = "Les champs marqués d’une * sont obligatoires.";
  static const String allMandatoryFields = "Tous les champs sont obligatoires.";
  static String duplicate = "Dupliquer";
  static String clear = "Effacer le texte";
  static const String back = 'Retour';
  static const String noData = "Aucune donnée";

  static String stepCounter(int current, int total) => "Étape $current sur $total";
  static String selectDateTooltip = "Sélectionner une date";
  static String removeDateTooltip = "Supprimer la date";
  static String newFeature = "Nouveauté";

  // Login mode
  static const String milo = "Mission Locale";
  static const String franceTravail = "France Travail";
  static const String accompagnementIntensif = "Accompagnement intensif";
  static const String accompagnementGlobal = "Accompagnement global";
  static const String equipEmploiRecrut = "Equip emploi recrut";

  // Menu
  static String menuAccueil = "Accueil";
  static String menuMonSuivi = "Agenda";
  static const String menuChat = "Messages";
  static String menuSolutions = "Offres";
  static String menuFavoris = "Favoris";
  static String menuRendezvous = "Rendez-vous";
  static String menuProfil = "Mon profil";
  static String menuEvenements = "Événements";

  // Chat
  static String yourMessage = Brand.isPassEmploi() ? "Votre message…" : "Ton message…";
  static String yourConseiller = "Ton conseiller";
  static String today = "Aujourd'hui";
  static String edited = "Modifié";
  static String read = "Lu";
  static String sent = "Envoyé";
  static String sending = "Envoi en cours";
  static String sendingFailed = "L'envoi a échoué";
  static String sendMessageTooltip = "Envoyer le message";
  static String sendAttachmentTooltip = "Envoyer une pièce jointe";
  static String chatError = Brand.isPassEmploi()
      ? "Erreur lors de la récupération de votre messagerie"
      : "Erreur lors de la récupération de ta messagerie";
  static String chatTabMonConseiller = "Mon conseiller";
  static String chatTabMaMissionLocale = "Ma mission locale";
  static String actualiteMissionLocaleEmptyTitle = "Retrouve ici les actualités de ta mission locale";
  static String actualiteMissionLocaleEmptySubtitle = "Pas d'actualités publiées pour le moment";
  static String actualiteMissionLocaleError = "Erreur lors de la récupération des actualités";
  static String newConseillerTitle = Brand.isPassEmploi()
      ? "Vous échangez avec votre nouveau conseiller."
      : "Tu échanges avec ton nouveau conseiller.";
  static String newConseillerTemporaireTitle = Brand.isPassEmploi()
      ? "Vous échangez temporairement avec un nouveau conseiller."
      : "Tu échanges temporairement avec un nouveau conseiller.";
  static String newConseillerDescription = Brand.isPassEmploi()
      ? "Il a accès à l’historique de vos échanges."
      : "Il a accès à l’historique de tes échanges.";
  static String unknownTypeTitle = "Le message est inaccessible";
  static String unknownTypeDescription = Brand.isPassEmploi()
      ? "Pour avoir l'accès au contenu, veuillez mettre à jour l'application."
      : "Pour avoir l'accès au contenu, mets à jour l'application.";
  static String voirOffre = "Voir l'offre";
  static String voirEvent = "Voir l'événement";

  static String chatWith(firstName) => "Discuter avec $firstName";

  static String simpleDayFormat(day) => "Le $day";
  static String open = "Ouvrir";
  static String fileNotAvailableError = "ERROR: 410";
  static String fileNotAvailableTitle = "Le fichier n'est plus disponible";
  static String chatEmpty = Brand.isPassEmploi()
      ? "Commencez une conversation avec votre conseiller"
      : "Commence une conversation avec ton conseiller";
  static String chatEmptySubtitle = Brand.isPassEmploi()
      ? "Obtenez les informations que vous recherchez en contactant directement votre conseiller"
      : "Obtiens les informations que tu recherches en contactant directement ton conseiller";
  static String hourAndPostOwner(String hour, String owner) => "$hour · Posté par $owner";

  static String chatMessageBottomSheetTitle = "Paramètres du message";
  static String chatCopyMessage = "Copier";
  static String chatDeleteMessage = "Supprimer";
  static String chatEditMessage = "Modifier";

  static String chatExpiredPjMessage = "Pièce jointe expirée";
  static String chatDeletedMessage = "Message supprimé";
  static String chatEditMessageAppBar = "Modifier le message";
  static String editMessageSave = "Modifier";

  static String chatDeletedMessageContent = "(Message supprimé)";

  static String chatOpenPieceJointe = "Ouvrir la pièce jointe";
  static String chatPieceJointeBottomSheetTitle = "Ajouter une pièce jointe";
  static String chatPieceJointeBottomSheetSubtitle = Brand.isPassEmploi()
      ? "Attention à ne pas partager vos données personnelles ou d’informations sensibles notamment votre numéro de Sécurité Sociale (ex : Carte Vitale, etc.)"
      : "Attention à ne pas partager tes données personnelles ou d’informations sensibles notamment ton numéro de Sécurité Sociale (ex : Carte Vitale, etc.)";
  static String chatPieceJointeBottomSheetTakeImageButton = "Prendre une photo";
  static String chatPieceJointeBottomSheetSelectImageButton = "Sélectionner une photo";
  static String chatPieceJointeBottomSheetSelectFileButton = "Sélectionner un fichier";
  static String chatPieceJointeBottomSheetFileTooLarge =
      "Le fichier est trop volumineux. Merci de sélectionner un fichier de moins de 5 Mo.";
  static String chatPieceJointeGalleryPermissionError = Brand.isPassEmploi()
      ? "Autorisez l’accès à la galerie pour pouvoir sélectionner une image."
      : "Autorise l’accès à la galerie pour pouvoir sélectionner une image.";
  static String chatPieceJointeCameraPermissionError = Brand.isPassEmploi()
      ? "Autorisez l’accès à l'appareil photo pour pouvoir prendre une photo."
      : "Autorise l’accès à l'appareil photo pour pouvoir prendre une photo.";
  static String chatPieceJointeFilePermissionError = Brand.isPassEmploi()
      ? "Autorisez l’accès aux fichiers pour pouvoir sélectionner un fichier."
      : "Autorise l’accès aux fichiers pour pouvoir sélectionner un fichier.";
  static String chatPieceJointeOpenAppSettings = "Accéder aux paramètres";
  static String chatA11yMessageFromMe = "Mon message : ";
  static String chatA11yMessageFromMyConseiller = "Message de mon conseiller : ";
  static String chatA11yLastMessage = "Dernier message : ";

  // Force Update
  static String updateTitle = "Mise à jour";
  static String updateButton = "Mettre à jour";
  static String forceUpdateOnStoreLabel = Brand.isPassEmploi()
      ? "Votre application nécessite d'être mise à jour pour son bon fonctionnement"
      : "Ton application nécessite d'être mise à jour pour son bon fonctionnement";
  static String forceUpdateOnFirebaseLabel =
      "Ton application nécessite d'être mise à jour sur Firebase pour son bon fonctionnement";

  // Soft Update
  static String softUpdateBottomSheetTitle = Brand.isPassEmploi()
      ? "Votre application n'est pas à jour"
      : "Ton application n'est pas à jour";
  static String softUpdateBottomSheetSubtitle =
      "Une version plus récente est disponible. La mise à jour ne prend que quelques secondes.";
  static String softUpdateBottomSheetDownload = "Télécharger";
  static String softUpdateBottomSheetClose = "Plus tard";

  // First Launch Onboarding
  static String firstLaunchOnboardingTagline = "Tes envies,\ntes projets,\ntes solutions.";
  static String firstLaunchOnboardingDescription =
      "L'app des 15-25 ans qui t'accompagne dans tous tes projets : études, emploi, logement, mobilité, santé, loisirs et bien plus";

  static String firstLaunchOnboardingCardTitle1 =
      "Des suggestions d’actions personnalisées pour démarrer selon tes objectifs";
  static String firstLaunchOnboardingCardTitle2 = "Des offres d’emploi et des événements adaptés à ton projet";
  static String firstLaunchOnboardingCardTitle3 = "Echange avec ton conseiller pour t’aider";

  // Entree
  static String republiqueFrancaise = "République Française, liberté, égalité, fraternité";
  static String askAccount = "Demander un compte";
  static String loginChooseAccountTitle = "Choisis un compte";
  static String loginChooseAccountDescription =
      "Si tu disposes de plusieurs accès, sélectionne l'organisme qui t'accompagne actuellement.";
  static String loginPassEmploiTitle = "Bienvenue";
  static String loginPassEmploiSubtitle = "L'app dédiée à votre accompagnement";
  static String loginPassEmploiDescription =
      "Utilisez votre compte France Travail pour accéder à vos messages, vos démarches, offres et rendez-vous.";
  static String loginInviteAccessTitle = "Accès invité";
  static String loginInviteAccessPasswordLabel = "Mot de passe";
  static String loginInviteAccessWrongPassword = "Mot de passe incorrect";
  static String loginInviteAccessValidate = "Valider";
  static String suiviParConseillerCej =
      "Dans le cadre de mon Contrat d'Engagement Jeune, je suis suivi par un conseiller :";
  static String suiviParConseillerPassEmploi = "Je suis suivi par un conseiller :";
  static String dontHaveAccount = "Tu n’as pas de compte sur cette application ?";

  static String alreadyHaveAccount = "Tu as déjà un compte\n sur cette application ?";
  static String accessibilityPartiallyConform = "Accessibilité : partiellement conforme";
  static String accessibilityNotConform = "Accessibilité : non conforme";

  // Onboarding
  static String skip = "Passer";
  static String continueLabel = "Continuer";
  static String gotIt = "C'est compris";
  static String discover = "Découvrir";

  static String onboardingMonSuiviTitle = "Pas à pas, trouve un emploi stable";
  static String onboardingChatTitle = "Garde le contact avec ton conseiller à tout moment";
  static String onboardingRechercheTitle = "Trouve des offres qui t'intéressent";
  static String onboardingEvenementsTitle = "Participe à des événements en lien avec ta recherche";
  static String onboardingOffreEnregistreeTitle = "Nouveau\u{00A0}!";

  static String onboardingMonSuiviBodyCej =
      "Mon suivi te permet de créer et visualiser les différentes actions ou rendez-vous à réaliser. Ton conseiller peut aussi ajouter des actions dans cette section !";
  static String onboardingMonSuiviBodyPe =
      "Mon suivi te permet de créer et visualiser les différentes démarches ou rendez-vous à réaliser. Ton conseiller peut aussi ajouter des démarches dans cette section !";
  static String onboardingChatBody =
      "Échange sur la messagerie instantanée avec ton conseiller pour construire ton projet, partager des offres, t'inscrire à des évènements, etc.";
  static String onboardingRechercheBodyCej =
      "L’espace recherche te permet de retrouver les offres d’emploi d’alternance, d’immersion et de service civique, et de les ajouter à tes offres suivies.";
  static String onboardingRechercheBodyPe =
      "L’espace recherche te permet de retrouver les offres d’emploi qui t'intéressent et de les ajouter à tes offres suivies.";
  static String onboardingEvenementsBody =
      "Découvre les événements à ne pas manquer en lien avec ta recherche et inscris-toi pour y participer.";
  static String onboardingOffreEnregistreeBody = "Retrouve maintenant tes favoris dans l’onglet “Suivi des offres”";

  static String takeRdvWithConseiller =
      "Prends rendez-vous avec ton conseiller qui procédera à la création de ton compte.";
  static String whoIsConcerned = "Qui est éligible ?";
  static List<String> whoIsConcernedFirstRichText = [
    "→ Les personnes entre ",
    "16 et 25 ans",
    " (moins de ",
    "30 ans",
    " pour celles en situation de handicap)",
  ];
  static List<String> whoIsConcernedSecondRichText = [
    "→ Les personnes qui ne sont ",
    "pas en formation ni en emploi durable",
    " (CDI ou CDD de longue durée)",
  ];

  static String installOnboardingSection = Brand.isPassEmploi() ? "Installez l’application" : "Installe l’application";
  static String messageOnboardingSection = Brand.isPassEmploi()
      ? "Envoyez un message à votre conseiller"
      : "Envoie un message à ton conseiller";
  static String planActionOnboardingSection = "Explore les suggestions d’action";
  static String actionOnboardingSection = "Crée une action dans l’agenda";
  static String demarcheOnboardingSection = Brand.isPassEmploi()
      ? "Créez une démarche dans l’agenda"
      : "Crée une démarche dans l’agenda";
  static String offreOnboardingSection = Brand.isPassEmploi() ? "Recherchez une offre" : "Recherche une offre";
  static String evenementOnboardingSection = Brand.isPassEmploi()
      ? "Recherchez un événement"
      : "Recherche un événement";
  static String outilsOnboardingSection = "Consulte les outils";

  static String skipOnboarding = "Passer le tutoriel";
  static String skipOnboardingContent = Brand.isPassEmploi()
      ? "Êtes-vous sûr de vouloir passer le tutoriel ?"
      : "Es-tu sûr de vouloir passer le tutoriel ?";

  static String onboardingShowcaseMessageTitle = Brand.isPassEmploi()
      ? "Saluez votre conseiller."
      : "Salue ton conseiller.";
  static String onboardingShowcaseActionTitle = Brand.isPassEmploi() ? "Lancez-vous !" : "Lance-toi !";
  static String onboardingShowcaseOffreTitle = "Un emploi en tête?";
  static String onboardingShowcaseEvenementTitle = Brand.isPassEmploi()
      ? "Explorez les événements en lien avec votre projet pro"
      : "Explore les événements en lien avec ton projet pro";
  static String onboardingShowcasePlanActionTitle = "Tes suggestions t’attendent";
  static String onboardingShowcaseOutilsTitle = "Besoin d’un coup de pouce?";
  static String onboardingShowcaseMessageDescription = Brand.isPassEmploi()
      ? "Envoyez-lui un premier message “Bonjour ! j’ai bien téléchargé l’application, j’ai hâte de commencer !”"
      : "Envoie-lui un premier message “Bonjour ! j’ai bien téléchargé l’application, j’ai hâte de commencer !”";
  static String onboardingShowcaseActionDescription = Brand.isPassEmploi()
      ? "Créez une première action pour vous rapprocher de votre objectif "
      : "Crée une première action pour te rapprocher de ton objectif ";
  static String onboardingShowcaseOffreDescription = Brand.isPassEmploi()
      ? "Lancez votre recherche pour découvrir des opportunités qui correspondent à vos critères"
      : "Lance ta recherche pour découvrir des opportunités qui correspondent à tes critères";
  static String onboardingShowcaseEvenementDescription = Brand.isPassEmploi()
      ? "Participez à des salons, forums, ateliers pour faire avancer votre projet pro"
      : "Participe à des salons, forums, ateliers pour faire avancer ton projet pro";
  static String onboardingShowcasePlanActionDescription =
      "Ouvre une catégorie pour découvrir les suggestions d’action.";
  static String onboardingShowcaseOutilsDescription = "Retrouve les bons outils pour te guider à chaque étapes";

  static String onboardingStepFinished = Brand.isPassEmploi()
      ? "🎉 Bravo, vous avez validé une étape du tutoriel !"
      : "🎉 Bravo, tu as validé une étape du tutoriel !";

  static String mesOutils = "Mes outils";
  static String mesOutilsDescription = Brand.isPassEmploi()
      ? "Trouver l’aide adaptée à votre projet professionnel"
      : "Trouver l’aide adaptée à ton projet professionel";
  static String decouvrirLeService = "Découvrir le service";

  // Login organisms
  static const String loginBottomSeetFranceTravailButton = "France Travail";
  static const String loginBottomSeetMissionLocaleButton = "Mission Locale";

  // Login
  static String loginWrongDeviceClockError = Brand.isPassEmploi()
      ? "L'heure de votre téléphone semble erronée, impossible de vous connecter."
      : "L'heure de ton téléphone semble erronée, impossible de te connecter.";
  static String loginWrongDeviceClockErrorDescription = Brand.isPassEmploi()
      ? "Accédez aux réglages de votre téléphone pour vérifier que l’heure et le fuseau horaire affichés sont corrects."
      : "Accède aux réglages de ton téléphone pour vérifier que l’heure et le fuseau horaire affichés sont corrects.";
  static String loginGenericError = "Erreur lors de la connexion";
  static String loginGenericErrorDescription = Brand.isPassEmploi()
      ? "Réessayez plus tard. Si le problème persiste, vous pouvez contacter votre conseiller."
      : "Réessaie plus tard. Si le problème persiste, tu peux contacter ton conseiller.";
  static String loginPoleEmploi = "France Travail";
  static String loginMissionLocale = "Mission Locale";
  static String loginAction = "Se connecter";

  // Mode invité
  static String invitePrenomTitle = "Ton prénom";
  static String invitePrenomSubtitle = "Choisis le prénom qui sera affiché dans l'application.";
  static String invitePrenomHint = "Ton prénom";
  static String invitePrenomValidate = "Valider";
  static String invitePrenomLoadError = "Impossible de récupérer ton prénom.";
  static String invitePrenomUpdateError = "La mise à jour a échoué. Réessaie.";
  static String invitePrenomUpdated(String prenom) => "Enregistré. Bonjour $prenom !";
  static String invitePrenomNextSteps = "La suite du parcours invité reste à développer.";
  static String logoutAction = "Me déconnecter";

  // Onboarding invité
  static String onboardingQuestionnaireBack = "Retour";
  static String onboardingQuestionnaireContinue = "Continuer";
  static String onboardingQuestionnaireSkip = "Passer cette étape";
  static String onboardingQuestionnaireStepOf(int current, int total) => "Étape $current sur $total";

  static String onboardingQuestionnairePrenomTitle = "Ton prénom";
  static String onboardingQuestionnairePrenomSubtitle =
      "Juste ton prénom, pour te parler normalement. Rien d'autre. 🙂";
  static String onboardingQuestionnairePrenomLabel = "Ton prénom";

  static String onboardingQuestionnaireBirthdateTitle = "Ta date de naissance";
  static String onboardingQuestionnaireBirthdateGreeting(String? prenom) {
    final trimmed = prenom?.trim() ?? '';
    if (trimmed.isEmpty) return "Salut ! L'app est réservée aux 15-25 ans.";
    return "Salut $trimmed ! L'app est réservée aux 15-25 ans.";
  }

  static String onboardingQuestionnaireBirthdateSubtitle =
      "Cette information nous sert à adapter les aides et dispositif auxquels tu as droit. 🎂";
  static String onboardingQuestionnaireBirthdateLabel = "Date de naissance";
  static String onboardingQuestionnaireBirthdateDayLabel = "Jour";
  static String onboardingQuestionnaireBirthdateMonthLabel = "Mois";
  static String onboardingQuestionnaireBirthdateYearLabel = "Année";
  static String onboardingQuestionnaireUnderAgeTitle = "Reviens dans quelque temps\u{00A0}!";
  static String onboardingQuestionnaireUnderAgeDescription = "Cette appli est destinée aux jeunes de 15 à 25 ans.";
  static String onboardingQuestionnaireUnderAgeNoticeTitle = "Encore un peu de patience";
  static String onboardingQuestionnaireUnderAgeNoticeDescription =
      "Tu pourras l’utiliser dès tes 15 ans. À très vite pour explorer tes pistes ensemble\u{00A0}!";

  static String onboardingQuestionnaireHabitationTitle = "Où habites-tu ?";
  static String onboardingQuestionnaireHabitationSubtitle =
      "Pour te proposer des aides ou dispositif près de chez toi.";
  static String onboardingQuestionnaireHabitationLabel = "Ville ou code postal";
  static String onboardingQuestionnaireGeolocate = "Me géolocaliser";

  static String onboardingQuestionnaireSituationTitle = "Où en es-tu ?";
  static String onboardingQuestionnaireSituationSubtitle =
      "Une seule réponse, choisis celle qui te correspond le plus.";
  static String onboardingQuestionnaireSituationCollege = "Au collège";
  static String onboardingQuestionnaireSituationLycee = "Au lycée";
  static String onboardingQuestionnaireSituationEtudes = "En études supérieures";
  static String onboardingQuestionnaireSituationEmploi = "En emploi";
  static String onboardingQuestionnaireSituationAutre = "Autre situation";

  static String onboardingQuestionnaireObjectifsTitle = "Comment peux-t-on t'aider ?";
  static String onboardingQuestionnaireObjectifsSubtitle =
      "Sélectionne tout ce qui t'intéresse. Tu peux en choisir plusieurs.";
  static String onboardingQuestionnaireObjectifOrienter = "M'orienter";
  static String onboardingQuestionnaireObjectifDecouvrirMetiers = "Découvrir des métiers";
  static String onboardingQuestionnaireObjectifFormer = "Me former, me qualifier";
  static String onboardingQuestionnaireObjectifStage = "Trouver un stage, une immersion";
  static String onboardingQuestionnaireObjectifAlternance = "Trouver une alternance";
  static String onboardingQuestionnaireObjectifEmploi = "Trouver un emploi";
  static String onboardingQuestionnaireObjectifEngager = "M'engager";
  static String onboardingQuestionnaireObjectifMobilite = "Faire une mobilité internationale";
  static String onboardingQuestionnaireObjectifAccompagne = "Être accompagné dans mes démarches";
  static String onboardingQuestionnaireObjectifCreerActivite = "Créer mon activité";
  static String onboardingQuestionnaireObjectifVieQuotidienne = "Vie quotidienne";

  static String onboardingQuestionnaireDomaineTitle = "Dans quel métier ou domaine d'activité ?";
  static String onboardingQuestionnaireDomaineSubtitle =
      "Un métier ou un secteur en tête ? Ça nous aide à te suggérer les bonnes offres.";
  static String onboardingQuestionnaireDomaineLabel = "Métier ou secteur";
  static String onboardingQuestionnaireDomaineUnknown = "Je ne sais pas encore";

  static String onboardingQuestionnaireVilleTitle = "Dans quelle ville cherches-tu ?";
  static String onboardingQuestionnaireVilleSubtitle = "Ta ville et jusqu'où tu es prêt·e à te déplacer.";
  static String onboardingQuestionnaireVilleLabel = "Ville ou code postal";
  static String onboardingQuestionnaireVilleOr = "Ou";
  static String onboardingQuestionnaireRayonLabel = "Dans un rayon de recherche";
  static String onboardingQuestionnaireRayonDescription(int km) => "de $km km";
  static String onboardingQuestionnaireRayonValue(int km) => "$km";

  static String onboardingQuestionnaireFreinsTitle = "Quelles sont tes contraintes ?";
  static String onboardingQuestionnaireFreinsSubtitle = "Sélectionne ce qui te freine. Tu peux en choisir plusieurs";
  static String onboardingQuestionnaireFreinPasDePermis = "Pas de permis";
  static String onboardingQuestionnaireFreinPasDeTransport = "Pas de moyens de transport";
  static String onboardingQuestionnaireFreinPasDeLogement = "Pas de logement stable";
  static String onboardingQuestionnaireFreinManqueConfiance = "Manque de confiance";
  static String onboardingQuestionnaireFreinFinDeMois = "Fin de mois difficile";
  static String onboardingQuestionnaireFreinPasDeDiplome = "Pas de diplôme";
  static String onboardingQuestionnaireFreinPeuExperience = "Peu d'expérience professionnelle";
  static String onboardingQuestionnaireFreinHandicap = "Situation de handicap";
  static String onboardingQuestionnaireFreinSante = "Un problème de santé";
  static String onboardingQuestionnaireFreinGardeEnfant = "Garde d'enfant";
  static String onboardingQuestionnaireFreinNumerique = "Difficulté avec le numérique";
  static String onboardingQuestionnaireFreinFrancais = "Difficulté avec le Français";
  static String onboardingQuestionnaireFreinRienNeMeBloque = "Rien ne me bloque";

  static String onboardingQuestionnaireLoaderTitle = "On construit tes suggestions d'actions";
  static String onboardingQuestionnaireLoaderSubtitle =
      "Quelques secondes le temps de croiser tes réponses avec nos solutions.";
  static String onboardingQuestionnaireLoaderProgression = "Progression";
  static String onboardingQuestionnaireLoaderProgressPercent(int percent) => "$percent%";
  static String onboardingQuestionnaireLoaderProfil = "Ton profil";
  static String onboardingQuestionnaireLoaderPrenom = "Prénom";
  static String onboardingQuestionnaireLoaderSituation = "Situation";
  static String onboardingQuestionnaireLoaderDomaine = "Domaine";
  static String onboardingQuestionnaireLoaderZone = "Zone";
  static String onboardingQuestionnaireLoaderZoneValue(String ville, int km) => "$ville · $km km";
  static String onboardingQuestionnaireLoaderObjectifsCount(int count) =>
      "$count ${count == 1 ? 'objectif' : 'objectifs'}";
  static String onboardingQuestionnaireLoaderContraintesCount(int count) =>
      "$count ${count == 1 ? 'contrainte' : 'contraintes'}";
  static String onboardingQuestionnaireLoaderStepRead = "On lit ton profil";
  static String onboardingQuestionnaireLoaderStepSolutions = "On sélectionne les solutions près de chez toi";
  static String onboardingQuestionnaireLoaderStepBuild = "On construit tes suggestions d'actions";
  static String onboardingQuestionnaireLoaderStepOrder = "On ordonne tes prochaines actions";
  static String onboardingQuestionnaireGeolocateError =
      "Impossible de récupérer ta position. Réessaie ou saisis une ville.";

  static String inviteAccueilGreeting(String? prenom) {
    final name = prenom?.trim();
    if (name == null || name.isEmpty) return "Bonjour 👋";
    return "Bonjour\n$name 👋";
  }

  static String inviteAccueilPlanTitle = "Mes pistes à explorer";
  static String inviteAccueilPlanSubtitleComplet =
      "Voici nos suggestions d’actions. Coche-les au fur et à mesure de ton avancement, et supprime celles qui ne t'intéressent pas.";
  static String inviteAccueilPlanSubtitlePartiel =
      "Voici tes premières actions. D’autres t’attendent une fois ton questionnaire complété";
  static String inviteAccueilPlanSubtitleIncomplet =
      "Tes suggestions d’actions apparaîtront ici une fois ton questionnaire terminé.";
  static String inviteAccueilQuestionnaireTitle = "Complète ton questionnaire";
  static String inviteAccueilQuestionnaireDescription =
      "Réponds aux dernières questions pour recevoir des suggestions d’actions plus adaptées.";
  static String inviteAccueilQuestionnaireDescriptionIncomplet =
      "Réponds à quelques questions pour recevoir des suggestions d’actions adaptées.";
  static String inviteAccueilDiscoveryTitle = "Je découvre l’application en quelques clics.";
  static String inviteAccueilDiscoveryProgress(int percent) => "$percent%";
  static String inviteAccueilProfilComplete = "Profil complété";
  static String inviteAccueilStepsCount(int current, int total) => "$current/$total étapes";
  static String inviteAccueilResumeQuestionnaire = "Reprendre le questionnaire";
  static String inviteAccueilModifier = "Modifier";
  static String actionPlanFeedbackTitle = "Avant de continuer";
  static String actionPlanFeedbackDescription = "Dis-nous ce que tu as pensé des pistes d’actions suggérées\u{00A0}?";
  static String actionPlanFeedbackGiveOpinion = "Donne ton avis";
  static String actionPlanDeclarationQuand = "Quand as-tu fait cette action\u{00A0}?";
  static String actionPlanDeclarationDecrire = "Décrire mon action";
  static String actionPlanDeclarationDecrireAide =
      "Ajoute des détails pour que ton conseiller puisse valider l’action.";
  static String actionPlanDeclarationDecrireExemple = "Exemple : j’ai cherché des offres d’emploi pour le métier…";
  static String actionPlanDeclarationSolutionRetiree = "Cette action n’est plus proposée.";
  static String actionPlanDeclarationIndisponible =
      "Le service est momentanément indisponible, réessaie dans quelques instants.";
  static String actionPlanDeclarationSuccesEnregistree = "L’action est enregistrée. Retrouve-la dans ton agenda.";
  static String actionPlanDeclarationSuccesConseiller =
      "Ton conseiller en est informé. Tu pourras en discuter lors de ton prochain rendez-vous\u{00A0}!";
  static String actionPlanDeclarationVoirAgenda = "Voir mon agenda";
  static String actionPlanDeclarationOuvreFormulaireA11y = "Ouvre le formulaire de déclaration";
  static String actionPlanDeclarationRetourPlan = "Retour au plan d’action";
  static String inviteAccueilExplorerTipTitle = "💡 Pas envie de répondre maintenant?";
  static String inviteAccueilExplorerTipBody = "Tu peux explorer librement les offres et les événements depuis le menu";
  static String inviteAccueilConseillerTitle = "Être accompagné par un conseiller ?";
  static String inviteAccueilConseillerBody = "Un professionnel près de chez toi peut t'aider à avancer.";
  static String inviteAccueilAfficherPlus = "Afficher plus";
  static String inviteAccueilObjectiveFeedbackTitle = "Ces actions t'ont été utiles ?";
  static String inviteAccueilObjectiveFeedbackYes = "Oui";
  static String inviteAccueilObjectiveFeedbackNo = "Pas vraiment";
  static String inviteAccueilObjectiveFeedbackNoA11y = "Ouvre un formulaire dans ton navigateur";
  static String inviteAccueilObjectiveFeedbackThanks = "Merci pour ton retour !";
  static String inviteAccueilRetryPlan = "Réessayer de générer mes suggestions";
  static String inviteAccueilPlanFailureTitle = "Tes suggestions d'actions n'ont pas pu être générées";
  static String inviteAccueilPlanFailureBody =
      "Impossible de générer tes suggestions d'actions pour le moment. Réessaie dans un instant.";
  static String inviteAccueilRetryLoadPlan = "Réessayer";
  static String inviteAccueilPlanLoadingFailureTitle = "Tes suggestions d'actions n'ont pas pu être chargées";
  static String inviteAccueilPlanLoadingFailureBody =
      "Impossible de charger tes suggestions d'actions pour le moment. Réessaie dans un instant.";
  static String inviteAccueilPlanEmptyTitle = "Tes suggestions d'actions ne sont pas disponibles";
  static String inviteAccueilPlanEmptyBody =
      "Aucune action n'a pu être proposée pour le moment. Modifie tes réponses pour obtenir de nouvelles suggestions.";
  static String inviteAccueilProgressBadge(int done, int total) => "$done/$total";
  static String inviteAccueilProgressA11y(int done, int total) => "$done actions faites sur $total";
  static String inviteAccueilDeleteActionA11y(String action) => "Supprimer l'action $action";
  static String inviteAccueilActionDeletedA11y(String action) => "Action $action supprimée";
  static String inviteAccueilPlanLoadingA11y = "Chargement de tes pistes à explorer";
  static String inviteAccueilDiscoveryProgressA11y(int percent) => "Découverte de l'application : $percent % terminé";
  static String inviteAccueilDiscoveryHideA11y = "Masquer la découverte de l'application";
  static String inviteAccueilStepsCountA11y(int current, int total) => "$current étapes sur $total";
  static String onboardingQuestionnaireStepA11y(int current, int total, String title) =>
      "Étape $current sur $total, $title";

  // Card and subcomponents
  static const String emploiTag = "Offre d’emploi";
  static const String alternanceTag = "Alternance";
  static const String immersionTag = "Immersion";
  static const String serviceCiviqueTag = "Service civique";

  static const String todoPillule = "À réaliser";
  static const String doingPillule = "À faire";
  static const String donePillule = "Terminée";
  static const String latePillule = "En retard";
  static const String canceledPillule = "Annulée";
  static const String newPillule = "Nouveau";

  // Onboarding
  static String onboardingTitle = Brand.isPassEmploi()
      ? "Terminez la découverte de l’application"
      : "Termine la découverte de l’application";
  static String onboardingSubtitle = Brand.isPassEmploi()
      ? "Touchez une fonctionnalité pour l’essayer, elle se coche automatiquement."
      : "Touche une fonctionnalité pour l’essayer, elle se coche automatiquement.";
  static String onboardingStepCompleted = "Étape terminée";

  // notifications bottom sheet
  static String notificationsBottomSheetTitle = Brand.isPassEmploi()
      ? "Activez les notifications"
      : "Active les notifications";
  static String notificationsBottomSheetContent = Brand.isPassEmploi()
      ? "Abonnez-vous pour recevoir les messages importants, rappel des rendez-vous, nouvelles offres ou événements adaptés à vos critères"
      : "Abonne toi pour recevoir les messages importants, rappel des rendez-vous, nouvelles offres ou événements adaptés à tes critères";
  static String notificationsBottomSheetButton = "Activer les notifications";
  static String notificationsBottomSheetDismissButton = "Pas maintenant";

  // Accueil
  static String accueilAppBarTitle = "Bonjour";
  static String onboardingAccueilTitle = Brand.isPassEmploi()
      ? "Découvrez l’application en quelques étapes"
      : "Découvre l’application en quelques étapes";
  static String onboardingAccueilTitleCompleted = Brand.isPassEmploi()
      ? "🎉 Vous avez terminé le tutoriel !"
      : "🎉 Tu as terminé le tutoriel !";
  static String accueilCetteSemaineSection = "Cette semaine";
  static String accueilVoirDetailsCetteSemaine = "Voir le détail de ma semaine";
  static String accueilRendezvousSection = Brand.isPassEmploi()
      ? "Votre prochain rendez-vous"
      : "Ton prochain rendez-vous";
  static String accueilActionSingular = "Action";
  static String accueilActionPlural = "Actions";
  static String accueilError = Brand.isPassEmploi()
      ? "Erreur lors de la récupération de votre page d’accueil"
      : "Erreur lors de la récupération de ta page d’accueil";
  static String accueilDemarcheSingular = "Démarche";
  static String accueilDemarchePlural = "Démarches";
  static String accueilRendezvous = "Rendez-vous";
  static String accueilEvenementsSection = "Événements pouvant t'intéresser";
  static String accueilVoirLesEvenements = "Voir plus d’événements";
  static String accueilMesAlertesSection = "Mes alertes";
  static String accueilVoirMesAlertes = "Voir toutes mes alertes";
  static String accueilPasDalerteDescription = Brand.isPassEmploi()
      ? "Créez des alertes lors de vos recherches et recevez les offres qui vous correspondent"
      : "Crée des alertes lors de tes recherches et reçois les offres qui te correspondent";
  static String accueilPasDalerteBouton = "Commencer une recherche";
  static String accueilOffresEnregistreesSection = "Mon suivi des offres";
  static String accueilOutilsSection = "Outils";
  static String accueilOutilsSectionDescription = "Découvre des outils pour t'aider dans tes projets";
  static String accueilVoirLesOutils = "Voir tous les outils";

  // Comptage des heures
  static String comptageDesHeures0To5 = "Bon début, continue comme ça\u{00A0}!\u{00A0}💪";
  static String comptageDesHeures5To10 = "Bon début, continue comme ça\u{00A0}!\u{00A0}💪";
  static String comptageDesHeures10To15 =
      "Tu te rapproches de ton objectif : encore un petit effort\u{00A0}!\u{00A0}🌟";
  static String comptageDesHeures15 = "🎉 Félicitations pour tes 15h d’activités \u{00A0}!";
  static String comptageDesHeures15Plus = "Objectif dépassé ! Bravo\u{00A0}👏";
  static String updatedAgo(String timeAgo) => "Actualisé $timeAgo";
  static String realizedHours = "validée";
  static String declaredHours = "réalisée";

  static String comptageDesHeuresError = "Il y a eu une erreur lors de la récupération de tes heures\u{00A0}😕";

  static String comptageDesHeuresEnCoursDeCalcul(int heuresEnCoursDeCalcul) => heuresEnCoursDeCalcul == 1
      ? "1 activité en cours de calcul.\nProchaine actualisation dans moins d’une heure"
      : "$heuresEnCoursDeCalcul activités en cours de calcul.\nProchaine actualisation dans moins d’une heure";

  // Mon Suivi
  static String agendaTitle = "Agenda";
  static String monSuiviCetteSemaine = "Cette semaine";
  static String monSuiviSemaineProchaine = "Semaine prochaine";
  static String monSuiviSemaineIntervalSameMonth(
    int startDay,
    int endDay,
    String month,
  ) => "Semaine du $startDay au $endDay $month";
  static String monSuiviSemaineIntervalDifferentMonths(
    int startDay,
    String startMonth,
    int endDay,
    String endMonth,
  ) => "Semaine du $startDay $startMonth au $endDay $endMonth";
  static String monSuiviEmptyPastMilo = "Aucun événement ni action";
  static String monSuiviEmptyPastPoleEmploi = "Aucun rendez-vous ni démarche";
  static String monSuiviEmptyFuture = "Rien de prévu";
  static String monSuiviError = Brand.isPassEmploi()
      ? "Erreur lors de la récupération de votre suivi"
      : "Erreur lors de la récupération de ton suivi";
  static String monSuiviSessionMiloError = "Des événements n’ont peut-être pas pu être récupérés.";
  static String monSuiviTooltip = "Aller à aujourd'hui";
  static String monSuiviPePastLimitReached = "Les démarches et les rendez-vous plus anciens ne sont pas disponibles";
  static String monSuiviPeFutureLimitReached = "Les démarches et les rendez-vous plus récents ne sont pas disponibles";
  static String monSuiviPoleEmploiDataError = "Certaines démarches et rendez-vous ne sont peut-être pas à jour.";
  static String monSuiviA11yPreviousPeriodButton = "Afficher la période précédente";
  static String monSuiviA11yNextPeriodButton = "Afficher la période suivante";

  // Actualisation  PE
  static String actualisationPePopUpTitle = "La période d’actualisation France Travail a commencé";
  static String actualisationPePopUpSubtitle = Brand.isPassEmploi()
      ? "Pensez à vous actualiser avant le 15 du mois"
      : "Pense à t'actualiser avant le 15 du mois";
  static String actualisationPePopUpPrimaryButton = "S'actualiser";
  static String actualisationPePopUpSecondaryButton = "Fermer";

  // Rendezvous
  static String eventTitle = "Événement";
  static String myRendezVous = "Mon rendez-vous";
  static String rendezvousCardAnnule = "Annulé";
  static String rendezvousDetailsAnnule = "Rendez-vous annulé";
  static String rendezVousConseillerCommentLabel = "Commentaire de mon conseiller";
  static String cannotGoToRendezvous = Brand.isPassEmploi()
      ? "Vous ne pouvez pas vous rendre au rendez-vous ?"
      : "Tu ne peux pas te rendre au rendez-vous ?";
  static String shouldInformConseiller = Brand.isCej()
      ? _CejStrings.shouldInformConseiller
      : _PassEmploiStrings.shouldInformConseiller;

  static String rendezVousDetailsError = "Erreur lors de la récupération de l'événement";
  static String conseillerIsPresent = Brand.isPassEmploi()
      ? "Votre conseiller sera présent"
      : "Ton conseiller sera présent";
  static String conseillerIsNotPresent = Brand.isPassEmploi()
      ? "Votre conseiller ne sera pas présent"
      : "Ton conseiller ne sera pas présent";
  static String commentWithoutConseiller = "Description";
  static String rendezVousDetails = "Détails";
  static String seeItinerary = 'Voir l\'itinéraire';
  static String seeVisio = 'Accéder à la visio';
  static String rendezvousVisioModalityMessage =
      'Le rendez-vous se fera en visio. La visio sera disponible le jour du rendez-vous.';
  static String withConseiller = " avec ";
  static String individualInterview = "Entretien individuel";
  static String publicInfo = "Information collective";
  static String shareToConseiller = "Partager à mon conseiller";
  static String shareToConseillerDemandeInscription = "Faire une demande d’inscription";
  static String autoInscriptionCta = "M'inscrire pour participer";
  static String annulerInscription = "Annuler mon inscription";
  static String withAnimateurTitle = "Animateur de la session";

  static String rendezvousWithConseiller(String conseiller) =>
      Brand.isPassEmploi() ? "votre conseiller $conseiller" : "ton conseiller $conseiller";

  static String rendezvousCreateur(String createur) {
    return Brand.isPassEmploi()
        ? "Le rendez-vous a été programmé par votre conseiller précédent $createur"
        : "Le rendez-vous a été programmé par ton conseiller précédent $createur";
  }

  static String rendezvousModalityDetailsMessage(String modality) => "Le rendez-vous se fera $modality";

  static String rendezvousModalityCardMessage(
    String modality,
    String conseiller,
  ) => "$modality avec $conseiller";
  static String placesRestantes(int count) => "$count ${count == 1 ? placesRestanteSingulier : placesRestantePluriel}";
  static String placesRestanteSingulier = "place restante";
  static String placesRestantePluriel = "places restantes";

  static String phone(String phone) => "Téléphone : $phone";

  // App evaluation

  static String nextButtonTitle = "Suivant";
  static String validateButtonTitle = "Valider";
  static String mandatory = "Les questions marquées d'une * sont obligatoires";
  static String pourquoiTitle = Brand.isPassEmploi()
      ? "Pouvez-vous nous en dire plus ?"
      : "Peux-tu nous en dire plus ?";
  static String evaluationSuccessfullySent = Brand.isPassEmploi()
      ? "Merci pour vos précieux retours\u{00A0}!"
      : "Merci pour tes précieux retours\u{00A0}!";
  static String pourquoiHintText = Brand.isPassEmploi() ? "Dites-nous pourquoi..." : "Dis-nous pourquoi...";

  // User action form
  static const String createActionAppBarTitle = 'Créer une action';
  static const String userActionBackButton = 'Retour';
  static const String userActionNextButton = 'Continuer';
  static const String userActionFinishButton = 'Terminer';

  static const String userActionTitleStep3 = 'Date et description';

  static const String userActionSubtitleStep1 = 'Choisis une catégorie';

  static const String userActionSubtitleStep2 = 'Sélectionne une action (obligatoire)';
  static const String userActionTitleTextfieldStep2 = '*Nommer mon action';
  static const String userActionDescriptionTextfieldStep2 = 'Décrire mon action';
  static const String userActionDescriptionDescriptionfieldStep2 =
      'Ajouter des détails pour que ton conseiller puisse valider ton action.';

  static const String userActionStatusRadioStep3 = 'L’action est :';
  static const String userActionStatusRadioCompletedStep3 = 'Terminée';
  static const String userActionStatusRadioTodoStep3 = 'En cours';
  static const String datePickerTitle = 'Date';
  static const String datePickerTitleMandatory = '*Date';

  static const String dateSuggestionAujourdhui = 'Aujourd’hui';
  static const String dateSuggestionDemain = 'Demain';
  static const String dateSuggestionHier = 'Hier';

  static const String userActionEmploiLabel = 'Emploi';
  static const String userActionProjetProfessionnelLabel = 'Projet pro';
  static const String userActionCultureSportLoisirsLabel = 'Sport et loisirs';
  static const String userActionCitoyenneteLabel = 'Citoyenneté';
  static const String userActionFormationLabel = 'Formation';
  static const String userActionLogementLabel = 'Logement';
  static const String userActionSanteLabel = 'Santé';

  static const String userActionEmploiDescription = 'Recherches, candidatures';
  static const String userActionProjetProfessionnelDescription = 'Définir un projet professionnel';
  static const String userActionCultureSportLoisirsDescription = 'Cours de sport, salle, sorties';
  static const String userActionCitoyenneteDescription = 'Démarches, passer le permis';
  static const String userActionFormationDescription = 'En présentiel ou en ligne';
  static const String userActionLogementDescription = 'Recherches de logement';
  static const String userActionSanteDescription = 'Rendez-vous médicaux';

  static const String userActionConfirmationTitleSingular = "Action créée";
  static const String userActionConfirmationTitlePlural = "Action(s) créée(s)";
  static String userActionConfirmationTitle(String firstName) {
    final name = firstName.trim();
    if (name.isEmpty) return "Bravo ! 🎉";
    return "Bravo, $name ! 🎉";
  }

  static const String userActionConfirmationDoneTag = "Action terminée";
  static String userActionConfirmationSubtitle(String actionContent) =>
      "L’action « $actionContent », est enregistrée.\n\nTon conseiller en est informé. Tu pourras en discuter ensemble lors de ton prochain rendez-vous\u{00A0}!";
  static const String userActionConfirmationSubtitleLegacy =
      "L’action est en route vers ton conseiller. Tu pourras en discuter ensemble lors de ton prochain rendez-vous\u{00A0}!";
  static const String userActionConfirmationSubtitlePlural =
      "La ou les actions sont en route vers ton conseiller. Tu pourras en discuter ensemble lors de ton prochain rendez-vous\u{00A0}!";
  static const String goToMonSuivi = "Consuter Mon suivi";

  static const String userActionConfirmationSeeDetailButton = "Consulter mon action";
  static const String userActionConfirmationCreateMoreButton = "Créer une autre action";

  static const String userActionDescriptionConfirmationTitle = "Cette action ne contient aucune description.";
  static const String userActionDescriptionConfirmationSubtitle =
      "Ton conseiller risque de ne pas pouvoir valider cette action.";
  static const String userActionDescriptionConfirmationConfirmButton = "Ajouter une description";
  static const String userActionDescriptionConfirmationGoToDescriptionButton = "Créer l’action sans description";
  static const String userActionDescriptionConfirmationTerminer = "Terminer l'action sans description";
  static String fieldMaxLengthExceeded(int maxLength) => "La limite de $maxLength caractères a été atteinte";

  // Emploi
  static const String faireMonCV = "Faire mon CV";
  static const String hintFaireMonCV = "J'ai mis à jour mon CV...";

  static const String rechercheEmploi = "Recherche d'emploi";
  static const String hintRechercheEmploi = "J'ai cherché des offres...";

  static const String candidature = "Candidature";
  static const String hintCandidature = "J'ai déposé mon CV...";

  static const String entretienEmbauche = "Entretien d'embauche";
  static const String hintEntretienEmbauche = "J'ai eu un entretien...";

  static const String lettreMotivationEmploi = "Lettre de motivation";
  static const String hintLettreMotivationEmploi = "J'ai rédigé ma lettre de motivation...";

  static const String rechercheStageEmploi = "Recherche de stage";
  static const String hintRechercheStageEmploi = "J'ai cherché des stages...";

  // Projet Professionnel
  static const String rechercheStageProjetPro = "Recherche de stage";
  static const String hintRechercheStageProjetPro = "J'ai cherché des stages...";

  static const String formationProjetPro = "Formation";
  static const String hintFormationProjetPro = "J'ai fait une formation...";

  static const String revisions = "Révisions";
  static const String hintRevisions = "J'ai révisé...";

  static const String rechercheAlternance = "Recherche d'alternance";
  static const String hintRechercheAlternance = "J'ai cherché des alternances...";

  static const String enqueteMetier = "Enquête métier";
  static const String hintEnqueteMetier = "J'ai été poser des questions...";

  static const String lettreMotivationProjetPro = "Lettre de motivation";
  static const String hintLettreMotivationProjetPro = "J'ai mis à jour ma lettre de motivation...";

  // Citoyenneté
  static const String examenPermis = "Examen permis, code";
  static const String hintExamenPermis = "J'ai passé mon permis...";

  static const String codeRoute = "Code de la route";
  static const String hintCodeRoute = "J'ai été à une séance de code...";

  static const String conduite = "Conduite";
  static const String hintConduite = "J'ai fait une séance de conduite...";

  static const String demarchesAdministratives = "Démarches administratives";
  static const String hintDemarchesAdministratives = "J'ai été à la mairie...";

  static const String demandeAllocations = "Demande d'allocations";
  static const String hintDemandeAllocations = "J'ai déposé mon dossier...";

  static const String benevolat = "Bénévolat";
  static const String hintBenevolat = "J'ai fait 2h de bénévolat...";

  // Santé
  static const String rendezVousMedical = "Rendez-vous médical";
  static const String hintRendezVousMedical = "J'ai été à un rendez-vous médical...";

  static const String bilanSante = "Bilan de santé";
  static const String hintBilanSante = "J'ai effectué un bilan...";

  static const String carteVitale = "Carte vitale";
  static const String hintCarteVitale = "J'ai fait les démarches pour...";

  static const String demarchesSante = "Démarches de santé";
  static const String hintDemarchesSante = "J'ai déposé ma demande...";

  static const String hospitalisation = "Hospitalisation";
  static const String hintHospitalisation = "J'ai été...";

  static const String reeducation = "Rééducation";
  static const String hintReeducation = "J'ai été à ma séance de kiné...";

  // Logement
  static const String rechercheLogement = "Recherche de logement";
  static const String hintRechercheLogement = "J'ai cherché un appartement...";

  static const String constitutionDossier = "Constitution d'un dossier";
  static const String hintConstitutionDossier = "J'ai rédigé une attestation...";

  static const String visiteLogement = "Visite de logement";
  static const String hintVisiteLogement = "J'ai visité un appartement...";

  static const String achatImmobilier = "Achat immobilier";
  static const String hintAchatImmobilier = "J'ai été faire évaluer ma capacité d'emprunt...";

  static const String demandeAideLogement = "Demande d'aide logement";
  static const String hintDemandeAideLogement = "J'ai envoyé des documents...";

  // Formation
  static const String rechercheFormation = "Recherche de formation";
  static const String hintRechercheFormation = "J'ai fait des recherches...";

  static const String rechercheApprentissage = "Recherche d'apprentissage";
  static const String hintRechercheApprentissage = "J'ai identifié des offres...";

  static const String atelier = "Atelier";
  static const String hintAtelier = "J'ai participé à l'atelier CV...";

  static const String rechercheSubvention = "Recherche de subvention";
  static const String hintRechercheSubvention = "J'ai identifié les subventions...";

  // Loisirs, Sport, Culture
  static const String sport = "Sport";
  static const String hintSport = "J'ai fait 2h de football...";

  static const String cinema = "Cinéma";
  static const String hintCinema = "J'ai été voir \"Horizon\" au cinéma...";

  static const String expositionMusee = "Exposition, musée";
  static const String hintExpositionMusee = "J'ai été voir les expositions du \"Voyage à Nantes\"...";

  static const String spectacleConcert = "Spectacle, concert";
  static const String hintSpectacleConcert = "J'ai été voir la comédie musicale \"le Roi Lion\" au théâtre...";

  static const String dessinMusiqueLecture = "Dessin, musique, lecture";
  static const String hintDessinMusiqueLecture =
      "J'ai été à mon cours de piano, j'ai lu le roman l'Alchimiste de Paulo Coelho...";

  // Autre
  static const String userActionOther = "Autre";
  static const String hintUserActionOther = "Je précise l'activité réalisée, son objectif...";

  // User Action
  static const String exampleHint = "Exemple : ";
  static String aboutThisAction = "À propos de cette action";
  static String actionDetails = "Mon action";
  static String demarcheDetails = "Détail";
  static String completeAction = "Terminer mon action";
  static String unCompleteAction = "Je n’ai pas terminé mon action";
  static String userActionDetailsSection = "Détails";
  static String userActionDate = "Date";
  static String userActionCategory = "Catégorie";
  static String userActionNoCategory = "Aucune";
  static String updateStatus = "Modifier le statut";
  static String refreshActionStatus = "Valider le statut";
  static String addAnAction = "Créer une action";
  static String addAMessageError = Brand.isPassEmploi()
      ? "Vous avez dépassé le nombre de caractères autorisés"
      : "Tu as dépassé le nombre de caractères autorisés";
  static String create = "Créer";
  static String actionLabel = "*Intitulé de l'action";
  static String actionDescription = "Description de l'action";
  static String mandatoryActionLabelError = "L'intitulé de l'action doit être renseigné";
  static String mandatoryDateEcheanceError = "La date d'échéance doit être renseignée";
  static String defineActionStatus = "Définir le statut";
  static String actionCreatedBy = "Créée par";
  static String duplicateAction = "Ajouter une date";
  static String deleteDuplicatedAction = "Supprimer cette action";
  static String fillAllFields = "Merci de remplir tous les champs";
  static String dateMandatory = "La date est obligatoire";
  static String descriptionMandatory = "La description est obligatoire";
  static String selectMultipleActions = "Sélectionne une ou plusieurs dates et renseigne la description";
  static String selectOneAction = "Sélectionne une date et renseigne la description";

  static String actionCreationInfos(String creator, String date) => "Ajouté par $creator le $date";
  static String youLowercase = "tu";
  static String you = "Tu";
  static String yourConseillerLowercase = "ton conseiller";
  static String congratulationsActionUpdated =
      "Félicitations !\n\nLa mise à jour de ton action a bien été prise en compte";
  static String understood = "J'ai compris";
  static String deleteActionError = "Erreur lors de la suppression de l'action. Réessaie";
  static String deleteActionSuccessTitle = "Action supprimée";
  static String deleteActionSuccess = "L’action a bien été supprimée";
  static String createActionSuccess = "Ton action a bien été créée.";
  static String createActionPostponed =
      " Ton action a bien été créée. Le détail sera disponible au rétablissement du réseau.";
  static String createDemarcheSuccess = "La démarche a bien été créée";
  static String linkDetailsRendezVous = "Voir les détails du rendez-vous";

  static String dateEcheanceFormat(String formattedDate) => "À réaliser pour le $formattedDate";
  static String doneActionsTitle = "Actions terminées et annulées";
  static String rappelSwitch = 'Recevoir une notification de rappel 3 jours avant l’échéance';

  static String numberOfActions(int count) => "$count actions";

  static String numberOfDemarches(int count) => "$count démarches";
  static String see = "Voir";
  static String pendingActionCreationSingular = "1 action est en attente de réseau.";

  static String pendingActionCreationPlural(int count) => "$count actions sont en attente de réseau.";

  static String userActionDetailsError = "Erreur lors de la récupération de l'action";

  // User action bottom sheet
  static String userActionBottomSheetTitle = "Éditer l’action";
  static String userActionBottomSheetDelete = "Supprimer";
  static String userActionBottomSheetEdit = "Modifier";
  static String moreActions = "Plus d’actions";
  static String markActionAsDone = "Marquer comme terminé";
  static String completeActionNotYet = "Pas encore";
  static String actionDoneWhen = "Tu l'as terminée quand ?";
  static String otherDate = "Autre date";
  static String cannotFinishActionInFuture = "On ne peut pas terminer une action dans le futur.";

  // User action done bottom sheet
  static String userActionDoneBottomSheetTitle = "Quand as-tu terminé l'action ?";
  static String updateActionConfirmation = "La mise à jour de ton action a bien été prise en compte";

  // Update user action
  static String updateUserActionPageTitle = "Modifier l'action";
  static String updateUserAction = "Modifier l'action";
  static String updateUserActionTitle = "*Titre de l'action";
  static String updateUserActionDescriptionTitle = "Décrire mon action";
  static String updateUserActionDescriptionSubtitle = "Des précisions à partager à ton conseiller ?";
  static String updateUserActionCategory = "Catégorie";
  static String updateUserActionCategoryPressedTip = "Modifier";
  static String updateUserActionSaveButton = "Enregistrer les modifications";
  static String updateUserActionConfirmationTitle = "Modification enregistrée";
  static String updateUserActionConfirmation = "Tes modifications ont été enregistrées.";
  static String deleteAction = "Supprimer l'action";
  static String deleteActionDescription = "Tu ne pourras plus consulter ni modifier l'action.";

  // Duplicate user action
  static String duplicateUserAction = "Dupliquer l'action";
  static String duplicateUserActionConfirmationTitle = "Action dupliquée";

  // Commentaires d'action
  static String actionCommentsTitle = "Commentaire de l’action";
  static String lastComment = "Dernier commentaire";
  static String noComments = "Tu n’as pas encore de commentaire";

  static String createdByAdvisor(String advisor) => "Ton conseiller $advisor";
  static String addComment = "Ajouter un commentaire";

  static String seeNComments(String n) => "Voir les $n commentaires";
  static String commentsUnavailableOffline = "Les commentaires de l'action ne sont pas disponibles hors connexion.";

  // Demarches
  static String demarcheDoneButton = "Terminer ma démarche";
  static String modifierStatut = "Modifier le statut";
  static String historiqueDemarche = "Historique";
  static String modifiedBy = "Modifiée le ";
  static String createdBy = "Créée le ";
  static String par = " par ";
  static String votreConseiller = Brand.isPassEmploi() ? "votre conseiller" : "ton conseiller";
  static const String late = "En retard : ";
  static String createDemarcheAppBarTitle = Brand.isPassEmploi() ? "Créer vos démarches" : "Créer tes démarches";
  static const String createOneDemarcheAppBarTitle = "Créer une démarche";
  static const String commentaire = "Commentaire";
  static const String descriptionDemarche = "Décrire la démarche";
  static const String caracteres255 = "255 caractères maximum";
  static const String quand = "Quand";
  static const String selectEcheance = "Sélectionner une date d'échéance";
  static String addADemarche = Brand.isPassEmploi() ? "Créer vos démarches" : "Créer tes démarches";
  static const String createDemarcheTitle = "Création d'une démarche";
  static const String createDemarcheStep2EmptyTitle = "Aucune démarche ne correspond à ta recherche";

  static String createDemarcheStep2EmptyTitleWithQuery(String query) =>
      "Aucune démarche ne correspond à ta recherche “$query”";
  static const String createDemarcheStep2EmptySubtitle = "Essaie de reformuler ou lance une nouvelle recherche";
  static const String noDemarcheFound = "Aucune démarche pre-renseignée n’a été trouvée";
  static const String selectDemarcheOrCreatePersonnalisee =
      "Sélectionne une démarche ou crée une démarche personnalisée";
  static const String createDemarchePersonnaliseeTitle = "Créer une démarche personnalisée";
  static const String descriptionDemarchePersonnaliseeLabel = "Description de la démarche (obligatoire)";
  static String selectDemarche = Brand.isPassEmploi() ? "Sélectionnez la démarche" : "Sélectionne la démarche";
  static String selectMoyen = Brand.isPassEmploi() ? "Sélectionnez le moyen" : "Sélectionne le moyen";
  static const String addALaDemarche = "Créer la démarche";
  static const String validateLaDemarche = "Valider ma démarche";
  static const String searchDemarcheHint = "Renseigne un mot clé pour rechercher une démarche à créer";
  static const String searchDemarcheButton = "Rechercher une démarche";
  static const String mandatoryField = "Le champ est obligatoire";
  static const String comment = "Comment";
  static const String selectComment = "Sélectionner un des moyens";
  static const String selectQuand = "Sélectionner une date d’échéance";
  static const String demarcheConfirmationDoneTag = "Démarche terminée";
  static const String demarcheConfirmationDoneTagPlural = "Démarches terminées";
  static String demarcheSuccessSubtitlePlural = Brand.isPassEmploi()
      ? "Les démarches sont enregistrées. Retrouvez-les dans votre agenda.\n\nVotre conseiller en est informé. Vous pourrez en discuter avec lui lors de votre prochain rendez-vous\u{00A0}!"
      : "Les démarches sont enregistrées. Retrouve-les dans ton agenda.\n\nTon conseiller en est informé. Tu pourras en discuter avec lui lors de ton prochain rendez-vous\u{00A0}!";

  static String demarcheActiveLabel = "À réaliser pour le ";

  static String demarcheActiveDateFormat(String formattedDate) => demarcheActiveLabel + formattedDate;

  static String demarcheDoneLabel = "Réalisé le ";

  static String demarcheDoneDateFormat(String formattedDate) => demarcheDoneLabel + formattedDate;

  static String demarcheCancelledLabel = "Annulée le ";

  static String demarcheCancelledDateFormat(String formattedDate) => demarcheCancelledLabel + formattedDate;

  static String updateStatusError = Brand.isPassEmploi()
      ? "Erreur lors de la modification de l'action. Veuillez réessayer"
      : "Erreur lors de la modification de l'action. Réessaie";

  static String withoutDate = "Date indéterminée";
  static String withoutContent = "Démarche indéterminée";
  static String createByAdvisor = "Créé par ton conseiller";
  static String demarcheRechercheSubtitle = "Rechercher par mot-clé";
  static String demarcheCategoriesSubtitle = "Rechercher par catégories";
  static String customDemarcheTitle = Brand.isPassEmploi()
      ? "Vous ne trouvez pas ce que vous cherchez ?"
      : "Tu ne trouves pas ce que tu cherches ?";
  static String customDemarcheSubtitle = Brand.isPassEmploi()
      ? "Créez une démarche personnalisée qui correspond à votre situation."
      : "Crée une démarche personnalisée qui correspond à ta situation.";

  static String demarcheBottomSheetTitle = "Éditer la démarche";

  static String demarcheSuccessSubtitle = Brand.isPassEmploi()
      ? "La démarche est enregistrée. Retrouvez-la dans votre agenda.\n\nVotre conseiller en est informé. Vous pourrez en discuter avec lui lors de votre prochain rendez-vous\u{00A0}!"
      : "La démarche est enregistrée. Retrouve-la dans mon agenda.\n\nTon conseiller en est informé. Tu pourras en discuter avec lui lors de ton prochain rendez-vous\u{00A0}!";
  static String demarcheSuccessConsulter = "Consulter ma démarche";
  static String demarcheSuccessCreerUneAutre = "Créer une autre démarche";
  static String createDemarcheErreur = Brand.isPassEmploi()
      ? "Erreur lors de la création de la démarche. Veuillez réessayer plus tard"
      : "Erreur lors de la création de la démarche. Réessaie plus tard";

  static String demarcheDoneBottomSheetTitle = Brand.isPassEmploi()
      ? "Quand avez-vous terminé la démarche ?"
      : "Quand as-tu terminé la démarche ?";

  static String jeValide = "Je valide";
  static String felicitations = "Félicitations !";
  static String updateDemarcheConfirmation = Brand.isPassEmploi()
      ? "La mise à jour de votre démarche a bien été prise en compte"
      : "La mise à jour de ta démarche a bien été prise en compte";
  static String cancelDemarche = "Annuler la demarche";

  // Duplicate demarche
  static String duplicateDemarchePageTitle = "Dupliquer la démarche";
  static String duplicateDemarche = "Dupliquer la démarche";

  // Thematique de demarche
  static String demarcheThematiqueTitle = "Thématiques";
  static String demarchesCategoriesPressedTip = "Découvrir la liste";
  static String demarchesCategoriesDescription =
      "Recherche parmi les thématiques d’emploi : candidatures, entretiens, création d’entreprise…";
  static String thematiquesDemarcheDescription = "Choisis une thématique parmi les thématiques suivantes :";
  static String thematiquesDemarcheDescriptionShort = Brand.isPassEmploi()
      ? "Choisissez une thématique"
      : "Choisis une thématique";
  static String dateShortMandatory = Brand.isPassEmploi()
      ? "Choisissez une date (obligatoire)"
      : "Choisis une date (obligatoire)";
  static String thematiquesDemarcheDateShort = Brand.isPassEmploi() ? "Choisissez une date" : "Choisis une date";
  static String thematiquesDemarchePressedTip = "Parcourir les démarches";
  static String thematiquesErrorTitle = "Il y a un problème de notre côté\u{00A0}!";
  static String thematiquesErrorSubtitle = Brand.isPassEmploi()
      ? "Nous sommes en train de régler le problème. Réessayez plus tard ou créez une démarche personnalisée."
      : "Nous sommes en train de régler le problème. Réessaie plus tard ou crée une démarche personnalisée.";
  static String otherDemarche = "Autre démarche";

  // IA FT
  static String iaFtStep2Title = Brand.isPassEmploi() ? "Décrivez vos démarches" : "Décris tes démarches";
  static String iaFtStep2Mandatory = "Obligatoire";
  static String iaFtStep2Warning = Brand.isPassEmploi()
      ? "Ne renseignez aucune donnée sensible"
      : "Ne renseigne aucune donnée sensible";
  static String iaFtStep2FieldHint = Brand.isPassEmploi()
      ? "Ajoutez des détails pour que votre conseiller puisse valider l'action."
      : "Ajoute des détails pour que ton conseiller puisse valider l'action.";
  static String iaFtStep2FieldPlaceholder = Brand.isPassEmploi()
      ? "Exemple : candidatures, entretiens, formations... L’IA va vous suggérer des démarches"
      : "Exemple : candidatures, entretiens, formations... L’IA va te suggérer des démarches";
  static String iaFtStep2ButtonDicter = "Dicter";
  static String iaFtStep2ButtonStop = "Arrêter";
  static String iaFtStep2Listening = "Dictée en cours";
  static String iaFtStep2Button = "Générer les démarches";

  // Dictée vocale (speech-to-text)
  static String dictationStart = "Dicter";
  static String dictationStop = "Arrêter";

  static String iaFtSuggestionsLoading = Brand.isPassEmploi()
      ? "Nous générons vos démarches, cela peut prendre quelques instants"
      : "Nous générons tes démarches, cela peut prendre quelques instants";
  static String iaFtSuggestionsLoadingWait = "Merci de patienter";
  static String iaFtSuggestionsFailure = "Oups, quelque chose s’est mal passé lors de la création des démarches.";
  static String iaFtSuggestionsEmpty = "Aucune démarche n’a pu être créée automatiquement.";
  static String iaFtSuggestionsContent(int count) =>
      count == 1 ? "$count démarche créée à valider" : "$count démarches créées à valider";
  static String iaFtSuggestionsSubmit = "Valider les démarches";
  static String iaFtSuggestionsError(int count) => count == 1
      ? "$count démarche n’a pas de date renseignée. Merci de la compléter pour valider"
      : "$count démarches n’ont pas de dates renseignées. Merci de les compléter pour valider";
  static String consulterMesDemarches = "Consulter mes démarches";
  static String iaFtShowcaseTitle = Brand.isPassEmploi()
      ? "Nouveau ! Créez vos démarches avec l'IA"
      : "Nouveau ! Crée tes démarches avec l'IA";

  static String topDemarchesTitle = "Tes démarches en 1 minute avec l'IA";
  static String topDemarchesHint = "Écris ou dicte tes démarches...";

  static String iaDemarchesAccueilTitle = "Tes démarches en 1 minute";
  static String iaDemarchesAccueilSubtitle = "L’IA détecte tes démarches et les organise en un clic";
  static String iaDemarchesAccueilHint = "Créer tes démarches avec l’IA";

  static String thematiquesDemarcheButton = "Accéder aux thématiques";
  static String iaFtEmptyError = Brand.isPassEmploi() ? "Décrivez vos démarches" : "Décris tes démarches";

  // Recherche
  static String derniereRecherche = "Recherches récentes";
  static String dernieresRecherches = "Recherches récentes";
  static String rechercheDerniereOffreConsultee = "Dernière offre consultée";
  static String rechercheHomeOffresEmploiTitle = "Emploi";
  static String rechercheHomeOffresEmploiSubtitle = "CDD, CDI, saisonnier";
  static String rechercheHomeOffresAlternanceTitle = "Alternance";
  static String rechercheHomeOffresAlternanceSubtitle = "Apprentissage & contrat pro";
  static String rechercheHomeOffresImmersionTitle = "Immersion";
  static String rechercheHomeOffresImmersionSubtitle = "Découvrir un métier";
  static String rechercheHomeOffresServiceCiviqueTitle = "Service civique";
  static String rechercheHomeOffresServiceCiviqueSubtitle = "Missions d’engagement";
  static String rechercheHomeCriteresTitle = Brand.isPassEmploi() ? "Votre recherche" : "Ta recherche";
  static String rechercheHomeExplorerParType = "Explorer par type";
  static String rechercheHomeCriteresMetierVide = "Aucun métier renseigné";
  static String rechercheHomeCriteresLieuVide = "Aucun lieu renseigné";
  static String rechercheHomeCriteresA11y(String? metier, String? lieu) => [
    rechercheHomeCriteresTitle,
    metier ?? rechercheHomeCriteresMetierVide,
    if (lieu != null) "à $lieu" else rechercheHomeCriteresLieuVide,
  ].join(" ");
  static String rechercheHomeEmploiEmoji = "💼";
  static String rechercheHomeAlternanceEmoji = "🔁";
  static String rechercheHomeImmersionEmoji = "👀";
  static String rechercheHomeServiceCiviqueEmoji = "🤝";
  static String rechercheOffresEmploiTitle = "Offres d’emploi";
  static String rechercheOffresAlternanceTitle = "Offres d’alternance";
  static String rechercheOffresImmersionTitle = "Offres d’immersion";
  static String rechercheOffresServiceCiviqueTitle = "Offres de service civique";
  static String rechercheAfficherPlus = "Afficher plus d'offres";
  static String recherchePlaceholderTitle = Brand.isPassEmploi()
      ? "Effectuez votre recherche pour afficher des résultats"
      : "Effectue ta recherche pour afficher des résultats";
  static String rechercheLancerUneRechercheHint = Brand.isPassEmploi()
      ? "Lancez une recherche pour afficher les offres vous correspondant"
      : "Lance une recherche pour afficher les offres te correspondant";
  static String rechercheEditButton = "Modifier ma recherche";
  static String filtrerLesResultats = "Filtrer les résultats";
  static String modifierMesCriteres = "Modifier mes critères";
  static String rechercheEmptyTitleEmploi = "Aucune offre d'emploi trouvée";
  static String rechercheEmptyTitleAlternance = "Aucune offre d'alternance trouvée";
  static String rechercheEmptyTitleImmersion = "Aucune offre d'immersion trouvée";
  static String rechercheEmptyTitleServiceCivique = "Aucune offre de service civique trouvée";
  static String rechercheEmptyTitleEvenementEmploi = "Aucun événement trouvé";

  static String rechercheResultsOffresCount(int count) => count <= 1 ? "$count offre" : "$count offres";

  static String rechercheResultsEvenementsCount(int count) => count <= 1 ? "$count événement" : "$count événements";

  static String rechercheEmptySubtitle({String? metier, String? lieu}) {
    final elargir = Brand.isPassEmploi() ? "Essayez d'élargir votre recherche." : "Essaie d'élargir ta recherche.";
    if (metier != null && metier.isNotEmpty && lieu != null && lieu.isNotEmpty) {
      return "Pas d'offres disponibles en $metier à $lieu pour le moment. $elargir";
    }
    if (metier != null && metier.isNotEmpty) {
      return "Pas d'offres disponibles en $metier pour le moment. $elargir";
    }
    if (lieu != null && lieu.isNotEmpty) {
      return "Pas d'offres disponibles à $lieu pour le moment. $elargir";
    }
    return "Pas d'offres disponibles pour le moment. $elargir";
  }

  static String rechercheRecentesTitle = "Recherches récentes";

  static String rechercheCriteresActifsZero = "0 critère actif";
  static String rechercheCriteresActifsOne = "(1) critère actif";

  static String rechercheCriteresActifsTooltip(bool isOpen) => "Formulaire de recherche ${isOpen ? 'ouvert' : 'fermé'}";

  static String rechercheCriteresActifsPlural(int count) => "($count) critères actifs";

  // Solutions
  static String offreNotFoundTitle = "Offre expirée";
  static String offreNotFoundBodyTitle = "Cette offre n'est plus disponible";
  static String offreNotFoundBodySubtitle = Brand.isPassEmploi()
      ? "Consultez les dernières offres ou demandez de l'aide à votre conseiller"
      : "Consulte les dernières offres ou demande de l'aide à ton conseiller";
  static String keywordTitle = "Mot clé";
  static String metierLabel = "Métier";
  static String locationTitle = "Lieu";
  static String locationHint = "Ville ou département";
  static String locationHintServiceCivique = "Ville";
  static String locationMandatoryTitle = "*Lieu";
  static String searchButton = "Rechercher";
  static String offreDetails = "Détails de l'offre";
  static String metierHint = "Mot clé, secteur, compétences....";
  static String rechercheTabTitle = "Recherche";
  static String offresEnregistreesTabTitle = "Suivi des offres";
  static String alertesTabTitle = "Alertes";
  static String solutionsAppBarTitle = "Offres";
  static String partagerOffreConseiller = "Partager l’offre à mon conseiller";
  static String partageOffreNavTitle = "Partage de l’offre d’emploi";
  static String souhaitDePartagerOffre = Brand.isPassEmploi()
      ? "L’offre que vous souhaitez partager"
      : "L’offre que tu souhaites partager";
  static String partageOffreDefaultMessage = "Bonjour, je vous partage une offre d’emploi afin d’avoir votre avis";
  static String partageOffreSuccessTitle = "Partage offre d’emploi";
  static String partageOffreSuccessContent = Brand.isPassEmploi()
      ? "L’offre d’emploi a été partagée à votre conseiller sur la messagerie de l’application"
      : "L’offre d’emploi a été partagée à ton conseiller sur la messagerie de l’application";
  static String messagePourConseiller = Brand.isPassEmploi()
      ? "Message destiné à votre conseiller"
      : "Message destiné à ton conseiller";
  static String infoOffrePartageChat = Brand.isPassEmploi()
      ? "L’offre d’emploi sera partagée à votre conseiller dans la messagerie"
      : "L’offre d’emploi sera partagée à ton conseiller dans la messagerie";
  static String partagerOffreEmploi = "Partager l’offre d’emploi";
  static String a11YLocationSuppressionLabel = "Supprimer la localisation";
  static String a11YKeywordSuppressionLabel = "Supprimer le mot clé";
  static String a11YMetierSuppressionLabel = "Supprimer le métier";
  static String a11YLocationWithDepartmentsExplanationLabel = Brand.isPassEmploi()
      ? "Commencez à saisir un nom de ville ou de département. Une liste de choix s'affiche directement sous le champ et se met à jour au fur et à mesure. Puis sélectionnez une ville ou un département dans lequel vous cherchez un emploi"
      : "Commence à saisir un nom de ville ou de département. Une liste de choix s'affiche directement sous le champ et se met à jour au fur et à mesure. Puis sélectionne une ville ou un département dans lequel tu cherches un emploi";
  static String a11YLocationWithoutDepartmentExplanationLabel = Brand.isPassEmploi()
      ? "Commencez à saisir un nom de ville. Une liste de choix s'affiche directement sous le champ et se met à jour au fur et à mesure. Puis sélectionnez une ville dans laquelle vous cherchez un emploi"
      : "Commence à saisir un nom de ville. Une liste de choix s'affiche directement sous le champ et se met à jour au fur et à mesure. Puis sélectionne une ville dans laquelle tu cherches un emploi";
  static String a11YKeywordExplanationLabel = Brand.isPassEmploi()
      ? "Saisissez un mot clé correspondant à votre recherche d'emploi. Puis validez votre choix."
      : "Saisis un mot clé correspondant à ta recherche d'emploi. Puis valide ton choix.";
  static String a11YMetiersExplanationLabel = Brand.isPassEmploi()
      ? "Commencez à saisir un métier. Une liste de choix s'affiche directement sous le champ et se met à jour au fur et à mesure. Puis sélectionnez un métier dans lequel vous cherchez une immersion"
      : "Commence à saisir un métier. Une liste de choix s'affiche directement sous le champ et se met à jour au fur et à mesure. Puis sélectionne un métier dans lequel tu cherches une immersion";

  static String a11yPartagerOffreLabel = "Partager l’offre";
  static String a11yPartagerEvenementLabel = "Partager l’événement";

  // Alternance
  static String partagerOffreAlternance = "Partager l’offre d’alternance";
  static String partageOffreAlternanceNavTitle = "Partage de l’offre d’alternance";

  // Event partage
  static String infoEventPartageChat = "L’événement sera partagé à ton conseiller dans la messagerie";
  static String souhaitDePartagerEvent = "Ce que tu souhaites partager";
  static String partageEventDefaultMessage = "Bonjour, je vous partage un événement afin d’avoir votre avis";
  static String partagerAuConseiller = "Partager à mon conseiller";
  static String partageEventNavTitle = "Partage d’événement";
  static String partageEventSuccess = "L’événement a été partagé à ton conseiller sur la messagerie de l’application";

  // Evenement partage
  static String partageEvenementEmploiNavTitle = "Partage de l’événement";
  static String souhaitDePartagerEvenementEmploi = Brand.isPassEmploi()
      ? "L’événement que vous souhaitez partager"
      : "L’événement que tu souhaites partager";
  static String partageEvenementEmploiDefaultMessage = "Bonjour, je vous partage un événement afin d’avoir votre avis";
  static String partageEvenementEmploiSuccess = Brand.isPassEmploi()
      ? "L’événement a été partagé à votre conseiller sur la messagerie de l’application"
      : "L’événement a été partagé à ton conseiller sur la messagerie de l’application";
  static String infoEvenementEmploiPartageChat = Brand.isPassEmploi()
      ? "L’événement sera partagé à votre conseiller dans la messagerie"
      : "L’événement sera partagé à ton conseiller dans la messagerie";
  static String partagerEvenementEmploiAuConseiller = "Partager l’événement";

  // Session milo partage
  static String partageSessionMiloNavTitle = "Partage d’événement";
  static String souhaitDePartagerSessionMilo = "Ce que tu souhaites partager";
  static String partageSessionMiloDefaultMessage = "Bonjour, pouvez-vous m'inscrire à cet événement ?";
  static String partageSessionMiloCompletMessage = "Bonjour, cet événement est complet mais je suis intéressé";
  static String partageSessionMiloSuccess =
      "L’événement a été partagé à ton conseiller sur la messagerie de l’application";
  static String infoSessionMiloPartageChat = "L’événement sera partagé à ton conseiller dans la messagerie";
  static String partagerSessionMiloAuConseiller = "Partager à mon conseiller";

  // Immersion
  static String lentreprise = 'L\'entreprise';
  static String disabledWorkersWelcome = 'Personnes en situation de handicap bienvenues';
  static String modeDistancielFullRemote = 'Télétravail';
  static String modeDistancielHybrid = 'Présentiel et à distance';
  static String modeDistancielOnSite = 'Présentiel';
  static String immersionExpansionTileTitle = "En savoir plus sur l’immersion";
  static String immersionAccueillanteExplanation =
      "Cette entreprise recherche activement des candidats à l’immersion. Contacte-la en expliquant ton projet professionnel et tes motivations.";
  static String immersionDescriptionLabel = Brand.isPassEmploi()
      ? "Si l’entreprise est d’accord pour vous accueillir :\n\n"
            "· Prévenez votre conseiller\n"
            "· Remplissez une convention d’immersion avec lui"
      : "Si l’entreprise est d’accord pour t'accueillir :\n\n"
            "· Préviens ton conseiller\n"
            "· Remplis une convention d’immersion avec lui";
  static String immersionContactBlocTitle = "Contact";
  static String immersionLocationButton = "Localiser l'entreprise";
  static String immersionEmailButton = "Envoyer un e-mail";
  static String immersionEmailSubject = "Candidature pour une période d'immersion";
  static String immersionContactSucceedMail = Brand.isPassEmploi()
      ? "L’entreprise a bien reçu votre demande. Laissez-lui un peu de temps pour vous répondre. En cas de réponse positive, vous recevrez un e-mail avec la suite des démarches. Pensez à vérifier vos spams."
      : "L’entreprise a bien reçu ta demande. Laisse-lui un peu de temps pour te répondre. En cas de réponse positive, tu recevras un e-mail avec la suite des démarches. Pense à vérifier tes spams.";
  static String immersionContactSucceedPhone = Brand.isPassEmploi()
      ? "Merci pour votre intérêt. Cette entreprise souhaite être contactée par téléphone. Ses coordonnées vous ont été envoyées par email."
      : "Merci pour ton intérêt. Cette entreprise souhaite être contactée par téléphone. Ses coordonnées t'ont été envoyées par email.";
  static String immersionContactSucceedInPerson = Brand.isPassEmploi()
      ? "Merci pour votre intérêt. Cette entreprise souhaite que vous vous rendiez sur place. Ses coordonnées vous ont été envoyées par email."
      : "Merci pour ton intérêt. Cette entreprise souhaite que tu te rendes sur place. Ses coordonnées t'ont été envoyées par email.";
  static String contactImmersionAlreadyDone = Brand.isPassEmploi()
      ? "Vous avez déjà postulé à cette offre d'immersion, il faut un minimum de 7 jours pour pouvoir postuler à nouveau"
      : "Tu as déjà postulé à cette offre d'immersion, il faut un minimum de 7 jours pour pouvoir postuler à nouveau";
  static String immersitionContactFormTitle = "Contacter l’entreprise";
  static String immersitionContactFormSubtitle =
      "Cette entreprise a choisi d’être contactée par mail. Merci de compléter ce formulaire qui sera transmis à l’entreprise.";
  static String immersitionContactFormHint = "Tous les champs avec * sont obligatoires";
  static String immersitionContactFormEmailHint = "Email";
  static String immersitionContactFormSurnameHint = "Prénom";
  static String immersitionContactFormNameHint = "Nom";
  static String immersitionContactFormPhoneHint = "Téléphone";
  static String immersitionContactFormStartDateHint = "Date de début d’immersion souhaitée";
  static String immersitionContactFormExperienceLabel = "Expérience";
  static String immersitionContactFormExperiencePlaceholder = Brand.isPassEmploi()
      ? "Détaillez en quelques lignes vos expériences et compétences"
      : "Détaille en quelques lignes tes expériences et compétences";
  static String immersitionContactFormLinkedinLabel = "Page LinkedIn ou CV en ligne";
  static String immersitionContactFormOptionalSuffix = "(optionnel)";
  static String immersionContactFormButton = "Envoyer";
  static String immersionContactFormEmailEmpty = "Renseigne ton adresse email";
  static String immersionContactFormEmailInvalid =
      "Merci de renseigner une adresse email valide au format exemple@email.com";
  static String immersionContactFormPhoneEmpty = "Renseigne ton numéro de téléphone";
  static String immersionContactFormPhoneInvalid = "Merci de renseigner un numéro de téléphone valide";
  static String immersionContactFormLinkedinInvalid = Brand.isPassEmploi()
      ? "Veuillez renseigner une URL valide (ex: https://linkedin.com/in/votre-profil)"
      : "Merci de renseigner une URL valide (ex: https://linkedin.com/in/ton-profil)";
  static String contactByMail = "Mise en relation par mail";
  static String contactByPhone = "Mise en relation par téléphone";
  static String contactByPresen = "Rendez-vous sur place";
  static String adresse = "Adresse";
  static String informationComplementaire = "Informations complémentaires";
  static String siteWeb = "Site web";
  static String contactWarning = Brand.isPassEmploi()
      ? "Veuillez utiliser les coordonnées de l'entreprise uniquement pour votre usage personnel"
      : "Merci d'utiliser les coordonnées de l'entreprise uniquement pour ton usage personnel";
  static String immersionContactTitle = "Entreprise contactée";
  static String desQuePossible = "Dès que possible";

  // Service Civique
  static String serviceCiviqueFiltresTitle = "Filtrer les missions";
  static String startDateFiltreTitle = "Date de début";
  static String startDate = "Dès le";

  static String startDateEnabled(bool enabled) => enabled
      ? "Désactiver l'affichage des offres à partir d'une date"
      : "Activer l'affichage des offres à partir d'une date";
  static String domainFiltreTitle = "Domaine";
  static String asSoonAs = "Dès le ";
  static String serviceCiviqueDetailTitle = "Détails de l’offre de service civique";
  static String serviceCiviqueMissionTitle = "Mission";
  static String serviceCiviqueOrganisationTitle = "Organisation";

  // Solutions Errors
  static String noContentErrorTitle = "Pour le moment, aucune offre ne correspond à tes critères.";
  static String noContentErrorSubtitle = "Essaie d’élargir ta recherche en modifiant tes critères ou crée une alerte.";
  static String genericError = Brand.isPassEmploi()
      ? "Une erreur est survenue. Veuillez réessayer"
      : "Une erreur est survenue. Réessaie";
  static String genericCreationError = Brand.isPassEmploi()
      ? "Erreur lors de la création. Veuillez réessayer"
      : "Erreur lors de la création. Réessaie";

  // Offre emploi filtres
  static String filtrer = "Filtrer";
  static String offresEmploiFiltresTitle = "Filtrer les annonces";
  static String searchRadius = "Dans un rayon de recherche";
  static String searchRadiusDescription(int km) => "de $km km";
  static String searchRadiusValue(int km) => "$km";
  static String searchRadiusA11yValue(int km) => "$km kilomètres";
  static String searchRadiusA11yHint(int min, int max) => "Minimum $min kilomètres, maximum $max kilomètres";
  static String applyFiltres = "Appliquer les filtres";
  static String resetFiltres = "Réinitialiser";

  static String kmFormat(int int) => "$int km";
  static String experienceSectionTitle = "Expérience";
  static String experienceSectionDescription = "Débutant accepté";

  static String experienceSectionEnabled(bool enabled) => enabled
      ? "Désactiver l'affichage des offres débutants acceptés uniquement"
      : "Activer l'affichage des offres débutants acceptés uniquement";
  static String contratSectionTitle = "Type de contrat";
  static String contratCdiLabel = "CDI";
  static String contratCdiTooltip = "CDI et CDI Intérimaire";
  static String contratCddInterimSaisonnierLabel = "CDD - intérim - saisonnier";
  static String contratAutreLabel = "Autres";
  static String contratAutreTooltip =
      "Profession commerciale, Franchise, Profession libérale, Reprise d’entreprise, Contrat travail temporaire insertion";
  static String dureeSectionTitle = "Temps de travail";
  static String dureeTempsPleinLabel = "Temps plein";
  static String dureeTempsPartielLabel = "Temps partiel";

  // Offre emploi details
  static String offreDetailsError = "Erreur lors de la récupération de l'offre";
  static String offreDetailsTitle = "Détail de l'offre";

  static String offreLastSeen(DateTime date) => "Vue ${date.timeAgo()}";
  static String offrePostulatedSeen(DateTime date) => "Postulé ${date.timeAgo()}";

  static String profileTitle = "Profil souhaité";
  static String experienceTitle = "Expérience";
  static String companyDescriptionTitle = "Détail de l'entreprise";
  static String companyAdaptedTitle = "Entreprise adaptée";
  static String companyAccessibilityTitle = "Entreprise handi-bienveillante";
  static String companyTitle = "Entreprise";
  static String skillsTitle = "Savoirs et savoir-faire";
  static String softSkillsTitle = "Savoir-être professionnels";
  static String languageTitle = "Langue";
  static String educationTitle = "Formation";
  static String driverLicenceTitle = "Permis";
  static String subscribeButtonTitle = "Recevoir l'offre par mail";
  static String postulerButtonTitle = "Je postule";
  static String requiredIcon = "Obligatoire";
  static String offreNotFoundError = "Cette offre n’existe plus ou est momentanément suspendue";
  static String offreNotFoundExplaination = Brand.isPassEmploi()
      ? "Vous pouvez décider de la supprimer ou bien de la conserver dans vos offres suivies."
      : "Tu peux décider de la supprimer ou bien de la conserver dans tes offres suivies.";
  static String deleteOffreFromFavori = "Supprimer des offres suivies";
  static String interim = "Intérim";

  static String origin(String label) => "Source : $label";

  // Favoris
  static String mesFavorisPageTitle = "Mon suivis des offres";
  static String miscellaneousErrorRetry = Brand.isPassEmploi()
      ? "Une erreur est survenue. Veuillez réessayer"
      : "Une erreur est survenue. Réessaie";
  static String favoriUpdateError = Brand.isPassEmploi()
      ? "La mise à jour de l’offre suivie a échoué. Veuillez réessayer."
      : "La mise à jour de l’offre suivie a échoué. Réessaie.";

  static String offreNumberAndLastUpdate(String offreId, String lastUpdate) =>
      "Offre n°$offreId, actualisée $lastUpdate";
  static String offreDetailNumber(String offreId) => "Offre n°$offreId";
  static String offreDetailLastUpdate(String lastUpdate) => "Actualisée $lastUpdate";

  static String offresEnregistreesEmptyTitle = Brand.isPassEmploi()
      ? "Suivez vos offres d’emploi ici"
      : "Suis tes offres d’emploi ici";

  static String offresEnregistreesEmptySubtitle = Brand.isPassEmploi()
      ? "Retrouvez ici les offres qui vous intéressent et celles où vous avez postulé."
      : "Retrouve ici les offres qui t'intéressent et celles où tu as postulé.";
  static String offresEnregistreesEmptyButton = "Lancer une recherche";
  static String suiviPostuleesCount(int count) => count <= 1 ? "$count postulée" : "$count postulées";
  static String suiviFavorisCount(int count) => count <= 1 ? "$count favori" : "$count favoris";
  static String suiviFavorisEmptyHint = Brand.isPassEmploi()
      ? "Sauvegardez une offre depuis les résultats pour la retrouver ici."
      : "Sauvegarde une offre depuis les résultats pour la retrouver ici.";
  static String candidatureEnvoyee = "Candidature envoyée";
  static String offreTypeEmploiLabel = "Emploi";
  static String offresEnregistreesError = Brand.isPassEmploi()
      ? "Erreur lors de la récupération de vos offres suivies"
      : "Erreur lors de la récupération de tes offres suivies";
  static String favorisUnknownContractType = 'Type de contrat inconnu';
  static String favorisUnknownSecteur = 'Secteur d\'activité inconnu';

  // Offre Filter Page
  static String filterList = "Filtrer la liste";
  static String filterByType = "Filtrer par type";
  static String filterAll = "Tous";
  static String filterEmploi = "Emploi";
  static String filterImmersion = "Immersion";
  static String filterAlternance = "Alternance";
  static String filterServiceCivique = "Service civique";

  static String poleEmploiUrlButton = "Accéder à mon espace France Travail";
  static String espacePoleEmploiUrl = "https://candidat.pole-emploi.fr/espacepersonnel/";

  static String emptyContentTitle(String content) => "Tu n’as pas encore de $content";

  static String emptyContentSubtitle(String content) => "Commence en créant une nouvelle $content\u{00A0}!";

  static String emptyContentDescription(String content) =>
      "Tu peux créer tes $content en autonomie depuis ton espace France Travail.";

  // Profil
  static String personalInformation = "Informations personnelles";
  static String profilButtonSemanticsLabel = "Voir mon Profil";
  static String myAccountLabel = "Mon compte";
  static String modifyMyInformation = "Modifier mes informations";
  static String emailAddressAccountLabel = "Adresse mail du compte";
  static String conseillerTileSubtitle(String date) =>
      Brand.isPassEmploi() ? "Votre conseiller depuis le $date" : "Ton conseiller depuis le $date";
  static String cvTileSubtitle = Brand.isPassEmploi()
      ? "Télécharger vos CV France Travail"
      : "Télécharger tes CV France Travail";
  static String privacyAndDataLabel = "Confidentialités et données";
  static String privacyAndDataSubtitle = "RGAA, RGPD, données stockées";

  static String sinceDate(String date) => "Depuis le $date";
  static String emailAddressLabel = "Adresse e-mail";
  static String missingEmailAddressValue = "Non renseignée";
  static String legalInformation = "Informations légales";
  static String legalNoticeLabel = "Mentions légales";
  static String privacyPolicyLabel = "Politique de confidentialité";
  static String accessibilityLevelLabel = "Niveau d’accessibilité";
  static String accessibilityLevelNonConforme = "Non conforme";
  static String termsOfServiceLabel = "Conditions Générales d'Utilisation";
  static String termsOfUseLabel = "Conditions d’utilisations";

  static String legalNoticeUrl = Brand.isCej() ? _CejStrings.legalNoticeUrl : _PassEmploiStrings.legalNoticeUrl;
  static String privacyPolicyUrl = Brand.isCej() ? _CejStrings.privacyPolicyUrl : _PassEmploiStrings.privacyPolicyUrl;
  static String termsOfServiceUrl = Brand.isCej()
      ? _CejStrings.termsOfServiceUrl
      : _PassEmploiStrings.termsOfServiceUrl;
  static String accessibilityUrl = Brand.isCej() ? _CejStrings.accessibilityUrl : _PassEmploiStrings.accessibilityUrl;

  // Profil: Settings & account suppression
  static String betaTag = "Bêta";
  static String settingsLabel = "Paramètres";
  static String themeLabel = "Apparence";
  static String themeModeLight = "Thème clair";
  static String themeModeDark = "Thème sombre";
  static String themeModeSystem = "Thème Système";
  static String themeModeSystemDescription = "Utilise les paramètres système.";
  static String suppressionPageTitle = "Supprimer mon compte";
  static String suppressionAccountLabel = Brand.isCej()
      ? _CejStrings.suppressionAccountLabel
      : _PassEmploiStrings.suppressionAccountLabel;
  static String activityShareLabel = Brand.isPassEmploi() ? "Partager votre activité" : "Partager ton activité";
  static String activitySharePageTitle = Brand.isPassEmploi() ? "Partage de votre activité" : "Partage de ton activité";
  static String notificationsLabel = "Gérer les notifications";

  static String partageFavorisEnabled(bool enabled) =>
      enabled ? "Désactiver le partage de mes offres suivies" : "Activer le partage de mes offres suivies";
  static String activityShareDescription = Brand.isPassEmploi()
      ? "Autorisez le partage pour permettre au conseiller d’avoir un suivi de votre activité."
      : "Autorise le partage pour permettre au conseiller d’avoir un suivi de ton activité.";
  static String warning = "Attention";
  static String suppressionButtonLabel = "Supprimer mon compte";
  static String warningInformationParagraph1 = Brand.isCej()
      ? _CejStrings.warningInformationParagraph1
      : _PassEmploiStrings.warningInformationParagraph1;
  static String warningInformationParagraph2 = Brand.isCej()
      ? _CejStrings.warningInformationParagraph2
      : _PassEmploiStrings.warningInformationParagraph2;
  static String warningInformationPoleEmploi = Brand.isPassEmploi()
      ? "Vos démarches et rendez-vous seront toujours disponibles dans votre portail France Travail."
      : "Tes démarches et rendez-vous seront toujours disponibles dans ton portail France Travail.";
  static List<String> warningPointsMilo = [
    "tes actions",
    "tes messages avec ton conseiller",
    "tes rendez-vous",
    "tes recherches et offres sauvegardées",
  ];

  static List<String> warningPointsPoleEmploi = Brand.isPassEmploi()
      ? [
          "vos messages avec votre conseiller",
          "vos recherches et offres sauvegardées",
        ]
      : [
          "tes messages avec ton conseiller",
          "tes recherches et offres sauvegardées",
        ];
  static String lastWarningBeforeSuppression = Brand.isPassEmploi()
      ? "Tapez “supprimer” pour confirmer la suppression de votre compte."
      : "Tape “supprimer” pour confirmer la suppression de ton compte.";
  static String mandatorySuppressionLabelError = Brand.isPassEmploi()
      ? "Champ invalide. Vérifiez que vous avez bien tapé “supprimer”"
      : "Champs invalide. Vérifie que tu as bien tapé “supprimer”";
  static String accountDeletionSuccess = Brand.isCej()
      ? _CejStrings.accountDeletionSuccess
      : _PassEmploiStrings.accountDeletionSuccess;

  static String shareFavoriteLabel = "Partager mes offres suivies";

  static String helpTitle = "Besoin d’aide ?";
  static String ratingAppLabel = "Donner mon avis";
  static String ratingAppSubtitle = Brand.isPassEmploi()
      ? "Votre retour fait évoluer l’appli"
      : "Ton retour fait évoluer l’appli";
  static String contactTeamLabel = "Contacter l’équipe";
  static String contactTeamSubtitle = "Une question, un souci ?";

  // Notifications settings
  static const String notificationsSettingsSubtitle = "Recevoir des notifications pour les événements suivants :";
  static const String notificationsToggleEnabled = "Activé";
  static const String notificationsToggleDisabled = "Désactivé";

  static const String notificationsSettingsAlertesTitle = "Alertes";
  static String notificationsSettingsAlertesSubtitle = Brand.isPassEmploi()
      ? "De nouvelles offres correspondant à vos alertes enregistrées"
      : "De nouvelles offres correspondant à tes alertes enregistrées";

  static const String notificationsSettingsMonSuiviTitle = "Mon suivi";

  static String notificationsSettingsMonSuiviSubtitle(bool isMilo) =>
      isMilo ? notificationsSettingsMonSuiviSubtitleMilo : notificationsSettingsMonSuiviSubtitleFT;

  static const String notificationsSettingsMonSuiviSubtitleMilo = "Création d’une action par ton conseiller";
  static String notificationsSettingsMonSuiviSubtitleFT = Brand.isPassEmploi()
      ? "Création d’une démarche par votre conseiller"
      : "Création d’une démarche par ton conseiller";

  static String notificationsSettingsRendezVoussTitle(bool isMilo) =>
      isMilo ? notificationsSettingsRendezVoussTitleMilo : notificationsSettingsRendezVoussTitleFT;

  static const String notificationsSettingsRendezVoussTitleMilo = "Rendez-vous et sessions";
  static const String notificationsSettingsRendezVoussTitleFT = "Rendez-vous";
  static String notificationsSettingsRendezVousSubtitle = Brand.isPassEmploi()
      ? "Inscription, modification ou suppression par votre conseiller"
      : "Inscription, modification ou suppression par ton conseiller";

  static const String notificationsSettingsRappelsTitle = "Rappels";

  static String notificationsSettingsRappelsSubtitle(bool isMilo) =>
      isMilo ? notificationsSettingsRappelsSubtitleMilo : notificationsSettingsRappelsSubtitleFT;
  static const String notificationsSettingsRappelsSubtitleMilo =
      "Rappel de complétion des actions (1 fois par semaine)";
  static const String notificationsSettingsRappelsSubtitleFT =
      "Rappel de complétion des démarches (1 fois par semaine)";

  static const String notificationsSettingsActuMiloTitle = "Ma mission locale";
  static const String notificationsSettingsActuMiloSubtitle =
      "Publication d’une nouvelle actualité dans ta Mission Locale";

  static const String notificationsSettingsTitle = "Paramètres système";
  static const String openNotificationsSettings = "Ouvrir les paramètres de notifications";
  static const String notificationsA11yEnable = "Activer les notifications pour ";
  static const String notificationsA11yDisable = "Désactiver les notifications pour ";

  // contact page
  static String contactConseilsDepartementaux = "Conseil départemental";
  static String contactPageTitle = "Contacter l’équipe";
  static String contactPageBody1 = Brand.isCej()
      ? "L’équipe technique de l’application CEJ est en charge du développement de l’application."
      : "L’équipe technique de l’application pass emploi est en charge du développement de l’application.";
  static String contactPageBody2 = Brand.isPassEmploi() ? "Contactez-nous pour :" : "Contacte-nous pour :";
  static String contactPageBody3 = Brand.isCej()
      ? "Pour toutes les informations et les problèmes liés au Contrat d’Engagement Jeune, contacte ton conseiller."
      : "Pour toutes les informations et les problèmes liés à votre dispositif d'accompagnement, veuillez contacter votre conseiller.";
  static String contactPageBodyBullet1 = "Un problème sur l’application";
  static String contactPageBodyBullet2 = "Une suggestion d’évolution";
  static String contactPageBodyBullet3 = "Toute autre remarque";
  static String contactPageButton = "Contacter l'équipe";

  static String objetPriseDeContact(Brand brand) => brand.isCej
      ? "Prise de contact avec l’équipe de l’application du CEJ"
      : "Prise de contact avec l’équipe de l’application pass emploi";
  static String corpsPriseDeContact = Brand.isPassEmploi()
      ? "Décrivez-nous votre problème ou vos suggestions d’évolution : "
      : "Décris-nous ton problème ou tes suggestions d’évolution : ";

  // alertes
  static String alerte = "Alerte";
  static String createAlert = "Créer une alerte";
  static String createAlertSuccessTitle = "Recherche enregistrée";
  static String createAlerteTitle = "Créer une alerte pour la recherche";
  static String alerteTitle = "Nom de la recherche";
  static String mandatoryAlerteTitleError = Brand.isPassEmploi()
      ? "Renseignez un nom pour votre recherche"
      : "Renseigne un nom pour ta recherche";
  static String alerteFilters = "Critères de la recherche";
  static String alerteInfo = "Les filtres appliqués seront aussi enregistrés.";
  static String searchNotificationInfo = Brand.isPassEmploi()
      ? "Vous recevrez des notifications pour être alerté des nouvelles offres liées aux critères de votre recherche."
      : "Tu recevras des notifications pour être alerté des nouvelles offres liées aux critères de ta recherche.";

  static String alerteTitleField(metier, localisation) => "$metier - $localisation";
  static String alerteSuccessfullyCreated = Brand.isPassEmploi()
      ? "Votre recherche a bien été enregistrée. Retrouvez-la dans la section Mes Alertes sur votre page d'accueil."
      : "Ta recherche a bien été enregistrée. Retrouve-la dans la section Mes Alertes sur ta page d'accueil.";
  static String creationAlerteError = Brand.isPassEmploi()
      ? "Erreur lors de la création de l'alerte. Veuillez réessayer"
      : "Erreur lors de la création de l'alerte. Réessaie";
  static String alerteGetError = "Erreur lors de la récupération des recherches sauvegardées.";
  static String alerteTabName = "Mes alertes";
  static String alertesListEmptyTitle = Brand.isPassEmploi()
      ? "Vous n’avez pas encore d’alerte sauvegardée"
      : "Tu n’as pas encore d’alerte sauvegardée";
  static String alertesListEmptySubtitle = Brand.isPassEmploi()
      ? "Créez des alertes lors de vos recherches et recevez les offres qui vous correspondent"
      : "Crée des alertes lors de tes recherches et reçois les offres qui te correspondent";
  static String alertesListEmptyButton = "Rechercher une offre";
  static String favorisTabName = "Mes offres";
  static String alerteSeeResults = "Voir les résultats";

  static String alerteDeleteMessageTitle = Brand.isPassEmploi()
      ? "Souhaitez-vous supprimer l’alerte ?"
      : "Souhaites-tu supprimer l’alerte ?";
  static String alertesCountTitle(int count) => count <= 1 ? "$count alerte" : "$count alertes";
  static String alertesCreationHint =
      "💡 Les alertes se créent depuis les résultats d’offres d’emploi ou d’alternance.";
  static String supprimerLesAlertesConfirmTitle = "Supprimer toutes les alertes ?";
  static String supprimerLesAlertesConfirmSubtitle = "Cette action supprimera définitivement les alertes affichées.";

  static String alerteDeleteMessageSubtitle = Brand.isPassEmploi()
      ? "Vous n’aurez plus accès à la page de résultats ni aux notifications."
      : "Tu n’auras plus accès à la page de résultats ni aux notifications.";
  static String alerteDeleteError = "Erreur lors de la suppression de la recherche.";

  static String alerteDeleteSuccessTitle = Brand.isPassEmploi()
      ? "Votre alerte a été supprimée avec succès."
      : "Ton alerte a été supprimée avec succès.";
  static String alerteDeleteSuccessContent = Brand.isPassEmploi()
      ? "Votre alerte a été supprimée avec succès."
      : "Ton alerte a été supprimée avec succès.";

  // Mode démo
  static String passerEnDemo = "Passer en mode démo";
  static String modeDemoAppBarLabel = "Version démo conseiller";
  static String modeDemoExplicationTitre = "Espace démo conseiller";
  static String modeDemoExplicationPremierPoint1 = Brand.isPassEmploi()
      ? "→ Cette version vous "
      : "→ Cette version te ";
  static String modeDemoExplicationPremierPoint2 = "permet d’explorer";
  static String modeDemoExplicationPremierPoint3 = Brand.isCej()
      ? _CejStrings.modeDemoExplicationPremierPoint3
      : _PassEmploiStrings.modeDemoExplicationPremierPoint3;
  static String modeDemoExplicationSecondPoint1 = "→ Les données présentées ";
  static String modeDemoExplicationSecondPoint2 = "sont factices.";
  static String modeDemoExplicationTroisiemePoint1 = Brand.isPassEmploi()
      ? "→ Vous pourrez naviguer dans l'application, rédiger des messages (sans les envoyer) et effectuer des recherches. Les résultats alors affichés sont "
      : "→ Tu pourras naviguer dans l'application, rédiger des messages (sans les envoyer) et effectuer des recherches. Les résultats alors affichés sont ";
  static String modeDemoExplicationTroisiemePoint2 =
      "donnés à titre d’exemples et ne correspondent pas aux recherches effectuées.";
  static String modeDemoExplicationChoix = "Accéder au mode démo";

  // Campagne
  static String campagneTitle(int page, int count) =>
      Brand.isPassEmploi() ? "Votre expérience $page/$count" : "Ton expérience $page/$count";

  // Developer options
  static String developerOptions = 'Options développeurs';
  static String developerOptionMatomo = 'Données envoyées à Matomo';
  static String developerOptionFCM = 'Copier le token FCM';
  static String developerOptionFCMDelete = 'Supprimer le token FCM';
  static String developerOptionDeleteAllPrefs = 'Supprimer les données locales';
  static String developerOptionMatomoPage = 'Matomo';

  // Tutorial
  static String seeLater = "Voir plus tard";
  static String finish = "Terminer";

  //Appstore rating
  static String ratingLabel = Brand.isPassEmploi()
      ? 'Êtes-vous satisfait de l’application\u{00A0}?'
      : 'Es-tu satisfait de l’application\u{00A0}?';
  static String ratingButton = 'Je donne mon avis';
  static String rateAppOnStoresLabel = 'Noter l’application sur les stores';
  static String proposeIdeaLabel = 'Proposer une idée';
  static String proposeIdeaSubtitle = Brand.isPassEmploi()
      ? "Aidez-nous à améliorer l’app"
      : 'Aide nous à améliorer l’app';
  static String positiveRating = "Oui ! \nBeau boulot, j’adore l’app.";
  static String negativeRating = "Non... \nJ’ai quelques remarques.";
  static String happyEmoji = "😍";
  static String sadEmoji = "😫";

  static String supportMail = "support@pass-emploi.beta.gouv.fr";

  static String ratingEmailObject(Brand brand) =>
      brand.isCej ? "Mon avis sur l’application du CEJ" : "Mon avis sur l’application pass emploi";

  static String contentSupportMail = "Aide-nous à améliorer l’application en nous donnant ton avis :\n";

  // Suggestions de recherche
  static String tesSuggestionsAlertesError = Brand.isPassEmploi()
      ? "Erreur lors de la récupération de vos suggestions d'alertes"
      : "Erreur lors de la récupération de tes suggestions d'alertes";
  static String mesSuggestionsAlertes = "Mes suggestions d'alertes";
  static String nouvellesSuggestionsDeRechercheTitre = "Tu as des suggestions d’alertes";
  static String nouvellesSuggestionsDeRechercheDescription =
      "Sur la base de ton profil France Travail, voici des suggestions d'alertes à sauvegarder";
  static String voirSuggestionsDeRecherche = "Voir les suggestions";
  static String suggestionsDeRechercheTitle = "Suggestions d'alertes";
  static String suggestionsDeRechercheHeader = Brand.isPassEmploi()
      ? "Vos suggestions peuvent venir de différentes sources. Après l’ajout, vous serez notifié si une nouvelle offre est disponible."
      : "Tes suggestions peuvent venir de différentes sources. Après l’ajout, tu seras notifié si une nouvelle offre est disponible.";
  static String suggestionSourcePoleEmploi = "Profil France Travail";
  static String suggestionSourceConseiller = "Conseiller";
  static String suggestionSourceDiagoriente = "Métiers favoris";
  static String suggestionRechercheAjoutee = "Recherche ajoutée";
  static String suggestionRechercheAjouteeDescription = Brand.isPassEmploi()
      ? "La recherche a été ajoutée à vos offres suivies"
      : "La recherche a été ajoutée à tes offres suivies";
  static String voirResultatsSuggestion = "Voir les résultats";
  static String emptySuggestionAlerteListTitre = Brand.isPassEmploi()
      ? "Vous n’avez pas encore de suggestions d’alerte"
      : "Tu n’as pas encore de suggestions d’alerte";
  static String emptySuggestionAlerteListDescriptionMilo =
      "De nouvelles suggestions pourront t'être proposées plus tard.";
  static String emptySuggestionAlerteListDescriptionPoleEmploi = Brand.isPassEmploi()
      ? "Vous pouvez remplir votre profil France Travail pour avoir des suggestions qui vous correspondent"
      : "Tu peux remplir ton profil France Travail pour avoir des suggestions qui te correspondent";

  // Événements
  static String eventListError = "Erreur lors de la récupération des événements";
  static String eventListEmpty = "Il n’y a pas encore d’événement dans ta Mission Locale";
  static String eventListEmptySubtitle = "Tu retrouvereras ici tous les événements programmés de ta mission locale.";
  static String eventListHeaderText = "Retrouve ici l’ensemble des événements organisés par ta Mission locale";
  static String eventVousEtesDejaInscrit = "Je suis déjà inscrit";
  static String eventAnnulerMonInscription = "Annulation possible";
  static String eventInscrivezVousPourParticiper = "Faire une demande d'inscription";
  static String eventAutoInscription = "M'inscrire pour participer";
  static String eventComplet = "Complet";
  static String eventAppBarTitle = "Événements";
  static String eventTabMaMissionLocale = "Ma Mission Locale";
  static String eventTabExternes = "Externes";
  static String eventEmploiDetailsAppBarTitle = "Détails de l’événement";
  static String eventEmploiDetailsPartagerConseiller = "Partager l'événement à mon conseiller";
  static String eventEmploiDetailsInscription = "Je m'inscris";
  static String eventPlaceholderTitle = Brand.isPassEmploi() ? "Trouvez un événement" : "Trouve un événement";
  static String eventPlaceholderSubtitle = Brand.isPassEmploi()
      ? "Commencez votre recherche en remplissant les champs ci-dessus."
      : "Commence ta recherche en remplissant les champs ci-dessus.";

  // auto desinscription
  static String dateLimiteAnnulation = "Date limite d'annulation";
  static String autoDesinscriptionFormConfirmation = "Confirmes-tu l’annulation à cet événement ?";
  static String autoDesinscriptionFormFieldTitle = "* Précise le motif de ton annulation";
  static String autoDesinscriptionConfirm = "Confirmer l’annulation";
  static String autoDesinscriptionCancel = "Garder mon inscription";
  static String autoDesinscriptionVoirAutresEvenements = "Voir d'autres événements";
  static String autoDesinscriptionSuccessTitle(String eventTitle) =>
      "Ton inscription à l'événement $eventTitle a été annulée";
  static String autoDesinscriptionSuccessAppBarTitle = "Annulation confirmée";

  // Événements Emploi
  static const String secteurActiviteLabel = "Secteur d'activité";
  static String secteurActiviteHint = Brand.isPassEmploi()
      ? "Sélectionnez un secteur d'activité"
      : "Sélectionne un secteur d'activité";
  static const String secteurActiviteAll = "Tous les secteurs d'activité";
  static const String secteurActiviteAgriculture =
      "Agriculture et Pêche, Espaces naturels et Espaces verts, Soins aux animaux";
  static const String secteurActiviteArt = "Arts et Façonnage d'ouvrages d'art";
  static const String secteurActiviteBanque = "Banque, Assurance, Immobilier";
  static const String secteurActiviteCommerce = "Commerce, Vente et Grande distribution";
  static const String secteurActiviteCommunication = "Communication, Média et Multimédia";
  static const String secteurActiviteBatiment = "Construction, Bâtiment et Travaux publics";
  static const String secteurActiviteTourisme = "Hôtellerie-Restauration, Tourisme, Loisirs et Animation";
  static const String secteurActiviteIndustrie = "Industrie";
  static const String secteurActiviteInstallation = "Installation et Maintenance";
  static const String secteurActiviteSante = "Santé";
  static const String secteurActiviteServices = "Services à la personne et à la collectivité";
  static const String secteurActiviteSpectacle = "Spectacle";
  static const String secteurActiviteSupport = "Support à l'entreprise";
  static const String secteurActiviteTransport = "Transport et Logistique";
  static const String evenementEmploiTypeAll = "Tous les types d’événements";
  static const String evenementEmploiTypeReunionInformation = "Réunion d'information";
  static const String evenementEmploiTypeForum = "Forum";
  static const String evenementEmploiTypeConference = "Conférence";
  static const String evenementEmploiTypeAtelier = "Atelier";
  static const String evenementEmploiTypeSalonEnLigne = "Salon en ligne";
  static const String evenementEmploiTypeJobDating = "Job Dating";
  static const String evenementEmploiTypeVisiteEntreprise = "Visite d'entreprise";
  static const String evenementEmploiTypePortesOuvertes = "Portes ouvertes";
  static const String evenementEmploiModaliteEnPhysique = "En présentiel";
  static const String evenementEmploiModaliteADistance = "À distance";
  static const String evenementEmploiDetails = "Détail de l'événement";
  static const String evenementEmploiFiltres = "Filtrer les événements";
  static const String evenementEmploiFiltresModalites = "Modalités d'accès";
  static const String evenementEmploiFiltresType = "Type d’événements";
  static const String evenementEmploiFiltresDate = "Période";
  static const String evenementEmploiFiltresDateDebut = "Date de début";
  static const String evenementEmploiFiltresDateFin = "Date de fin";

  // Mode dégradé France Travail
  static String reloadPage = "Recharger la page";

  static String dateDerniereMiseAJourRendezvous(String date) => Brand.isPassEmploi()
      ? "Dernière actualisation de vos rendez-vous le $date"
      : "Dernière actualisation de tes rendez-vous le $date";

  static String dateDerniereMiseAJourDemarches(String date) => Brand.isPassEmploi()
      ? "Dernière actualisation de vos démarches le $date"
      : "Dernière actualisation de tes démarches le $date";

  // CV
  static String cvCardTitle = "CV";
  static String cvCardSubtitle =
      "Prépare tes prochaines candidatures en téléchargeant tes CV France Travail directement sur ton téléphone.";
  static String cvCadCaption = "Voir";
  static String cvListPageTitle = "CV";
  static String cvListPageSubtitle = Brand.isPassEmploi()
      ? "Téléchargez vos CV France Travail sur votre téléphone pour préparer votre candidature"
      : "Télécharge tes CV France Travail sur ton téléphone pour préparer ta candidature";
  static String cvError = "Erreur lors de la récupération des CVs France Travail";
  static String cvListEmptyTitle = Brand.isPassEmploi()
      ? "Vous n’avez pas de CV dans votre espace France Travail"
      : "Tu n’as pas de CV dans ton espace France Travail";
  static String cvListEmptySubitle = Brand.isPassEmploi()
      ? "Déposez votre CV dans votre espace France Travail pour le récupérer automatiquement quand vous postulerez à des offres"
      : "Dépose ton CV dans ton espace France Travail pour le récupérer automatiquement quand tu postuleras à des offres";
  static String cvEmptyButton = "Mon espace France Travail";
  static String cvDownload = "Télécharger";
  static String cvErrorApiPeKoMessage = Brand.isPassEmploi()
      ? "Impossible de se synchroniser avec votre espace France Travail"
      : "Impossible de se synchroniser avec ton espace France Travail";
  static String cvErrorApiPeKoButton = "Recharger la page";

  // Postuler
  static String postulerOffreTitle = "Postuler";
  static String postulerTitle = Brand.isPassEmploi()
      ? "Récupérez votre CV sur votre téléphone"
      : "Récupère ton CV sur ton téléphone";
  static String postulerContinueButton = Brand.isPassEmploi() ? "Continuez vers l’offre" : "Continue vers l’offre";

  // Suggestions alertes location form
  static String suggestionLocalisationAppBarTitle = Brand.isPassEmploi()
      ? "Paramétrer votre alerte"
      : "Paramétrer ton alerte";
  static String suggestionLocalisationFormEmploiSubtitle = Brand.isPassEmploi()
      ? "Sélectionnez une ville ou un département dans lequel vous cherchez un emploi."
      : "Sélectionne une ville ou un département dans lequel tu cherches un emploi.";
  static String suggestionLocalisationFormImmersionSubtitle = Brand.isPassEmploi()
      ? "Sélectionnez une ville dans laquelle vous cherchez une immersion."
      : "Sélectionne une ville dans laquelle tu cherches une immersion.";
  static String suggestionLocalisationAddAlerteButton = "Ajouter l’alerte";

  // CGU
  static String cguNeverAcceptedTitle = Brand.isCej()
      ? "Bienvenue sur l’application du CEJ"
      : "Bienvenue sur l’application pass emploi";
  static String cguUpdateRequiredTitle = "Mise à jour des Conditions Générales d'Utilisation (CGU)";
  static List<String> cguNeverAcceptedDescription = Brand.isPassEmploi()
      ? [
          "L’utilisation de notre service est soumise à l’acceptation préalable de nos ",
          "↗ Conditions Générales d’Utilisation",
          ". Ces conditions définissent ",
          "vos droits et obligations en tant qu'utilisateur ",
          "de notre application.",
        ]
      : [
          "L’utilisation de notre service est soumise à l’acception préalable de nos ",
          "↗ Conditions Générales d’Utilisation",
          ". Ces conditions définissent ",
          "tes droits et obligations en tant qu'utilisateur ",
          "de notre application.",
        ];
  static List<String> cguUpdateRequiredDescription = [
    "Nous avons mis à jour nos CGU le ",
    ". L’utilisation de notre service est soumise à l’acception préalable de nos ",
    "↗ CGU.",
    "\n\nPoints clés de la mise à jour :\n",
  ];
  static List<String> cguNeverAcceptedSwitch = [
    "J’ai lu et j’accepte les",
    " ↗ Conditions Générales d’Utilisation",
  ];
  static List<String> cguUpdateRequiredSwitch = [
    "J’ai lu et j’accepte les nouvelles",
    " ↗ CGU",
  ];
  static String cguSwitchError = Brand.isPassEmploi()
      ? "Acceptez les Conditions Générales d’Utilisation pour utiliser l’application."
      : "Accepte les Conditions Générales d’Utilisation pour utiliser l’application.";
  static String cguAccept = "Valider";
  static String cguRefuse = "Refuser et se déconnecter";

  static String cguSwitchLabel(bool accepted) => accepted ? "Refuser les cgu" : "Accepter les cgu";

  // In-app feedback
  static String feedbackBad = "Pas d’accord";
  static String feedbackNeutral = "Neutre";
  static String feedbackGood = "D’accord";
  static String feedbackThanks = Brand.isPassEmploi() ? "Merci pour votre retour !" : "Merci pour ton retour !";

  static String feedbackProvenanceOffre(String provenance) =>
      "Connaître la source d’une offre ($provenance, etc) m’intéresse.";
  static String feedbackCreateDemarche = Brand.isPassEmploi()
      ? "Qu’avez-vous pensé de la nouvelle saisie des démarches ?"
      : "Qu’as-tu pensé de la nouvelle saisie des démarches ?";

  // centre de notifications
  static String notificationsCenterTooltip = "Centre de notifications";
  static String notificationsCenterTitle = "Notifications";
  static String notificationsCenterError = "Erreur lors de la récupération des notifications";
  static String notificationsCenterEmptyTitle = Brand.isPassEmploi()
      ? "Vous n’avez pas de nouvelle notification."
      : "Tu n’as pas de nouvelle notification.";

  // a11y
  static String selectedRadioButton = "Sélectionné";
  static String unselectedRadioButton = "Non sélectionné";

  static String deleteSelection = "Supprimer la sélection";

  static String iconAlternativeLocation = "Localisation";
  static String iconAlternativeContractType = "Type de contrat";
  static String iconAlternativeSalary = "Salaire";
  static String iconAlternativeDuration = "Temps de travail";
  static String iconAlternativeDate = "Date";
  static String iconAlternativeHour = "Horaire";
  static String iconAlternativeDateDeDebut = "Date de début";
  static String iconAlternativeDateDeFin = "Date de fin";
  static String a11yHours = " heures ";
  static String a11yMinutes = " minutes ";
  static String a11yDuration = "durée : ";
  static String a11yMonday = "lundi";
  static String a11yTuesday = "mardi";
  static String a11yWednesday = "mercredi";
  static String a11yThursday = "jeudi";
  static String a11yFriday = "vendredi";
  static String a11ySaturday = "samedi";
  static String a11ySunday = "dimanche";
  static String a11yJanuary = " janvier ";
  static String a11yFebruary = " février ";
  static String a11yMarch = " mars ";
  static String a11yApril = " avril ";
  static String a11yMay = " mai ";
  static String a11yJune = " juin ";
  static String a11yJuly = " juillet ";
  static String a11yAugust = " août ";
  static String a11ySeptember = " septembre ";
  static String a11yOctober = " octobre ";
  static String a11yNovember = " novembre ";
  static String a11yDecember = " décembre ";

  static String a11yStatus = "Statut : ";

  // textes alternatifs
  static String offreEnregistreeRemove(String offre) => "Retirer l'offre $offre des offres suivies";

  static String offreEnregistreeAdd(String offre) => "Enregistrer l'offre $offre";
  static String link = "Lien";
  static String semanticsLabelInformation = "Information";
  static String invalidField = "Champ invalide";
  static String loadingAnnouncement = "Chargement en cours";
  static String closeDialog = "Fermer la boîte de dialogue";
  static String closeInformationMessage = "Fermer le message d'information";
  static String chosenValue = "Valeur choisie :";
  static String buttonRole = "bouton";
  static String bottomSheetBarrierLabel = "$closeDialog, $buttonRole";
  static String source = "Source : ";
  static const String moodBad = "Emoticone pas d’accord du tout";
  static const String sentimentDissatisfied = "Emoticone plutôt pas d’accord";
  static const String sentimentNeutral = "Emoticone neutre";
  static const String sentimentSatisfied = "Emoticone plutôt d’accord";
  static const String mood = "Emoticone d’accord";
  static const String emptyDate = "Aucune date sélectionnée";
  static String feedbackCommentaire = Brand.isPassEmploi()
      ? "Dites-nous pourquoi vous avez attribué cette note\u{00A0}?"
      : "Dis-nous pourquoi tu as attribué cette note\u{00A0}?";
  static String submitFeedback = Brand.isPassEmploi() ? "Soumettre votre réponse" : "Soumettre ta réponse";

  static String removeDistance(int value) => 'Diminuer la distance de $value km';

  static String addDistance(int value) => 'Augmenter la distance de $value km';

  static String listOffres = "Liste des offres";

  // Autoinscription
  static String demandeInscriptionConfirmationTitle = "Demande d'inscription";
  static String demandeInscriptionError = "Erreur lors de la demande d'inscription";
  static String demandeInscriptionErrorButton = "Revenir au détail";
  static String demandeInscriptionDescription = "Ta demande d’inscription à l’événement a été envoyée à ton conseiller";
  static String consulterAutresEvennements = "Consulter d’autres événements";
  static String nombreDePlacesInssufisantesError =
      "Cet événement est victime de son succès. Il n'y a plus de place disponible.";
  static String conseillerInactifError = "Ton conseiller est inactif";
  static String autoInscriptionConfirmation(String eventTitle) =>
      "Ton inscription à l’événement $eventTitle est confirmée";
  static String autoInscriptionContent = "Bravo pour ton engagement !";

  // Suivi des offres
  static String offreSuivieBottomSheetTitle = Brand.isPassEmploi()
      ? "Avez-vous postulé à cette offre ?"
      : "As-tu postulé à cette offre ?";
  static String offreSuivieOuiPostule = "Oui, j’ai postulé";
  static String offreSuiviePasEncore = "Pas encore, mais ça m’intéresse";
  static String offreSuivieNonPasInteresse = "Non, ça ne m’intéresse plus";

  static String offrePostuleeConfirmationAppBar = "Offre postulée";
  static String offreFavorisConfirmationAppBar = "Offre enregistrée";
  static String offreSuivieConfirmationPageTitle = Brand.isPassEmploi()
      ? "Retrouvez cette offre dans votre suivi des offres"
      : "Retrouve cette offre dans ton suivi des offres";
  static String offreSuivieConfirmationPageDescription = Brand.isPassEmploi()
      ? "👏 Bravo pour votre engagement !"
      : "👏 Bravo pour ton engagement !";
  static String youConsultedThisOfferAt(String timeAgo) =>
      Brand.isPassEmploi() ? "Vous avez consulté cette offre $timeAgo" : "Tu as consulté cette offre $timeAgo";
  static String youSavedThisOfferAt(String timeAgo) =>
      Brand.isPassEmploi() ? "Vous avez enregistré cette offre $timeAgo" : "Tu as enregistré cette offre $timeAgo";
  static String ouEnEtesVous = Brand.isPassEmploi() ? "Où en êtes-vous ?" : "Où en es-tu ?";

  static String jaiPostule = "J’ai postulé";
  static String caMinteresse = "Ça m’intéresse";
  static String notYetPostuled = "Je n'ai pas encore postulé";
  static String caNeMinteressePas = "Ça ne m’intéresse plus";
  static String seeNextOffer = "Voir l’offre suivante";
  static String merciPourVotreReponse = Brand.isPassEmploi() ? "Merci pour votre réponse" : "Merci pour ta réponse";
  static String suivezVosOffres = Brand.isPassEmploi() ? "Suivez vos offres" : "Suis tes offres";
  static String suivezVosOffresDescription = Brand.isPassEmploi()
      ? "Retrouvez ici les offres auxquelles vous avez postulé"
      : "Retrouve ici les offres auxquelles tu as postulé";
  static String addAction = "Créer l'action";
  static String addDemarche = "Créer la démarche";
  static String wishToCreateAction = "Souhaites-tu créer l’action ? ";
  static String wishToCreateDemarche = Brand.isPassEmploi()
      ? "Souhaitez-vous créer la démarche ? "
      : "Souhaites-tu créer la démarche ? ";
  static String jaiPostuleAOffre = "J’ai postulé à une offre";
  static String jaiPostuleA(String offre, String societe) => "J’ai postulé à l’offre $offre de la société $societe";
  static String unknown = "Inconnu";

  static String boulangerCampagneTitle = "1000 immersions dans les métiers de la vente et de la logistique";
  static String boulangerCampagneDescription = "Découvre les métiers de la vente et de la logistique.";

  // Actualite Mission Locale
  static String externalUrlAlertTitle = "Ce lien redirige vers un site externe";
  static String actualiteMissionLocaleSupprime = "Actualité supprimée";
}
