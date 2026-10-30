import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/accueil/accueil_item.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_dismissible_tile.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_tuile_card.dart';

class RemoteCampagneAccueilCard extends StatelessWidget {
  const RemoteCampagneAccueilCard(this.item);
  final RemoteCampagneAccueilItem item;

  @override
  Widget build(BuildContext context) {
    return DsfrDismissibleTile(
      title: item.title,
      description: item.cta,
      leading: DsfrTuileCardIcon(icon: DsfrIcons.systemExternalLinkLine),
      onTap: () {
        PassEmploiMatomoTracker.instance.trackOutlink(item.url);
        launchExternalUrl(item.url);
      },
      onDismiss: item.onDismissed,
      dismissSemanticLabel: "${Strings.closeDialog} ${item.title}",
      semanticsLink: true,
    );
  }
}
