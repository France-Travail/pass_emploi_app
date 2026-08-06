import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/mode_demo/explication_page_mode_demo.dart';
import 'package:pass_emploi_app/presentation/login_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';
import 'package:pass_emploi_app/widgets/drawables/app_logo.dart';
import 'package:pass_emploi_app/widgets/dsfr/bloc_marque.dart';
import 'package:pass_emploi_app/widgets/login_page_remote_message.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.login,
      child: StoreConnector<AppState, LoginPageViewModel>(
        converter: (store) => LoginPageViewModel.create(store),
        builder: (context, viewModel) => _Scaffold(viewModel),
        onWillChange: _onWillChange,
        distinct: true,
      ),
    );
  }

  void _onWillChange(LoginPageViewModel? previousVM, LoginPageViewModel newVM) {
    final bool isAfterWebAuthPage = previousVM?.withLoading == true && newVM.withLoading == false;
    if (!isAfterWebAuthPage) return;
    if (newVM.withWrongDeviceClockMessage || newVM.technicalErrorMessage != null) {
      _trackLoginResult(successful: false);
    } else {
      _trackLoginResult(successful: true);
    }
  }

  void _trackLoginResult({required bool successful}) {
    PassEmploiMatomoTracker.instance.trackEvent(
      eventCategory: AnalyticsEventNames.webAuthPageEventCategory,
      action: successful ? AnalyticsEventNames.webAuthPageSuccessAction : AnalyticsEventNames.webAuthPageErrorAction,
    );
  }
}

class _Scaffold extends StatelessWidget {
  final LoginPageViewModel viewModel;

  const _Scaffold(this.viewModel);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: Scaffold(
        backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: BlocMarque(),
                ),
                const SizedBox(height: Margins.spacing_s),
                GestureDetector(
                  onDoubleTap: () => Navigator.push(context, ExplicationModeDemoPage.materialPageRoute()),
                  child: const Center(child: AppLogo(width: 120)),
                ),
                const SizedBox(height: Margins.spacing_l),
                if (viewModel.withOrganismChoice) ...[
                  Text(
                    Strings.loginChooseAccountTitle,
                    style: DsfrTextStyle.headline2(color: DsfrColorDecisions.textTitleGrey(context)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Margins.spacing_base),
                  Text(
                    Strings.loginChooseAccountDescription,
                    style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textTitleGrey(context)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Margins.spacing_base),
                ],
                LoginPageRemoteMessageCard(),
                if (viewModel.withLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: Margins.spacing_m),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  _OrganismButton(
                    label: Strings.loginBottomSeetFranceTravailButton,
                    logo: Drawables.franceTravailLogo,
                    onPressed: viewModel.onFranceTravailLogin,
                  ),
                  if (viewModel.onMissionLocaleLogin != null) ...[
                    const SizedBox(height: Margins.spacing_base),
                    _OrganismButton(
                      label: Strings.loginBottomSeetMissionLocaleButton,
                      logo: Drawables.missionLocaleLogo,
                      onPressed: viewModel.onMissionLocaleLogin!,
                    ),
                  ],
                ],
                if (viewModel.technicalErrorMessage != null) ...[
                  const SizedBox(height: Margins.spacing_m),
                  _GenericError(viewModel.technicalErrorMessage!),
                ],
                if (viewModel.withWrongDeviceClockMessage) ...[
                  const SizedBox(height: Margins.spacing_m),
                  _ErrorBanner(
                    title: Strings.loginWrongDeviceClockError,
                    description: Strings.loginWrongDeviceClockErrorDescription,
                  ),
                ],
                if (viewModel.withInviteButton && viewModel.onInviteLogin != null) ...[
                  const SizedBox(height: Margins.spacing_l),
                  Divider(height: 1, color: DsfrColors.blueFrance950),
                  const SizedBox(height: Margins.spacing_base),
                  Text(
                    Strings.loginNoAccountLabel,
                    style: DsfrTextStyle.bodySmBold(color: DsfrColorDecisions.textTitleGrey(context)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Margins.spacing_base),
                  DsfrButton(
                    label: Strings.loginInviteActionCta,
                    variant: DsfrButtonVariant.secondary,
                    size: DsfrComponentSize.lg,
                    icon: DsfrIcons.systemArrowRightLine,
                    iconLocation: DsfrButtonIconLocation.right,
                    onPressed: viewModel.onInviteLogin,
                  ),
                ],
                const SizedBox(height: Margins.spacing_l),
                _InformationsLegales(),
                const SizedBox(height: Margins.spacing_m),
                Text(
                  viewModel.accessibilityLevelLabel,
                  textAlign: TextAlign.center,
                  style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textDefaultGrey(context)),
                ),
                const SizedBox(height: Margins.spacing_xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrganismButton extends StatelessWidget {
  const _OrganismButton({
    required this.label,
    required this.logo,
    required this.onPressed,
  });

  final String label;
  final String logo;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final borderColor = DsfrColorDecisions.borderActionHighBlueFrance(context);
    final textColor = DsfrColorDecisions.textActionHighBlueFrance(context);
    return Material(
      color: DsfrColorDecisions.backgroundDefaultGrey(context),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                excludeSemantics: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(logo, width: 48, height: 48, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: Margins.spacing_s),
              Flexible(
                child: Text(
                  label,
                  style: DsfrTextStyle.bodyLgMedium(color: textColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InformationsLegales extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DsfrAccordionsGroup(
      values: [
        DsfrAccordion(
          headerLabel: Strings.legalInformation,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Link(Strings.legalNoticeLabel, Strings.legalNoticeUrl),
              const SizedBox(height: Margins.spacing_base),
              Link(Strings.privacyPolicyLabel, Strings.privacyPolicyUrl),
              const SizedBox(height: Margins.spacing_base),
              Link(Strings.termsOfServiceLabel, Strings.termsOfServiceUrl),
              const SizedBox(height: Margins.spacing_base),
              Link(Strings.accessibilityLevelLabel, Strings.accessibilityUrl),
            ],
          ),
        ),
      ],
    );
  }
}

class Link extends StatelessWidget {
  final String label;
  final String link;

  const Link(this.label, this.link, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          PassEmploiMatomoTracker.instance.trackOutlink(link);
          launchExternalUrl(link);
        },
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Icon(
                DsfrIcons.systemExternalLinkLine,
                color: DsfrColorDecisions.textActionHighBlueFrance(context),
                size: 16,
              ),
            ),
            const SizedBox(width: Margins.spacing_xs),
            Text(
              label,
              style: DsfrTextStyle.bodySmMedium(color: DsfrColorDecisions.textActionHighBlueFrance(context)).copyWith(
                decoration: TextDecoration.underline,
                decorationColor: DsfrColorDecisions.textActionHighBlueFrance(context),
              ),
            ),
            Semantics(label: Strings.link),
          ],
        ),
      ),
    );
  }
}

class _GenericError extends StatelessWidget {
  final String technicalErrorMessage;

  const _GenericError(this.technicalErrorMessage);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: _ErrorBanner(title: Strings.loginGenericError, description: Strings.loginGenericErrorDescription),
      onDoubleTap: () => showDialog(context: context, builder: (context) => _ErrorInfoDialog(technicalErrorMessage)),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String title;
  final String description;

  const _ErrorBanner({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CardContainer(
        backgroundColor: AppColors.warningLighten,
        withShadow: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: DsfrTextStyle.bodySmBold(color: AppColors.warning)),
            const SizedBox(height: Margins.spacing_s),
            Text(description, style: DsfrTextStyle.bodyXs(color: AppColors.warning)),
          ],
        ),
      ),
    );
  }
}

class _ErrorInfoDialog extends StatelessWidget {
  final String message;

  const _ErrorInfoDialog(this.message);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Erreur technique'),
      content: Text(message),
      actions: [TextButton(child: Text(Strings.close), onPressed: () => Navigator.of(context).pop())],
    );
  }
}
