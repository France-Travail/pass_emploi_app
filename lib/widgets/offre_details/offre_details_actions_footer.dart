import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/widgets/a11y/external_link_semantics.dart';

class OffreDetailsAction {
  const OffreDetailsAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = DsfrButtonVariant.primary,
    this.semanticsLink = false,
    this.semanticsLinkDestination = LinkDestination.website,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final DsfrButtonVariant variant;
  final bool semanticsLink;
  final LinkDestination semanticsLinkDestination;
}

class OffreDetailsActionsFooter extends StatelessWidget {
  const OffreDetailsActionsFooter({
    super.key,
    required this.actions,
  });

  final List<OffreDetailsAction> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Material(
      color: DsfrColorDecisions.backgroundDefaultGrey(context),
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, DsfrSpacings.s1w, DsfrSpacings.s2w, DsfrSpacings.s2w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(height: DsfrSpacings.s2w),
                _ActionButton(action: actions[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action});

  final OffreDetailsAction action;

  @override
  Widget build(BuildContext context) {
    final button = DsfrButton(
      label: action.label,
      icon: action.icon,
      variant: action.variant,
      size: DsfrComponentSize.lg,
      onPressed: action.onPressed,
    );
    if (!action.semanticsLink) return SizedBox(width: double.infinity, child: button);
    // A11y 5.1 : DsfrButton expose toujours un rôle bouton ; on le remplace par un rôle lien unique
    // (bouton + indication de site externe sur Android, où le rôle lien n'est pas annoncé).
    return ExternalLinkSemantics(
      label: action.label,
      onTap: action.onPressed,
      destination: action.semanticsLinkDestination,
      child: SizedBox(width: double.infinity, child: button),
    );
  }
}
