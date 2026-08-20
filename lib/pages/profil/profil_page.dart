import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/deep_link/deep_link_actions.dart';
import 'package:pass_emploi_app/features/details_jeune/details_jeune_actions.dart';
import 'package:pass_emploi_app/features/developer_option/activation/developer_options_action.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/models/deep_link.dart';
import 'package:pass_emploi_app/pages/cv/cv_list_page.dart';
import 'package:pass_emploi_app/pages/notification_preferences_page.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_page.dart';
import 'package:pass_emploi_app/pages/partage_activite_page.dart';
import 'package:pass_emploi_app/pages/profil/confidentialite_page.dart';
import 'package:pass_emploi_app/pages/profil/matomo_logging_page.dart';
import 'package:pass_emploi_app/pages/suppression_compte_page.dart';
import 'package:pass_emploi_app/presentation/profil/profil_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/widgets/cards/profil/mon_conseiller_card.dart';
import 'package:pass_emploi_app/widgets/contact_page.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_profil_tile.dart';
import 'package:pass_emploi_app/widgets/rating_page.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';

class ProfilPage extends StatelessWidget {
  static MaterialPageRoute<void> materialPageRoute() => MaterialPageRoute(builder: (context) => ProfilPage());

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.profil,
      child: StoreConnector<AppState, ProfilPageViewModel>(
        onInit: (store) => store.dispatch(DetailsJeuneRequestAction()),
        converter: (store) => ProfilPageViewModel.create(store),
        builder: (_, vm) => _Scaffold(vm),
        distinct: true,
      ),
    );
  }
}

class _Scaffold extends StatelessWidget {
  final ProfilPageViewModel viewModel;

  const _Scaffold(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: const BackAppBar(),
      body: Semantics(
        container: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionTitle(Strings.menuProfil),
                const SizedBox(height: DsfrSpacings.s2w),
                _IdentityHighlight(viewModel: viewModel),
                if (viewModel.displayMonCompte) ...[
                  const SizedBox(height: DsfrSpacings.s4w),
                  _SectionTitle(Strings.myAccountLabel),
                  const SizedBox(height: DsfrSpacings.s1w),
                  DsfrProfilTile(
                    icon: DsfrIcons.businessMailLine,
                    iconBackgroundColor: DsfrColors.blueCumulus925,
                    title: viewModel.userEmail,
                    description: Strings.emailAddressAccountLabel,
                    semanticsLabel: "${Strings.emailAddressAccountLabel} : ${viewModel.userEmail}",
                  ),
                  if (viewModel.withDownloadCv) ...[
                    const SizedBox(height: DsfrSpacings.s1w),
                    DsfrProfilTile(
                      icon: DsfrIcons.documentFileLine,
                      iconBackgroundColor: DsfrColors.blueCumulus925,
                      title: Strings.cvCardTitle,
                      description: Strings.cvTileSubtitle,
                      onTap: () => Navigator.push(context, CvListPage.materialPageRoute()),
                    ),
                  ],
                  if (viewModel.displayMonConseiller) ...[
                    const SizedBox(height: DsfrSpacings.s1w),
                    MonConseillerCard(),
                  ],
                ],
                const SizedBox(height: DsfrSpacings.s4w),
                _SectionTitle(Strings.helpTitle),
                const SizedBox(height: DsfrSpacings.s1w),
                DsfrProfilTile(
                  icon: DsfrIcons.systemStarLine,
                  iconBackgroundColor: DsfrColors.purpleGlycine925,
                  title: Strings.ratingAppLabel,
                  description: Strings.ratingAppSubtitle,
                  onTap: () => Navigator.push(context, RatingPage.materialPageRoute()),
                ),
                const SizedBox(height: DsfrSpacings.s1w),
                DsfrProfilTile(
                  icon: DsfrIcons.businessMailLine,
                  iconBackgroundColor: DsfrColors.purpleGlycine925,
                  title: Strings.contactTeamLabel,
                  description: Strings.contactTeamSubtitle,
                  onTap: () => Navigator.push(context, ContactPage.materialPageRoute()),
                ),
                const SizedBox(height: DsfrSpacings.s4w),
                _SectionTitle(Strings.settingsLabel),
                const SizedBox(height: DsfrSpacings.s1w),
                _ThemeRadios(
                  themeMode: viewModel.themeMode,
                  onThemeModeChanged: viewModel.onThemeModeChanged,
                ),
                const SizedBox(height: DsfrSpacings.s1w),
                DsfrProfilTile(
                  icon: DsfrIcons.mediaNotification3Line,
                  iconBackgroundColor: DsfrColors.greenEmeraude950,
                  title: Strings.notificationsLabel,
                  onTap: () => Navigator.push(context, NotificationPreferencesPage.materialPageRoute()),
                ),
                if (viewModel.displayPartageActivite) ...[
                  const SizedBox(height: DsfrSpacings.s1w),
                  DsfrProfilTile(
                    icon: DsfrIcons.systemShareForwardLine,
                    iconBackgroundColor: DsfrColors.greenEmeraude950,
                    title: Strings.activityShareLabel,
                    onTap: () => Navigator.push(context, PartageActivitePage.materialPageRoute()),
                  ),
                ],
                const SizedBox(height: DsfrSpacings.s1w),
                DsfrProfilTile(
                  icon: DsfrIcons.systemShieldLine,
                  iconBackgroundColor: DsfrColors.greenEmeraude950,
                  title: Strings.privacyAndDataLabel,
                  description: Strings.privacyAndDataSubtitle,
                  onTap: () => Navigator.push(context, ConfidentialitePage.materialPageRoute()),
                ),
                const SizedBox(height: DsfrSpacings.s1w),
                DsfrProfilTile(
                  icon: DsfrIcons.systemDeleteBinLine,
                  iconBackgroundColor: DsfrColors.greenEmeraude950,
                  title: Strings.suppressionButtonLabel,
                  onTap: () => Navigator.push(context, SuppressionComptePage.materialPageRoute()),
                ),
                const SizedBox(height: DsfrSpacings.s4w),
                DsfrButton(
                  label: Strings.logoutAction,
                  icon: DsfrIcons.systemLogoutBoxRLine,
                  variant: DsfrButtonVariant.secondary,
                  size: DsfrComponentSize.lg,
                  onPressed: () => context.dispatch(RequestLogoutAction(LogoutReason.userLogout)),
                ),
                if (kDebugMode || viewModel.displayDeveloperOptions) ...[
                  const SizedBox(height: DsfrSpacings.s4w),
                  _SectionTitle(Strings.developerOptions),
                  const SizedBox(height: DsfrSpacings.s1w),
                  _DeveloperOptions(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IdentityHighlight extends StatelessWidget {
  final ProfilPageViewModel viewModel;

  const _IdentityHighlight({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 4, color: DsfrColorDecisions.borderDefaultBlueFrance(context)),
          const SizedBox(width: DsfrSpacings.s2w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onDoubleTap: viewModel.onTitleTap,
                  child: Semantics(
                    header: true,
                    child: Text(
                      viewModel.userName,
                      style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                    ),
                  ),
                ),
                if (viewModel.withQuestionnaireHighlight) ...[
                  if (viewModel.situationLabel != null) ...[
                    const SizedBox(height: DsfrSpacings.s1w),
                    _HighlightRow(
                      label: Strings.onboardingQuestionnaireLoaderSituation,
                      value: viewModel.situationLabel!,
                    ),
                  ],
                  if (viewModel.domaineLabel != null) ...[
                    const SizedBox(height: DsfrSpacings.s1w),
                    _HighlightRow(
                      label: Strings.onboardingQuestionnaireLoaderDomaine,
                      value: viewModel.domaineLabel!,
                    ),
                  ],
                  if (viewModel.zoneLabel != null) ...[
                    const SizedBox(height: DsfrSpacings.s1w),
                    _HighlightRow(
                      label: Strings.onboardingQuestionnaireLoaderZone,
                      value: viewModel.zoneLabel!,
                    ),
                  ],
                  if (viewModel.objectifsCount > 0) ...[
                    const SizedBox(height: DsfrSpacings.s1w),
                    DsfrTag(
                      label: Strings.onboardingQuestionnaireLoaderObjectifsCount(viewModel.objectifsCount),
                      size: DsfrComponentSize.md,
                      backgroundColor: DsfrColorDecisions.backgroundContrastGrey(context),
                      textColor: DsfrColorDecisions.textLabelGrey(context),
                    ),
                  ],
                  const SizedBox(height: DsfrSpacings.s2w),
                  SizedBox(
                    width: double.infinity,
                    child: DsfrButton(
                      label: Strings.modifyMyInformation,
                      icon: DsfrIcons.designPencilLine,
                      variant: DsfrButtonVariant.secondary,
                      size: DsfrComponentSize.lg,
                      onPressed: () => Navigator.push(context, OnboardingQuestionnairePage.materialPageRoute()),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  final String label;
  final String value;

  const _HighlightRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
          ),
        ),
        const SizedBox(width: DsfrSpacings.s1w),
        Expanded(
          child: Text(
            value,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(title, style: DsfrTextStyle.headline5(color: DsfrColorDecisions.textTitleGrey(context))),
    );
  }
}

class _ThemeRadios extends StatelessWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeModeChanged;

  const _ThemeRadios({required this.themeMode, required this.onThemeModeChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _themeRadio(
          context,
          mode: ThemeMode.system,
          title: Strings.themeModeSystem,
          description: Strings.themeModeSystemDescription,
          illustration: Drawables.illustrationThemeSystem,
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        _themeRadio(
          context,
          mode: ThemeMode.light,
          title: Strings.themeModeLight,
          illustration: Drawables.illustrationThemeSun,
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        _themeRadio(
          context,
          mode: ThemeMode.dark,
          title: Strings.themeModeDark,
          illustration: Drawables.illustrationThemeMoon,
        ),
      ],
    );
  }

  Widget _themeRadio(
    BuildContext context, {
    required ThemeMode mode,
    required String title,
    String? description,
    required String illustration,
  }) {
    return DsfrRadioRichButton<ThemeMode>(
      title: title,
      description: description,
      value: mode,
      groupValue: themeMode,
      size: DsfrComponentSize.md,
      isExpanded: true,
      trailingIcon: SvgPicture.asset(
        illustration,
        width: 56,
        height: 56,
        excludeFromSemantics: true,
      ),
      onChanged: (value) {
        if (value != null) onThemeModeChanged(value);
      },
    );
  }
}

class _DeveloperOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final grey = DsfrColorDecisions.backgroundContrastGrey(context);
    return Column(
      children: [
        DsfrProfilTile(
          icon: DsfrIcons.systemSettings5Line,
          iconBackgroundColor: grey,
          title: Strings.developerOptionMatomo,
          onTap: () => Navigator.push(context, MatomoLoggingPage.materialPageRoute()),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrProfilTile(
          icon: DsfrIcons.systemSettings5Line,
          iconBackgroundColor: grey,
          title: Strings.developerOptionFCM,
          onTap: () async {
            final String? token = await FirebaseMessaging.instance.getToken();
            if (token != null) {
              await Clipboard.setData(ClipboardData(text: token));
              if (context.mounted) {
                showSnackBarWithSystemError(context, "Token copié ✅");
              }
            }
          },
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrProfilTile(
          icon: DsfrIcons.systemSettings5Line,
          iconBackgroundColor: grey,
          title: Strings.developerOptionFCMDelete,
          onTap: () async {
            await FirebaseMessaging.instance.deleteToken();
            if (context.mounted) {
              showSnackBarWithSystemError(context, "Token supprimé ❌");
            }
          },
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrProfilTile(
          icon: DsfrIcons.systemSettings5Line,
          iconBackgroundColor: grey,
          title: "Récupérer le token APNs",
          onTap: () async {
            final String? token = await _getApnsToken();
            await Clipboard.setData(ClipboardData(text: token ?? ""));
            if (context.mounted) {
              showSnackBarWithSystemError(context, "Token APNs copié ✅");
            }
          },
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrProfilTile(
          icon: DsfrIcons.systemSettings5Line,
          iconBackgroundColor: grey,
          title: "Deep link parcours emploi",
          onTap: () => context.dispatch(
            HandleDeepLinkAction(MigrationParcoursEmploiDeepLink(), DeepLinkOrigin.inAppNavigation),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrProfilTile(
          icon: DsfrIcons.systemSettings5Line,
          iconBackgroundColor: grey,
          title: Strings.developerOptionDeleteAllPrefs,
          onTap: () {
            context.dispatch(DeveloperOptionsDeleteAllPrefsAction());
            showSnackBarWithSystemError(context, "Killez 💀- voire supprimer 🗑 - l'app");
          },
        ),
      ],
    );
  }

  Future<String?> _getApnsToken() async {
    const channel = MethodChannel('apns_token_channel');
    try {
      return await channel.invokeMethod<String>('getApnsToken');
    } catch (e) {
      return null;
    }
  }
}
