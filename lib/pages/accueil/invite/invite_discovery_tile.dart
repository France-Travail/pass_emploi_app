import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/pages/onboarding_page.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class InviteDiscoveryTile extends StatelessWidget {
  const InviteDiscoveryTile({
    super.key,
    required this.progressPercent,
    required this.isCompleted,
    required this.onHide,
  });

  final int progressPercent;
  final bool isCompleted;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final title = isCompleted ? Strings.onboardingAccueilTitleCompleted : Strings.inviteAccueilDiscoveryTitle;
    // A11y : un seul nœud bouton dont le nom reflète l'action (ouvrir la découverte ou la masquer).
    return Semantics(
      container: true,
      button: true,
      label: [
        Strings.inviteAccueilDiscoveryProgressA11y(progressPercent),
        title,
        if (isCompleted) Strings.inviteAccueilDiscoveryHideA11y,
      ].join(', '),
      onTap: () => _onTap(context),
      excludeSemantics: true,
      child: Material(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: () => _onTap(context),
          borderRadius: BorderRadius.circular(4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: DsfrColorDecisions.borderActionHighBlueFrance(context)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Margins.spacing_base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DsfrBadge(
                    label: Strings.inviteAccueilDiscoveryProgress(progressPercent),
                    type: DsfrBadgeType.news,
                    size: DsfrComponentSize.sm,
                    withIcon: true,
                  ),
                  const SizedBox(height: Margins.spacing_s),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                        ),
                      ),
                      Icon(
                        isCompleted ? DsfrIcons.systemCloseLine : DsfrIcons.systemArrowRightSLine,
                        color: DsfrColorDecisions.textTitleBlueFrance(context),
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    if (isCompleted) {
      onHide();
    } else {
      Navigator.of(context).push(OnboardingPage.route());
    }
  }
}
