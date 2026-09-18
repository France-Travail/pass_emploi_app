import 'package:pass_emploi_app/models/brand.dart';

class Drawables {
  Drawables._();

  static const String _assets = "assets/";
  static const String _svg = ".svg";

  static String appLogo = Brand.isCej()
      ? "${_assets}logo_app_cej$_svg"
      : "${_assets}logo_app_brsa$_svg";

  static String badge = "${_assets}ic_badge$_svg";

  static String franceTravailLogo = "${_assets}logo-france-travail.webp";
  static String missionLocaleLogoTitle =
      "${_assets}logo_mission_locale_title.webp";
  static String franceTravailLogoTitle =
      "${_assets}logo_france_travail_title.webp";

  static String campagneRecrutementBg =
      "${_assets}campagne_recrutement_bg.webp";

  static String logoInProgress = Brand.isCej()
      ? "${_assets}cej_in_progress.webp"
      : "${_assets}brsa_in_progress.webp";

  static String blocMarqueLight = "${_assets}dsfr/bloc_marque_light.svg";
  static String blocMarqueDark = "${_assets}dsfr/bloc_marque_dark.svg";
  static String illustrationRechercheEmpty =
      "${_assets}dsfr/illustration_recherche_empty.webp";
  static String illustrationEvenementsEmpty =
      "${_assets}dsfr/illustration_evenements_empty.svg";
  static String illustrationActualitesEmpty =
      "${_assets}dsfr/illustration_actualites_empty.svg";
  static String illustrationSuccess = "${_assets}dsfr/success.svg";
  static String illustrationWarning = "${_assets}dsfr/warning.svg";
  static String illustrationThemeSystem = "${_assets}dsfr/system.svg";
  static String illustrationThemeSun = "${_assets}dsfr/sun.svg";
  static String illustrationThemeMoon = "${_assets}dsfr/moon.svg";
  static String illustrationSystem = "${_assets}dsfr/illustration_system.svg";

  static String evalImage = "${_assets}evalluation_illustration.webp";
  static String presseCard = "${_assets}dsfr/presse_card.webp";
  static String ratingStar = "${_assets}dsfr/star_line.svg";

  static String success = "${_assets}success.webp";
}
