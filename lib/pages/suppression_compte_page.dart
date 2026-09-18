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
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dialogs/delete_user_dialog.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';

class SuppressionComptePage extends StatelessWidget {
  static MaterialPageRoute<void> materialPageRoute() {
    return MaterialPageRoute(builder: (context) => SuppressionComptePage());
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.suppressionAccount,
      child: StoreConnector<AppState, SuppressionCompteViewModel>(
        converter: (store) => SuppressionCompteViewModel.create(store),
        builder: (context, viewModel) => _scaffold(context, viewModel),
        onDidChange: (_, newVM) {
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

  Widget _scaffold(BuildContext context, SuppressionCompteViewModel viewModel) {
    return Scaffold(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      appBar: const BackAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _body(context, viewModel)),
              _DeleteAccountButton(),
            ],
          ),
          if (viewModel.displayState == DisplayState.LOADING)
            Positioned.fill(
              child: ColoredBox(
                color: DsfrColorDecisions.backgroundDefaultGrey(context).withValues(alpha: 0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, SuppressionCompteViewModel viewModel) {
    return Semantics(
      container: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s3w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageTitle(Strings.suppressionPageTitle),
            const SizedBox(height: DsfrSpacings.s2w),
            Semantics(
              header: true,
              child: Text(
                Strings.warning,
                style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            Text(
              Strings.warningInformationParagraph1,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s3w),
            _ListedItems(list: viewModel.warningSuppressionFeatures),
            const SizedBox(height: DsfrSpacings.s3w),
            Text(
              Strings.warningInformationParagraph2,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
            if (viewModel.isPoleEmploiLogin) ...[
              const SizedBox(height: DsfrSpacings.s3w),
              Text(
                Strings.warningInformationPoleEmploi,
                style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ],
            const SizedBox(height: DsfrSpacings.s3w),
            const DsfrDivider(),
          ],
        ),
      ),
    );
  }
}

class _ListedItems extends StatelessWidget {
  final List<String> list;

  const _ListedItems({required this.list});

  @override
  Widget build(BuildContext context) {
    final textStyle = DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in list)
          Padding(
            padding: const EdgeInsets.only(left: DsfrSpacings.s3w, bottom: DsfrSpacings.s1v),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(child: Text('•', style: textStyle)),
                const SizedBox(width: DsfrSpacings.s1w),
                Expanded(child: Text(item, style: textStyle)),
              ],
            ),
          ),
      ],
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: DsfrSpacings.s5w),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
        child: SizedBox(
          width: double.infinity,
          child: DsfrButton(
            label: Strings.suppressionButtonLabel,
            icon: DsfrIcons.systemDeleteBinLine,
            variant: DsfrButtonVariant.secondary,
            size: DsfrComponentSize.lg,
            foregroundColor: DsfrColorDecisions.textDefaultError(context),
            onPressed: () => DeleteAlertDialog.show(context),
          ),
        ),
      ),
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
        data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
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
