import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/onboarding/onboarding_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/dsfr/emoji_tile.dart';

class NotificationsBottomSheet extends StatelessWidget {
  const NotificationsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
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
      routeSettings: const RouteSettings(name: AnalyticsScreenNames.onboardingPushNotificationPermission),
      builder: (context) => Theme(
        data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
        child: DsfrModal(
          isDismissible: true,
          closeLabel: Strings.close,
          child: const NotificationsBottomSheet(),
        ),
      ),
    ).then((activated) {
      if (!context.mounted) return;
      final store = StoreProvider.of<AppState>(context);
      if (activated == true) {
        PassEmploiMatomoTracker.instance.trackEvent(
          eventCategory: AnalyticsEventNames.onboardingPushNotificationPermissionCategory,
          action: AnalyticsEventNames.onboardingPushNotificationPermissionAcceptAction,
        );
        store.dispatch(OnboardingPushNotificationPermissionRequestAction());
      } else {
        PassEmploiMatomoTracker.instance.trackEvent(
          eventCategory: AnalyticsEventNames.onboardingPushNotificationPermissionCategory,
          action: AnalyticsEventNames.onboardingPushNotificationPermissionDeclineAction,
        );
        store.dispatch(OnboardingNotificationsDismissedAction());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: DsfrSpacings.s3w),
        const Center(
          child: EmojiTile(
            emoji: '🔔',
            backgroundColor: DsfrColors.purpleGlycine925,
          ),
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        Text(
          Strings.notificationsBottomSheetTitle,
          style: DsfrTextStyle.headline3(color: DsfrColorDecisions.textTitleGrey(context)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          Strings.notificationsBottomSheetContent,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        DsfrButton(
          label: Strings.notificationsBottomSheetButton,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrButton(
          label: Strings.notificationsBottomSheetDismissButton,
          variant: DsfrButtonVariant.tertiaryWithoutBorder,
          size: DsfrComponentSize.md,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
