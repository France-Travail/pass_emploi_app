import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/profil/suppression_compte_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/theme.dart';
import 'package:pass_emploi_app/widgets/a11y/a11y_bullet_list.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dialogs/delete_user_dialog.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';

class SuppressionComptePage extends StatelessWidget {
  static Future<void> show(BuildContext context) {
    return showDsfrBottomSheet<void>(
      context: context,
      name: AnalyticsScreenNames.suppressionAccount,
      builder: (context) => SuppressionComptePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.suppressionAccount,
      child: StoreConnector<AppState, SuppressionCompteViewModel>(
        converter: (store) => SuppressionCompteViewModel.create(store),
        builder: (context, viewModel) => _sheet(context, viewModel),
        onDidChange: (_, newVM) {
          if (!context.mounted) return;
          if (newVM.displayState == DisplayState.FAILURE) {
            showSnackBarWithSystemError(context, Strings.alerteDeleteError);
          } else if (newVM.displayState == DisplayState.CONTENT) {
            _DeleteAccountSuccessDialog.show(context);
          }
        },
        distinct: true,
      ),
    );
  }

  Widget _sheet(BuildContext context, SuppressionCompteViewModel viewModel) {
    final isLoading = viewModel.displayState == DisplayState.LOADING;
    return Stack(
      children: [
        DsfrBottomSheet(
          actions: _Actions(confirmLabel: viewModel.confirmLabel),
          child: _body(context, viewModel),
        ),
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: DsfrColorDecisions.backgroundDefaultGrey(context).withValues(alpha: 0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _body(BuildContext context, SuppressionCompteViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageTitle(viewModel.title),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          viewModel.introduction,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        A11yBulletList(items: viewModel.warningSuppressionFeatures),
        if (viewModel.accompagnementNotice != null) ...[
          const SizedBox(height: DsfrSpacings.s3w),
          Text(
            viewModel.accompagnementNotice!,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ],
        if (viewModel.poleEmploiNotice != null) ...[
          const SizedBox(height: DsfrSpacings.s3w),
          Text(
            viewModel.poleEmploiNotice!,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ],
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.confirmLabel});

  final String confirmLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsfrButton(
          label: confirmLabel,
          icon: DsfrIcons.systemDeleteBinLine,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          foregroundColor: DsfrColorDecisions.textDefaultError(context),
          onPressed: () => DeleteAlertDialog.show(context),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: Strings.cancelLabel,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class _DeleteAccountSuccessDialog extends StatelessWidget {
  const _DeleteAccountSuccessDialog();

  static Future<void> show(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: DsfrColorDecisions.backgroundTransparent(context),
      barrierColor: DsfrColorDecisions.backgroundOverlayGrey(context),
      barrierLabel: Strings.bottomSheetBarrierLabel,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Theme(
        data: isDarkMode ? PassEmploiTheme.darkData : PassEmploiTheme.data,
        child: DsfrModal(
          isDismissible: true,
          closeLabel: Strings.close,
          child: const _DeleteAccountSuccessDialog(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SvgPicture.asset(
            Drawables.illustrationSuccess,
            width: 80,
            height: 80,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        Text(
          Strings.accountDeletionSuccess,
          style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        DsfrButton(
          label: Strings.close,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
