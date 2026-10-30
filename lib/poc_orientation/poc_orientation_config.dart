// Accès France Travail (recette) injectés au build par scripts/poc_orientation_build.ps1, jamais versionnés.
// Sans eux, le POC reste invisible.
class PocOrientationConfig {
  static const clientId = String.fromEnvironment('POC_FT_CLIENT_ID');
  static const clientSecret = String.fromEnvironment('POC_FT_CLIENT_SECRET');
  static const loginUrl = String.fromEnvironment('POC_FT_LOGIN_URL');
  static const apiBaseUrl = String.fromEnvironment('POC_FT_API_BASE_URL');

  static bool get isEnabled =>
      clientId.isNotEmpty && clientSecret.isNotEmpty && loginUrl.isNotEmpty && apiBaseUrl.isNotEmpty;
}
