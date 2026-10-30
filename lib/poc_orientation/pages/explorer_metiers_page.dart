import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/poc_orientation/mes_metiers.dart';
import 'package:pass_emploi_app/poc_orientation/pages/centres_interet_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/fiche_metier_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/test_riasec_page.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_tuile_card.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/metier_autocomplete.dart';

class ExplorerMetiersPage extends StatelessWidget {
  const ExplorerMetiersPage({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const ExplorerMetiersPage());

  @override
  Widget build(BuildContext context) {
    return PocScaffold(
      titre: PocOrientationStrings.hubTitre,
      body: ListView(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: DsfrBadge(
              label: PocOrientationStrings.prototype,
              type: DsfrBadgeType.news,
              size: DsfrComponentSize.sm,
            ),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          Text(
            PocOrientationStrings.hubIntro,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s4w),
          PocSectionTitre(PocOrientationStrings.hubMetierEnTete),
          const SizedBox(height: DsfrSpacings.s2w),
          MetierAutocomplete(
            title: PocOrientationStrings.hubMetierChamp,
            hint: PocOrientationStrings.hubMetierAide,
            onMetierSelected: (metier) {
              if (metier == null) return;
              Navigator.push(
                context,
                FicheMetierPage.route(RomeMetierResume(code: metier.codeRome, libelle: metier.libelle)),
              );
            },
          ),
          const SizedBox(height: DsfrSpacings.s4w),
          PocSectionTitre(PocOrientationStrings.hubPasEncore),
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrTuileCard(
            leading: const DsfrTuileCardIcon(icon: DsfrIcons.othersLightbulbLine),
            title: PocOrientationStrings.hubTestTitre,
            description: PocOrientationStrings.hubTestDescription,
            onTap: () => Navigator.push(context, TestRiasecPage.route()),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrTuileCard(
            leading: const DsfrTuileCardIcon(icon: DsfrIcons.userUserHeartLine),
            title: PocOrientationStrings.hubCentresTitre,
            description: PocOrientationStrings.hubCentresDescription,
            onTap: () => Navigator.push(context, CentresInteretPage.route()),
          ),
          const SizedBox(height: DsfrSpacings.s4w),
          PocSectionTitre(PocOrientationStrings.hubMesMetiers),
          const SizedBox(height: DsfrSpacings.s1w),
          ValueListenableBuilder<List<RomeMetierResume>>(
            valueListenable: MesMetiers.instance,
            builder: (context, metiers, _) {
              if (metiers.isEmpty) {
                return Text(
                  PocOrientationStrings.hubMesMetiersVide,
                  style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final metier in metiers) PocMetierTuile(metier: metier)],
              );
            },
          ),
          const SizedBox(height: DsfrSpacings.s4w),
          PocMention(PocOrientationStrings.sourceRome),
        ],
      ),
    );
  }
}
