import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class DsfrDismissibleTile extends StatelessWidget {
  const DsfrDismissibleTile({
    super.key,
    required this.title,
    this.description,
    this.imageAsset,
    this.actionIcon = DsfrIcons.systemArrowRightLine,
    this.semanticsLink = false,
    required this.onTap,
    required this.onDismiss,
    required this.dismissSemanticLabel,
  });

  final String title;
  final String? description;
  final String? imageAsset;
  final IconData actionIcon;
  final bool semanticsLink;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final String dismissSemanticLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Semantics(
          button: !semanticsLink,
          link: semanticsLink,
          label: [
            title,
            if (description != null) description!,
            if (semanticsLink) Strings.openInNewTab,
          ].join('. '),
          onTap: onTap,
          child: ExcludeSemantics(
            child: DsfrTile(
              size: DsfrComponentSize.sm,
              direction: Axis.horizontal,
              title: title,
              description: description,
              imageAsset: imageAsset,
              actionIcon: actionIcon,
              onTap: onTap,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: DsfrButton(
            icon: DsfrIcons.systemCloseLine,
            iconSemanticLabel: dismissSemanticLabel,
            variant: DsfrButtonVariant.tertiaryWithoutBorder,
            size: DsfrComponentSize.sm,
            onPressed: onDismiss,
          ),
        ),
      ],
    );
  }
}
