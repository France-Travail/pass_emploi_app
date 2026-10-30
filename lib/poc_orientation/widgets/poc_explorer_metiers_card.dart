import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/poc_orientation/pages/explorer_metiers_page.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_tuile_card.dart';

class PocExplorerMetiersCard extends StatelessWidget {
  const PocExplorerMetiersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DsfrTuileCard(
      leading: const DsfrTuileCardIcon(icon: DsfrIcons.mapCompass3Line),
      title: PocOrientationStrings.carteTitre,
      description: PocOrientationStrings.carteDescription,
      onTap: () => Navigator.push(context, ExplorerMetiersPage.route()),
    );
  }
}
