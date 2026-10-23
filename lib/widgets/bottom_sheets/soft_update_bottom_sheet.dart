import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/presentation/soft_update_bottom_sheet_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/utils/platform.dart';

class SoftUpdateBottomSheet extends StatelessWidget {
  const SoftUpdateBottomSheet({super.key});

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
      builder: (context) => Theme(
        data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
        child: DsfrModal(
          isDismissible: true,
          closeLabel: Strings.close,
          child: const SoftUpdateBottomSheet(),
        ),
      ),
    ).then((didDownload) {
      if (!context.mounted) return;
      final store = StoreProvider.of<AppState>(context);
      final viewModel = SoftUpdateBottomSheetViewModel.create(
        store,
        PlatformUtils.getPlatform,
      );
      if (didDownload == true) {
        PassEmploiMatomoTracker.instance.trackEvent(
          eventCategory: AnalyticsEventNames.softUpdateCategory,
          action: AnalyticsEventNames.softUpdateDownload,
        );
        viewModel.onDownload?.call();
      } else {
        PassEmploiMatomoTracker.instance.trackEvent(
          eventCategory: AnalyticsEventNames.softUpdateCategory,
          action: AnalyticsEventNames.softUpdateDismiss,
        );
        viewModel.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SoftUpdateBottomSheetViewModel>(
      converter: (store) => SoftUpdateBottomSheetViewModel.create(
        store,
        PlatformUtils.getPlatform,
      ),
      builder: (context, viewModel) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              viewModel.title,
              style: DsfrTextStyle.headline4(
                color: DsfrColorDecisions.textTitleGrey(context),
              ),
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            Text(
              viewModel.subtitle,
              style: DsfrTextStyle.bodyMd(
                color: DsfrColorDecisions.textDefaultGrey(context),
              ),
            ),
            const SizedBox(height: DsfrSpacings.s4w),
            DsfrButton(
              label: viewModel.downloadLabel,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.lg,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            DsfrButton(
              label: viewModel.closeLabel,
              variant: DsfrButtonVariant.tertiaryWithoutBorder,
              size: DsfrComponentSize.md,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        );
      },
    );
  }
}
