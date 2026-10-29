import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/presentation/comptage_des_heures_card_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';

class ComptageDesHeuresCard extends StatelessWidget {
  const ComptageDesHeuresCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ComptageDesHeuresCardViewModel>(
      converter: (store) => ComptageDesHeuresCardViewModel.create(store),
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
                semanticsLabel: Strings.a11yHeuresRealisees(viewModel.heuresDeclarees),
                type: DsfrBadgeType.information,
              ),
            ),
            const SizedBox(width: DsfrSpacings.s1v),
            Expanded(
              child: _HourStat(
                hours: '${viewModel.heuresValidees}h',
                label: Strings.realizedHours,
                semanticsLabel: Strings.a11yHeuresValidees(viewModel.heuresValidees),
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
    required this.semanticsLabel,
    required this.type,
  });

  final String hours;
  final String label;
  final String semanticsLabel;
  final DsfrBadgeType type;

  @override
  Widget build(BuildContext context) {
    final badge = DsfrBadge(
      label: hours,
      type: type,
      size: DsfrComponentSize.md,
    );
    final text = Text(
      label,
      style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
    );

    // A11y 8.2 : texte agrandi, le libellé passe sous le badge pour que les mots ne soient pas coupés.
    final content = A11yUtils.withTextScale(context)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              badge,
              const SizedBox(height: DsfrSpacings.s1v),
              // Le mot est réduit si besoin plutôt que coupé.
              FittedBox(fit: BoxFit.scaleDown, child: text),
            ],
          )
        : Row(
            children: [
              badge,
              const SizedBox(width: DsfrSpacings.s3v),
              Flexible(child: text),
            ],
          );

    // A11y : une seule annonce par statistique (ex. « 20 heures réalisées »).
    return Semantics(
      container: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: content,
    );
  }
}
