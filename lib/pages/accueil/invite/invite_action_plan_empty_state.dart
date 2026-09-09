import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/accueil/invite_accueil_view_model.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class InviteActionPlanEmptyState extends StatelessWidget {
  const InviteActionPlanEmptyState({
    super.key,
    required this.kind,
    required this.showRetry,
    required this.showModifier,
    required this.onRetry,
    required this.onModifier,
  });

  final InvitePlanEmptyKind kind;
  final bool showRetry;
  final bool showModifier;
  final VoidCallback onRetry;
  final VoidCallback onModifier;

  @override
  Widget build(BuildContext context) {
    final isFailure = kind == InvitePlanEmptyKind.failure;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsfrAlert(
          type: isFailure ? DsfrAlertType.warning : DsfrAlertType.info,
          title: isFailure ? Strings.inviteAccueilPlanFailureTitle : Strings.inviteAccueilPlanEmptyTitle,
          description: DsfrAlertDescriptionText(
            isFailure ? Strings.inviteAccueilPlanFailureBody : Strings.inviteAccueilPlanEmptyBody,
          ),
        ),
        if (showRetry) ...[
          const SizedBox(height: Margins.spacing_base),
          DsfrButton(
            label: Strings.inviteAccueilRetryPlan,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: onRetry,
          ),
        ] else if (showModifier) ...[
          const SizedBox(height: Margins.spacing_base),
          DsfrButton(
            label: Strings.inviteAccueilModifier,
            icon: DsfrIcons.designEditLine,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: onModifier,
          ),
        ],
      ],
    );
  }
}
