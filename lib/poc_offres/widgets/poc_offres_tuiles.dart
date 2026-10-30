import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/poc_offres/pages/alternance_page.dart';
import 'package:pass_emploi_app/poc_offres/pages/benevolat_page.dart';
import 'package:pass_emploi_app/poc_offres/pages/formation_pages.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_criteres_utilisateur.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_strings.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/widgets/dsfr/emoji_solution_tile.dart';

// Tuiles ajoutées à « Explorer par type » en mode démo seulement (choix de Steph du 30/10 : l'alternance
// actuelle, branchée sur France Travail, reste à côté).
List<Widget> pocOffresTuiles(BuildContext context) {
  PocCriteresInitiaux initiaux() => PocCriteresInitiaux.depuis(StoreProvider.of<AppState>(context, listen: false));
  return [
    EmojiSolutionTile(
      emoji: PocOffresStrings.tuileBenevolatEmoji,
      emojiBackground: DsfrColors.pinkMacaron950,
      title: PocOffresStrings.tuileBenevolatTitre,
      subtitle: PocOffresStrings.tuileBenevolatSousTitre,
      onTap: () => Navigator.push(context, BenevolatRecherchePage.route(initiaux())),
    ),
    EmojiSolutionTile(
      emoji: PocOffresStrings.tuileFormationEmoji,
      emojiBackground: DsfrColors.blueCumulus950,
      title: PocOffresStrings.tuileFormationTitre,
      subtitle: PocOffresStrings.tuileFormationSousTitre,
      onTap: () => Navigator.push(context, FormationRecherchePage.route(initiaux())),
    ),
    EmojiSolutionTile(
      emoji: PocOffresStrings.tuileAlternanceEmoji,
      emojiBackground: DsfrColors.yellowTournesol950,
      title: PocOffresStrings.tuileAlternanceTitre,
      subtitle: PocOffresStrings.tuileAlternanceSousTitre,
      onTap: () => Navigator.push(context, AlternanceRecherchePage.route(initiaux())),
    ),
  ];
}
