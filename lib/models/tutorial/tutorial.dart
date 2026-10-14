import 'package:pass_emploi_app/models/tutorial/tutorial_page.dart';

class Tutorial {
  static const String versionTimestamp = '1718704185';
  static const String ftIaTutorialVersionTimestamp = 'ia_1';
  static const String planActionVersionTimestamp = 'plan_action_3';

  static List<TutorialPage> milo = [
    // TutorialPage(
    //   title: "Le mode sombre est disponible\u{00A0}!",
    //   description:
    //       "Rendez-vous dans votre profil, rubrique Apparence, pour l'activer. Une expérience visuelle encore plus confortable.",
    //   image: "assets/tuto/tuto.webp",
    // ),
  ];
  static List<TutorialPage> pe = [
    // TutorialPage(
    //   title: "Le mode sombre est disponible\u{00A0}!",
    //   description:
    //       "Rendez-vous dans votre profil, rubrique Apparence, pour l'activer. Une expérience visuelle encore plus confortable.",
    //   image: "assets/tuto/tuto.webp",
    // ),
  ];

  static List<TutorialPage> planAction = [
    TutorialPage(
      title: "Dis-nous où tu en es…",
      description:
          "Réponds à quelques questions sur ta situation, ce que tu recherches et les difficultés que tu rencontres.",
      image: "assets/tuto/tuto_1.webp",
    ),
    TutorialPage(
      title: "Des idées pour avancer ! ",
      description:
          "Découvre des recommandations adaptées à ta situation. Choisis celles qui t’intéressent et avance à ton rythme.",
      image: "assets/tuto/tuto_2.webp",
    ),
  ];
}
