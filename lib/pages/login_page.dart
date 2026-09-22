import 'package:clock/clock.dart';
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: _HiddenInviteAccess(
                    viewModel: viewModel,
                    child: const BlocMarque(),
                  ),
                ),
                const SizedBox(height: Margins.spacing_s),
                GestureDetector(
                  onDoubleTap: () => Navigator.push(context, ExplicationModeDemoPage.materialPageRoute()),
                  child: Center(
                    child: AppLogo(
                      width: 120,
                      color: viewModel.withThemedAppLogo ? DsfrColorDecisions.textTitleGrey(context) : null,
                    ),
                  ),
                ),
                const SizedBox(height: Margins.spacing_l),
                Semantics(
                  header: true,
                  child: Text(
                    viewModel.title,
                    style: DsfrTextStyle.headline2(color: DsfrColorDecisions.textTitleGrey(context)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: Margins.spacing_base),
                Text(
                  viewModel.description,
                  style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textTitleGrey(context)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Margins.spacing_base),
                LoginPageRemoteMessageCard(),
                if (viewModel.withLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: Margins.spacing_m),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  _OrganismButton(
                    label: Strings.loginBottomSeetFranceTravailButton,
                    logo: Drawables.franceTravailLogoTitle,
                    onPressed: viewModel.onFranceTravailLogin,
                  ),
                  if (viewModel.onMissionLocaleLogin != null) ...[
                    const SizedBox(height: Margins.spacing_base),
                    _OrganismButton(
                      label: Strings.loginBottomSeetMissionLocaleButton,
                      logo: Drawables.missionLocaleLogoTitle,
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

class _HiddenInviteAccess extends StatefulWidget {
  const _HiddenInviteAccess({required this.viewModel, required this.child});

  final LoginPageViewModel viewModel;
  final Widget child;

  @override
  State<_HiddenInviteAccess> createState() => _HiddenInviteAccessState();
}

class _HiddenInviteAccessState extends State<_HiddenInviteAccess> {
  static const int _requiredTaps = 5;
  static const Duration _maxDelayBetweenTaps = Duration(seconds: 1);

  int _tapCount = 0;
  DateTime? _lastTapAt;

  Future<void> _onTap() async {
    if (widget.viewModel.withLoading) return;
    final now = clock.now();
    final lastTapAt = _lastTapAt;
    final isSameSequence = lastTapAt != null && now.difference(lastTapAt) <= _maxDelayBetweenTaps;
    _tapCount = isSameSequence ? _tapCount + 1 : 1;
    _lastTapAt = now;
    if (_tapCount < _requiredTaps) return;

    _tapCount = 0;
    _lastTapAt = null;
    final isPasswordValid = await _InviteAccessModal.show(context, widget.viewModel.isInviteAccessPasswordValid);
    if (isPasswordValid == true) widget.viewModel.onInviteLogin();
  }

  @override
  Widget build(BuildContext context) {
    // Accès volontairement caché : non exposé aux lecteurs d'écran.
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      child: widget.child,
    );
  }
}

class _InviteAccessModal extends StatefulWidget {
  const _InviteAccessModal({required this.isPasswordValid});

  final bool Function(String password) isPasswordValid;

  static Future<bool?> show(BuildContext context, bool Function(String password) isPasswordValid) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: DsfrColorDecisions.backgroundTransparent(context),
      barrierColor: DsfrColorDecisions.backgroundOverlayGrey(context),
      barrierLabel: Strings.bottomSheetBarrierLabel,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Theme(
        data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DsfrModal(
            isDismissible: true,
            closeLabel: Strings.close,
            child: _InviteAccessModal(isPasswordValid: isPasswordValid),
          ),
        ),
      ),
    );
  }

  @override
  State<_InviteAccessModal> createState() => _InviteAccessModalState();
}

class _InviteAccessModalState extends State<_InviteAccessModal> {
  String _password = "";
  bool _withError = false;

  void _onValidate() {
    if (widget.isPasswordValid(_password)) {
      Navigator.pop(context, true);
    } else {
      setState(() => _withError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.loginInviteAccessTitle,
          style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        DsfrInput(
          label: Strings.loginInviteAccessPasswordLabel,
          isPasswordMode: true,
          autofocus: true,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          onChanged: (value) => setState(() {
            _password = value;
            _withError = false;
          }),
          onFieldSubmitted: (_) => _onValidate(),
          componentState: _withError
              ? DsfrComponentState.error(errorMessage: Strings.loginInviteAccessWrongPassword)
              : const DsfrComponentState.none(),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        DsfrButton(
          label: Strings.loginInviteAccessValidate,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: _onValidate,
        ),
      ],
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
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        child: InkWell(
          onTap: onPressed,
          child: ExcludeSemantics(
            child: Container(
              constraints: const BoxConstraints(minHeight: 68),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(logo, width: 48, height: 48, fit: BoxFit.cover),
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
        ),
      ),
    );
  }
}

class _InformationsLegales extends StatefulWidget {
  @override
  State<_InformationsLegales> createState() => _InformationsLegalesState();
}

class _InformationsLegalesState extends State<_InformationsLegales> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    const divider = DsfrDivider();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        divider,
        Semantics(
          button: true,
          expanded: _isExpanded,
          label: Strings.legalInformation,
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: ColoredBox(
              color: _isExpanded
                  ? DsfrColorDecisions.backgroundActionLowBlueFrance(context)
                  : DsfrColorDecisions.backgroundTransparent(context),
              child: ExcludeSemantics(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s3v),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
                            child: Text(
                              Strings.legalInformation,
                              style: DsfrTextStyle.bodyMdMedium(
                                color: DsfrColorDecisions.textActionHighBlueFrance(context),
                              ),
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isExpanded ? -0.5 : 0,
                          duration: Durations.short4,
                          child: Icon(
                            DsfrIcons.systemArrowDownSLine,
                            size: DsfrSpacings.s2w,
                            color: DsfrColorDecisions.textActionHighBlueFrance(context),
                          ),
                        ),
                        const SizedBox(width: DsfrSpacings.s2w),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: DsfrSpacings.s2w, bottom: DsfrSpacings.s3w),
            child: Column(
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
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: Durations.short4,
        ),
        divider,
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
