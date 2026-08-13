import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/demarche/update/update_demarche_actions.dart';
import 'package:pass_emploi_app/features/mon_suivi/mon_suivi_actions.dart';
import 'package:pass_emploi_app/features/mon_suivi/mon_suivi_state.dart';
import 'package:pass_emploi_app/pages/demarche/demarche_detail_bottom_sheet.dart';
import 'package:pass_emploi_app/pages/demarche/demarche_done_bottom_sheet.dart';
import 'package:pass_emploi_app/presentation/demarche/demarche_detail_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/confetti_wrapper.dart';
import 'package:pass_emploi_app/widgets/connectivity_widgets.dart';
import 'package:pass_emploi_app/widgets/date_echeance_in_detail.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';
import 'package:pass_emploi_app/widgets/loading_overlay.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';

class DemarcheDetailPage extends StatelessWidget {
  final String id;

  DemarcheDetailPage._(this.id);

  static Future<void> show(BuildContext context, String id) {
    return showDsfrBottomSheet(
      context: context,
      name: AnalyticsScreenNames.userActionDetails,
      builder: (context) => DemarcheDetailPage._(id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.userActionDetails,
      child: ConfettiWrapper(
        builder: (context, confettiController) {
          return StoreConnector<AppState, DemarcheDetailViewModel>(
            onInit: (store) {
              final monSuiviState = store.state.monSuiviState;
              if (monSuiviState is! MonSuiviSuccessState) {
                store.dispatch(MonSuiviRequestAction(MonSuiviPeriod.current));
              }
            },
            converter: (store) => DemarcheDetailViewModel.create(store, id),
            onDidChange: (oldViewModel, newViewModel) async {
              if (newViewModel.updateDisplayState == DisplayState.FAILURE) {
                showSnackBarWithSystemError(context, Strings.updateStatusError);
                newViewModel.resetUpdateStatus();
              }
            },
            onDispose: (store) => store.dispatch(UpdateDemarcheResetAction()),
            builder: (context, viewModel) =>
                _Sheet(viewModel, id, confettiController),
            distinct: true,
          );
        },
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet(this.viewModel, this.demarcheId, this.confettiController);

  final DemarcheDetailViewModel viewModel;
  final String demarcheId;
  final ConfettiController confettiController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DsfrBottomSheet(
          leading: DsfrBottomSheetMoreActionsButton(
            onPressed: () =>
                DemarcheDetailsBottomSheet.show(context, demarcheId),
          ),
          actions: viewModel.withDemarcheDoneButton
              ? DsfrButton(
                  label: Strings.demarcheDoneButton,
                  icon: DsfrIcons.systemArrowRightLine,
                  iconLocation: DsfrButtonIconLocation.right,
                  variant: DsfrButtonVariant.primary,
                  size: DsfrComponentSize.md,
                  onPressed: () async {
                    final result = await DemarcheDoneBottomSheet.show(
                      context,
                      demarcheId,
                    );
                    if (result == true) {
                      confettiController.play();
                    }
                  },
                )
              : null,
          child: _Body(viewModel),
        ),
        if (viewModel.updateDisplayState == DisplayState.LOADING)
          Positioned.fill(child: LoadingOverlay()),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  final DemarcheDetailViewModel viewModel;

  const _Body(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (viewModel.withOfflineBehavior) ConnectivityBandeau(),
        if (viewModel.withDateDerniereMiseAJour != null) ...[
          DsfrAlert(
            type: DsfrAlertType.info,
            description: DsfrAlertDescriptionText(
              viewModel.withDateDerniereMiseAJour!,
            ),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
        ],
        if (viewModel.label != null && viewModel.pillule != null) ...[
          Wrap(
            spacing: DsfrSpacings.s1w,
            runSpacing: DsfrSpacings.s1w,
            children: [
              DsfrCategoryTag.emploiCategory(label: viewModel.label!),
              DsfrStatusBadge.fromPillule(
                pillule: viewModel.pillule!,
                forDemarche: true,
                excludeSemantics: true,
              ),
            ],
          ),
        ],
        if (viewModel.titreDetail != null) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          Semantics(
            header: true,
            child: Text(
              viewModel.titreDetail!,
              style: DsfrTextStyle.headline5(
                color: DsfrColorDecisions.textTitleGrey(context),
              ),
            ),
          ),
        ],
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          Strings.demarcheDetails,
          style: DsfrTextStyle.bodyMdBold(
            color: DsfrColorDecisions.textTitleGrey(context),
          ),
        ),
        if (viewModel.promptIa != null) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          Text(
            viewModel.promptIa!,
            style: DsfrTextStyle.bodyMd(
              color: DsfrColorDecisions.textDefaultGrey(context),
            ),
          ),
        ],
        if (viewModel.attributs.isNotEmpty) ...[
          const SizedBox(height: DsfrSpacings.s2w),
          _Attributs(viewModel.attributs),
        ],
        const SizedBox(height: DsfrSpacings.s2w),
        DateEcheanceInDetail(
          icons: viewModel.dateIcons,
          formattedTexts: viewModel.dateFormattedTexts,
          backgroundColor: viewModel.dateBackgroundColor,
          textColor: viewModel.dateTextColor,
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Divider(
          height: 1,
          color: DsfrColorDecisions.borderDefaultGrey(context),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        Text(
          Strings.historiqueDemarche,
          style: DsfrTextStyle.bodyMdBold(
            color: DsfrColorDecisions.textTitleGrey(context),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        _Historique(viewModel),
      ],
    );
  }
}

class _Attributs extends StatelessWidget {
  final List<String> attributs;

  const _Attributs(this.attributs);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: attributs.map((e) => _AttributItem(e)).toList(),
    );
  }
}

class _AttributItem extends StatelessWidget {
  final String label;

  const _AttributItem(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DsfrSpacings.s2w),
      child: DsfrDetailIconLine(icon: DsfrIcons.mapMapPin2Line, text: label),
    );
  }
}

class _Historique extends StatelessWidget {
  final DemarcheDetailViewModel viewModel;

  const _Historique(this.viewModel);

  @override
  Widget build(BuildContext context) {
    final titleStyle = DsfrTextStyle.bodyMd(
      color: DsfrColorDecisions.textDefaultGrey(context),
    );
    final boldStyle = DsfrTextStyle.bodyMdBold(
      color: DsfrColorDecisions.textTitleGrey(context),
    );
    return Container(
      padding: const EdgeInsets.only(left: DsfrSpacings.s2w),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: DsfrColorDecisions.borderDefaultGrey(context),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (viewModel.modificationDate != null)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: Strings.modifiedBy, style: titleStyle),
                  TextSpan(text: viewModel.modificationDate, style: boldStyle),
                  if (viewModel.modifiedByAdvisor)
                    TextSpan(text: Strings.par, style: titleStyle),
                  if (viewModel.modifiedByAdvisor)
                    TextSpan(text: Strings.votreConseiller, style: boldStyle),
                ],
              ),
            ),
          if (viewModel.creationDate != null)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: Strings.createdBy, style: titleStyle),
                  TextSpan(text: viewModel.creationDate, style: boldStyle),
                  if (viewModel.createdByAdvisor)
                    TextSpan(text: Strings.par, style: titleStyle),
                  if (viewModel.createdByAdvisor)
                    TextSpan(text: Strings.votreConseiller, style: boldStyle),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
