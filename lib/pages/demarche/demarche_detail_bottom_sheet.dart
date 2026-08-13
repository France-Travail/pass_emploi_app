import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/pages/demarche/duplicate_demarche_page.dart';
import 'package:pass_emploi_app/presentation/demarche/demarche_detail_bottom_sheet_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_sheet.dart';

class DemarcheDetailsBottomSheet extends StatelessWidget {
  const DemarcheDetailsBottomSheet({required this.demarcheId});
  final String demarcheId;

  static Future<void> show(BuildContext context, String demarcheId) {
    return showDsfrBottomSheet(
      context: context,
      name: AnalyticsScreenNames.userActionDetails,
      builder: (context) => DemarcheDetailsBottomSheet(demarcheId: demarcheId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DemarcheDetailBottomSheetViewModel>(
      converter: (store) =>
          DemarcheDetailBottomSheetViewModel.create(store, demarcheId),
      builder: (context, viewModel) => DsfrBottomSheet(
        shrinkWrap: true,
        leading: DsfrBottomSheetMoreActionsButton(
          onPressed: () => Navigator.pop(context),
        ),
        actions: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DsfrButton(
              label: Strings.duplicate,
              icon: DsfrIcons.documentFileAddLine,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.md,
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.push(DuplicateDemarchePage.route(demarcheId));
              },
            ),
            if (viewModel.withDemarcheCancelButton) ...[
              const SizedBox(height: DsfrSpacings.s2w),
              DsfrButton(
                label: Strings.cancelDemarche,
                icon: DsfrIcons.systemDeleteBinLine,
                variant: DsfrButtonVariant.secondary,
                size: DsfrComponentSize.md,
                foregroundColor: DsfrColorDecisions.textDefaultError(context),
                onPressed: () {
                  viewModel.onDemarcheCancel();
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
