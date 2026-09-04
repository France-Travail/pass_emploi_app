import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/comptage_des_heures/comptage_des_heures_actions.dart';
import 'package:pass_emploi_app/presentation/comptage_des_heures_card_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class ComptageDesHeuresCard extends StatelessWidget {
  const ComptageDesHeuresCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ComptageDesHeuresCardViewModel>(
      converter: (store) => ComptageDesHeuresCardViewModel.create(store),
      onInit: (store) => store.dispatch(ComptageDesHeuresRequestAction()),
      distinct: true,
      builder: (context, viewModel) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: DsfrColorDecisions.backgroundDefaultGrey(context),
            borderRadius: BorderRadius.circular(DsfrSpacings.s1w),
            border: Border.all(color: DsfrColorDecisions.borderActionHighBlueFrance(context)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DsfrSpacings.s2w),
            child: switch (viewModel.displayState) {
              DisplayState.CONTENT => _Content(viewModel: viewModel),
              DisplayState.LOADING => const Center(child: CircularProgressIndicator()),
              DisplayState.FAILURE => Column(
                children: [
                  Text(
                    Strings.comptageDesHeuresError,
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DsfrSpacings.s1w),
                  DsfrButton(
                    label: Strings.retry,
                    icon: DsfrIcons.systemRefreshLine,
                    variant: DsfrButtonVariant.secondary,
                    size: DsfrComponentSize.sm,
                    onPressed: viewModel.retry,
                  ),
                ],
              ),
              DisplayState.EMPTY => const SizedBox.shrink(),
            },
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.viewModel});

  final ComptageDesHeuresCardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (viewModel.heuresEnCoursDeCalcul != null) ...[
          Text(
            viewModel.heuresEnCoursDeCalcul!,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textTitleGrey(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DsfrSpacings.s3v),
        ],
        Text(
          viewModel.title,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DsfrSpacings.s3v),
        Row(
          children: [
            Expanded(
              child: _HourStat(
                hours: '${viewModel.heuresDeclarees}h',
                label: Strings.declaredHours,
                type: DsfrBadgeType.information,
              ),
            ),
            const SizedBox(width: DsfrSpacings.s1v),
            Expanded(
              child: _HourStat(
                hours: '${viewModel.heuresValidees}h',
                label: Strings.realizedHours,
                type: DsfrBadgeType.success,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HourStat extends StatelessWidget {
  const _HourStat({
    required this.hours,
    required this.label,
    required this.type,
  });

  final String hours;
  final String label;
  final DsfrBadgeType type;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DsfrBadge(
          label: hours,
          type: type,
          size: DsfrComponentSize.md,
        ),
        const SizedBox(width: DsfrSpacings.s3v),
        Flexible(
          child: Text(
            label,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
      ],
    );
  }
}
