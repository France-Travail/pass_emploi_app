import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/presentation/onboarding_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_profil_tile.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (BuildContext context) => const OnboardingPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Tracker(
      tracking: AnalyticsScreenNames.onboardingAccueil,
      child: Theme(
        data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
        child: StoreConnector<AppState, OnboardingViewModel>(
          converter: (store) => OnboardingViewModel.create(store),
          builder: (context, viewModel) {
            return Scaffold(
              backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(
                context,
              ),
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(
                  context,
                ),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                actions: [
                  DsfrButton(
                    label: Strings.close,
                    icon: DsfrIcons.systemCloseLine,
                    iconLocation: DsfrButtonIconLocation.right,
                    variant: DsfrButtonVariant.tertiaryWithoutBorder,
                    size: DsfrComponentSize.sm,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DsfrSpacings.s2w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: _ProgressBadge(viewModel: viewModel)),
                      const SizedBox(height: DsfrSpacings.s3v),
                      AutoFocusA11y(
                        child: Semantics(
                          header: true,
                          child: Text(
                            Strings.onboardingTitle,
                            textAlign: TextAlign.center,
                            style: DsfrTextStyle.headline3(
                              color: DsfrColorDecisions.textTitleGrey(context),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: DsfrSpacings.s3v),
                      Text(
                        Strings.onboardingSubtitle,
                        style: DsfrTextStyle.bodyMd(
                          color: DsfrColorDecisions.textTitleGrey(context),
                        ),
                      ),
                      const SizedBox(height: DsfrSpacings.s3v),
                      ..._stepTiles(context, viewModel),
                      const SizedBox(height: DsfrSpacings.s4w),
                      DsfrButton(
                        label: Strings.skipOnboarding,
                        variant: DsfrButtonVariant.secondary,
                        size: DsfrComponentSize.md,
                        onPressed: () =>
                            _showSkipOnboardingDialog(context, viewModel),
                      ),
                      const SizedBox(height: DsfrSpacings.s2w),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _stepTiles(BuildContext context, OnboardingViewModel viewModel) {
    final tiles = [
      _OnboardingStepTile(
        title: Strings.installOnboardingSection,
        icon: DsfrIcons.deviceSmartphoneLine,
        isCompleted: true,
      ),
      _OnboardingStepTile(
        title: Strings.messageOnboardingSection,
        icon: DsfrIcons.communicationChat3Line,
        isCompleted: viewModel.messageCompleted,
        onTap: () {
          Navigator.of(context).pop();
          viewModel.onMessageOnboarding.call();
        },
      ),
      if (viewModel.withActionStep)
        _OnboardingStepTile(
          title: viewModel.actionStepLabel,
          icon: DsfrIcons.editorListOrdered,
          isCompleted: viewModel.actionCompleted,
          onTap: () {
            Navigator.of(context).pop();
            viewModel.onActionOnboarding.call();
          },
        ),
      _OnboardingStepTile(
        title: Strings.offreOnboardingSection,
        icon: DsfrIcons.systemSearchLine,
        isCompleted: viewModel.offreCompleted,
        onTap: () {
          Navigator.of(context).pop();
          viewModel.onOffreOnboarding.call();
        },
      ),
      _OnboardingStepTile(
        title: Strings.evenementOnboardingSection,
        icon: DsfrIcons.businessCalendarEventLine,
        isCompleted: viewModel.evenementCompleted,
        onTap: () {
          Navigator.of(context).pop();
          viewModel.onEvenementOnboarding.call();
        },
      ),
      _OnboardingStepTile(
        title: Strings.outilsOnboardingSection,
        icon: DsfrIcons.othersLightbulbLine,
        isCompleted: viewModel.outilsCompleted,
        onTap: () {
          Navigator.of(context).pop();
          viewModel.onOutilsOnboarding.call();
        },
      ),
    ];

    return [
      for (var i = 0; i < tiles.length; i++) ...[
        if (i > 0) const SizedBox(height: DsfrSpacings.s3v),
        tiles[i],
      ],
    ];
  }

  void _showSkipOnboardingDialog(
    BuildContext context,
    OnboardingViewModel viewModel,
  ) async {
    final result = await _SkipOnboardingDialog.show(context, viewModel);
    if (result == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final progressPercent = viewModel.totalSteps == 0
        ? 0
        : ((viewModel.completedSteps / viewModel.totalSteps) * 100).round();
    return Semantics(
      label: '${viewModel.completedSteps} sur ${viewModel.totalSteps}',
      child: ExcludeSemantics(
        child: DsfrBadge(
          label: Strings.inviteAccueilDiscoveryProgress(progressPercent),
          type: DsfrBadgeType.news,
          size: DsfrComponentSize.sm,
          withIcon: true,
        ),
      ),
    );
  }
}

class _OnboardingStepTile extends StatelessWidget {
  const _OnboardingStepTile({
    required this.title,
    required this.icon,
    required this.isCompleted,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DsfrProfilTile(
      icon: isCompleted ? DsfrIcons.systemCheckLine : icon,
      iconBackgroundColor: isCompleted
          ? DsfrColors.greenEmeraude950
          : DsfrColorDecisions.backgroundOpenBlueFrance(context),
      title: title,
      onTap: isCompleted ? null : onTap,
      semanticsLabel: isCompleted
          ? '$title. ${Strings.onboardingStepCompleted}'
          : title,
    );
  }
}

class _SkipOnboardingDialog extends StatelessWidget {
  const _SkipOnboardingDialog({required this.viewModel});

  final OnboardingViewModel viewModel;

  static Future<bool?> show(
    BuildContext context,
    OnboardingViewModel viewModel,
  ) {
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
        child: DsfrModal(
          isDismissible: true,
          closeLabel: Strings.close,
          child: _SkipOnboardingDialog(viewModel: viewModel),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            Strings.skipOnboarding,
            style: DsfrTextStyle.headline4(
              color: DsfrColorDecisions.textTitleGrey(context),
            ),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          Strings.skipOnboardingContent,
          style: DsfrTextStyle.bodyMd(
            color: DsfrColorDecisions.textDefaultGrey(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        DsfrButton(
          label: Strings.continueLabel,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () {
            viewModel.onSkipOnboarding.call();
            PassEmploiMatomoTracker.instance.trackEvent(
              eventCategory: AnalyticsEventNames.onboardingCategory,
              action: AnalyticsEventNames.onboardingSkipOnboardingAction,
            );
            Navigator.pop(context, true);
          },
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: Strings.cancelLabel,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    );
  }
}
