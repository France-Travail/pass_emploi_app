import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

class OffreDetailsAction {
  const OffreDetailsAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = DsfrButtonVariant.primary,
    this.semanticsLink = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final DsfrButtonVariant variant;
  final bool semanticsLink;
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
    return Semantics(
      link: action.semanticsLink,
      child: SizedBox(width: double.infinity, child: button),
    );
  }
}
