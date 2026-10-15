import 'package:flutter/material.dart';
import 'package:pass_emploi_app/widgets/a11y/external_link_semantics.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_tuile_card.dart';

class DsfrDismissibleTile extends StatelessWidget {
  const DsfrDismissibleTile({
    super.key,
    required this.title,
    this.description,
    this.leading,
    required this.onTap,
    required this.onDismiss,
    required this.dismissSemanticLabel,
    this.semanticsLink = false,
    this.semanticsLinkDestination = LinkDestination.website,
  });

  final String title;
  final String? description;
  final Widget? leading;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final String dismissSemanticLabel;
  final bool semanticsLink;
  final LinkDestination semanticsLinkDestination;

  @override
  Widget build(BuildContext context) {
    return DsfrTuileCard(
      leading: leading ?? const SizedBox.shrink(),
      title: title,
      description: description,
      onTap: onTap,
      onDismiss: onDismiss,
      dismissSemanticLabel: dismissSemanticLabel,
      semanticsLink: semanticsLink,
      semanticsLinkDestination: semanticsLinkDestination,
    );
  }
}
