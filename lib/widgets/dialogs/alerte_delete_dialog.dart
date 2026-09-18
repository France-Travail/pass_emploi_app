import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/alerte/delete/alerte_delete_actions.dart';
import 'package:pass_emploi_app/presentation/alerte/alerte_delete_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';

enum AlerteType { EMPLOI, ALTERNANCE, IMMERSION, SERVICE_CIVIQUE }

class AlerteDeleteDialog extends StatelessWidget {
  final String alerteId;
  final AlerteType type;

  const AlerteDeleteDialog._(this.alerteId, this.type);

  static Future<bool?> show(BuildContext context, String alerteId, AlerteType type) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: DsfrColorDecisions.backgroundTransparent(context),
      barrierColor: DsfrColorDecisions.backgroundOverlayGrey(context),
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      isScrollControlled: true,
      useSafeArea: true,
      routeSettings: RouteSettings(name: _screenName(type)),
      builder: (context) => Theme(
        data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
        child: DsfrModal(
          isDismissible: true,
          closeLabel: Strings.close,
          child: AlerteDeleteDialog._(alerteId, type),
        ),
      ),
    );
  }

  static String _screenName(AlerteType type) {
    return switch (type) {
      AlerteType.EMPLOI => AnalyticsScreenNames.alerteEmploiDelete,
      AlerteType.ALTERNANCE => AnalyticsScreenNames.alerteAlternanceDelete,
      AlerteType.IMMERSION => AnalyticsScreenNames.alerteImmersionDelete,
      AlerteType.SERVICE_CIVIQUE => AnalyticsScreenNames.alerteServiceCiviqueDelete
    };
  }

  static String _actionName(AlerteType type) {
    return switch (type) {
      AlerteType.EMPLOI => AnalyticsActionNames.deleteAlerteEmploi,
      AlerteType.ALTERNANCE => AnalyticsActionNames.deleteAlerteAlternance,
      AlerteType.IMMERSION => AnalyticsActionNames.deleteAlerteImmersion,
      AlerteType.SERVICE_CIVIQUE => AnalyticsActionNames.deleteAlerteServiceCivique
    };
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: _screenName(type),
      child: StoreConnector<AppState, AlerteDeleteViewModel>(
        converter: (store) => AlerteDeleteViewModel.create(store),
        builder: (context, vm) {
          final isLoading = vm.displayState == AlerteDeleteDisplayState.LOADING;
          final hasError = vm.displayState == AlerteDeleteDisplayState.FAILURE;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                Strings.alerteDeleteMessageTitle,
                style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              Text(
                Strings.alerteDeleteMessageSubtitle,
                style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
              ),
              if (hasError) ...[
                const SizedBox(height: DsfrSpacings.s2w),
                DsfrAlert(
                  type: DsfrAlertType.error,
                  description: DsfrAlertDescriptionText(Strings.alerteDeleteError),
                ),
              ],
              const SizedBox(height: DsfrSpacings.s4w),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
                  ),
                )
              else ...[
                DsfrButton(
                  label: Strings.suppressionLabel,
                  variant: DsfrButtonVariant.primary,
                  size: DsfrComponentSize.lg,
                  onPressed: () => vm.onDeleteConfirm(alerteId),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
                DsfrButton(
                  label: Strings.cancelLabel,
                  variant: DsfrButtonVariant.secondary,
                  size: DsfrComponentSize.lg,
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ],
          );
        },
        onWillChange: (_, viewModel) {
          if (viewModel.displayState == AlerteDeleteDisplayState.SUCCESS) {
            PassEmploiMatomoTracker.instance.trackScreen(_actionName(type));
            Navigator.pop(context, true);
          }
        },
        distinct: true,
        onDispose: (store) => store.dispatch(AlerteDeleteResetAction()),
      ),
    );
  }
}
