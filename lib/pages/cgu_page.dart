import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/presentation/cgu_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dsfr/bloc_marque.dart';

class CguPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.cguPage,
      child: StoreConnector<AppState, CguPageViewModel>(
        builder: (context, viewModel) => _Scaffold(viewModel),
        converter: CguPageViewModel.create,
        distinct: true,
      ),
    );
  }
}

class _Scaffold extends StatelessWidget {
  final CguPageViewModel viewModel;

  const _Scaffold(this.viewModel);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: Scaffold(
        backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DsfrSpacings.s3w,
              DsfrSpacings.s4w,
              DsfrSpacings.s3w,
              DsfrSpacings.s3w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: BlocMarque(),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
                Expanded(
                  child: _Body(
                    viewModel,
                    child: switch (viewModel.displayState) {
                      CguNeverAcceptedDisplayState() => const _CguNeverAcceptedContent(),
                      final CguUpdateRequiredDisplayState vm => _CguUpdateRequiredContent(vm),
                      null => const SizedBox.shrink(),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final CguPageViewModel viewModel;
  final Widget child;

  const _Body(this.viewModel, {required this.child});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  bool _acceptCguButtonClicked = false;
  bool _cguAccepted = false;

  @override
  Widget build(BuildContext context) {
    final bool neverAccepted = widget.viewModel.displayState is CguNeverAcceptedDisplayState;
    final switchParts = neverAccepted ? Strings.cguNeverAcceptedSwitch : Strings.cguUpdateRequiredSwitch;
    final hasError = shouldHighlightError();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s3w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                widget.child,
                const SizedBox(height: DsfrSpacings.s3w),
                const DsfrDivider(),
                const SizedBox(height: DsfrSpacings.s3w),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DsfrLink(
                    label: switchParts[1],
                    icon: DsfrIcons.systemExternalLinkLine,
                    onTap: _launchExternalRedirect,
                  ),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
                Semantics(
                  label: Strings.cguSwitchLabel(_cguAccepted),
                  child: DsfrToggleSwitch(
                    label: switchParts[0].trim(),
                    labelLocation: DsfrToggleSwitchLabelLocation.left,
                    value: _cguAccepted,
                    status: _cguAccepted
                        ? Strings.notificationsToggleEnabled
                        : Strings.notificationsToggleDisabled,
                    componentState: hasError
                        ? DsfrComponentState.error(errorMessage: Strings.cguSwitchError)
                        : const DsfrComponentState.none(),
                    onChanged: (value) => setState(() => _cguAccepted = value),
                  ),
                ),
                if (hasError) ...[
                  const SizedBox(height: DsfrSpacings.s2w),
                  DsfrAlert(
                    type: DsfrAlertType.error,
                    description: DsfrAlertDescriptionText(Strings.cguSwitchError),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        DsfrButton(
          label: Strings.cguAccept,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () {
            final controller = PrimaryScrollController.of(context);
            controller.animateTo(
              controller.position.maxScrollExtent,
              duration: AnimationDurations.medium,
              curve: Curves.easeInOut,
            );
            setState(() => _acceptCguButtonClicked = true);
            if (_cguAccepted) widget.viewModel.onAccept();
          },
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: Strings.cguRefuse,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () => widget.viewModel.onRefuse(),
        ),
      ],
    );
  }

  bool shouldHighlightError() => _acceptCguButtonClicked && !_cguAccepted;
}

class _CguNeverAcceptedContent extends StatelessWidget {
  const _CguNeverAcceptedContent();

  @override
  Widget build(BuildContext context) {
    final bodyStyle = DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageTitle(Strings.cguNeverAcceptedTitle),
        const SizedBox(height: DsfrSpacings.s3w),
        Text(Strings.cguNeverAcceptedDescription[0], style: bodyStyle),
        Align(
          alignment: Alignment.centerLeft,
          child: DsfrLink(
            label: Strings.cguNeverAcceptedDescription[1],
            icon: DsfrIcons.systemExternalLinkLine,
            onTap: _launchExternalRedirect,
          ),
        ),
        Text.rich(
          TextSpan(
            style: bodyStyle,
            children: [
              TextSpan(text: Strings.cguNeverAcceptedDescription[2]),
              TextSpan(
                text: Strings.cguNeverAcceptedDescription[3],
                style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textDefaultGrey(context)),
              ),
              TextSpan(text: Strings.cguNeverAcceptedDescription[4]),
            ],
          ),
        ),
      ],
    );
  }
}

class _CguUpdateRequiredContent extends StatelessWidget {
  final CguUpdateRequiredDisplayState displayState;

  const _CguUpdateRequiredContent(this.displayState);

  @override
  Widget build(BuildContext context) {
    final bodyStyle = DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageTitle(Strings.cguUpdateRequiredTitle),
        const SizedBox(height: DsfrSpacings.s3w),
        Text(
          Strings.cguUpdateRequiredDescription[0] +
              displayState.lastUpdateLabel +
              Strings.cguUpdateRequiredDescription[1],
          style: bodyStyle,
        ),
        DsfrLink(
          label: Strings.cguUpdateRequiredDescription[2],
          icon: DsfrIcons.systemExternalLinkLine,
          onTap: _launchExternalRedirect,
        ),
        Text(Strings.cguUpdateRequiredDescription[3], style: bodyStyle),
        for (final change in displayState.changes)
          Text(' • $change\n', style: bodyStyle),
      ],
    );
  }
}

void _launchExternalRedirect() {
  PassEmploiMatomoTracker.instance.trackOutlink(Strings.termsOfServiceUrl);
  launchExternalUrl(Strings.termsOfServiceUrl);
}
