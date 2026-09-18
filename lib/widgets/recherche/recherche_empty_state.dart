import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';

class RechercheEmptyState<Result> extends StatelessWidget {
  final Widget? Function()? buildAlertBottomSheet;

  const RechercheEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.buildAlertBottomSheet,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DsfrSpacings.s1w, bottom: DsfrSpacings.s3w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              Drawables.illustrationRechercheEmpty,
              width: 212,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          Text(
            title,
            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s1w),
          Text(
            subtitle,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrButton(
            label: Strings.modifierMesCriteres,
            icon: DsfrIcons.designEditLine,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: () => context.dispatch(RechercheOpenCriteresAction<Result>()),
          ),
          if (buildAlertBottomSheet != null) ...[
            const SizedBox(height: DsfrSpacings.s2w),
            DsfrButton(
              label: Strings.createAlert,
              icon: DsfrIcons.mediaNotification3Line,
              variant: DsfrButtonVariant.secondary,
              size: DsfrComponentSize.lg,
              onPressed: () {
                final sheet = buildAlertBottomSheet!();
                if (sheet == null) return;
                showPassEmploiBottomSheet(
                  context: context,
                  builder: (_) => sheet,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
