import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/pages/demarche/demarche_detail_bottom_sheet.dart';
import 'package:pass_emploi_app/presentation/demarche/demarche_card_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_card_semantics.dart';

class DemarcheCard extends StatelessWidget {
  final String demarcheId;
  final Function() onTap;

  const DemarcheCard({
    required this.demarcheId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DemarcheCardViewModel>(
      converter: (store) => DemarcheCardViewModel.create(store: store, demarcheId: demarcheId),
      builder: _builder,
      distinct: true,
    );
  }

  Widget _builder(BuildContext context, DemarcheCardViewModel viewModel) {
    final (badgeType, badgeLabel) = viewModel.pillule.toDemarcheDsfrBadge();

    // A11y : to read "Démarche" + category + title + status
    return Semantics(
      label: Strings.accueilDemarcheSingular,
      button: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              onLongPress: () => DemarcheDetailsBottomSheet.show(context, demarcheId),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: DsfrSpacings.s1w,
                    runSpacing: DsfrSpacings.s1w,
                    children: [
                      if (viewModel.categoryText != null)
                        DsfrCategoryTag.emploiCategory(label: viewModel.categoryText!),
                      DsfrStatusBadge(
                        label: badgeLabel,
                        type: badgeType,
                        excludeSemantics: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: DsfrSpacings.s1w),
                  Text(
                    viewModel.title,
                    style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                ],
              ),
            ),
          ),
          Semantics(label: Strings.a11yStatus + badgeLabel),
        ],
      ),
    );
  }
}
