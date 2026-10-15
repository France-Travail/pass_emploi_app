import 'package:flutter/material.dart';
import 'package:pass_emploi_app/widgets/a11y/external_link_semantics.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_profil_card.dart';

class DsfrProfilTile extends StatelessWidget {
  const DsfrProfilTile({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    this.description,
    this.onTap,
    this.showChevron,
    this.semanticsLink = false,
    this.semanticsLinkDestination = LinkDestination.website,
    this.semanticsLabel,
  });

  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String? description;
  final VoidCallback? onTap;
  final bool? showChevron;
  final bool semanticsLink;
  final LinkDestination semanticsLinkDestination;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return DsfrProfilCard(
      leading: DsfrProfilCardIcon(icon: icon, backgroundColor: iconBackgroundColor),
      title: title,
      description: description,
      onTap: onTap,
      showChevron: showChevron,
      semanticsLink: semanticsLink,
      semanticsLinkDestination: semanticsLinkDestination,
      semanticsLabel: semanticsLabel,
    );
  }
}
