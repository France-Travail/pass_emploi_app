import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/mode_demo/mode_demo_offline.dart';
import 'package:pass_emploi_app/poc_orientation/donnees_parcours.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pages/centres_interet_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/fiche_metier_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/riasec_resultat_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/test_riasec_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/tri_page.dart';
import 'package:pass_emploi_app/poc_orientation/parcours.dart';
import 'package:pass_emploi_app/poc_orientation/pistes_pour_toi.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/poc_passerelles.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/carte_a_trier.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_tuile_card.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/metier_autocomplete.dart';

// « Trouver des idées », à tout moment : le test, ce que le jeune aime, la recherche. Le test et les centres d'intérêt
// n'ont plus leurs propres listes : leurs métiers rejoignent le tri.
class TrouverDesIdeesPage extends StatefulWidget {
  const TrouverDesIdeesPage({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const TrouverDesIdeesPage());

  @override
  State<TrouverDesIdeesPage> createState() => _TrouverDesIdeesPageState();
}

class _TrouverDesIdeesPageState extends State<TrouverDesIdeesPage> {
  late final Future<DonneesParcours> _donnees;

  @override
  void initState() {
    super.initState();
    ouvrirMesPistes(context);
    _donnees = chargerDonneesParcours(StoreProvider.of<AppState>(context, listen: false).state);
    demanderLesDonneesDuJeune(context);
  }

  @override
  Widget build(BuildContext context) {
    return PocScaffold(
      titre: PocOrientationStrings.ideesTitre,
      body: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) => FutureBuilder<DonneesParcours>(
          future: _donnees,
          builder: (context, snapshot) => ValueListenableBuilder<MesPistesEtat>(
            valueListenable: MesPistes.instance,
            builder: (context, etat, _) {
              final donnees = snapshot.data;
              final List<PisteProposee> aTrier = donnees == null ? const [] : metiersATrier(state, etat, donnees);
              final profil = etat.profilRiasec;
              final aUnProfil = profil != null && !profil.estPlat;
              return ListView(
                padding: const EdgeInsets.all(DsfrSpacings.s2w),
                children: [
                  Text(
                    PocOrientationStrings.ideesIntro,
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                  ),
                  if (aTrier.isNotEmpty) ...[
                    const SizedBox(height: DsfrSpacings.s3w),
                    RappelATrier(
                      texte: PocOrientationStrings.rappelATrier(aTrier.length, voisinsDe(aTrier, etat, donnees?.marche)),
                      onTap: () => Navigator.push(context, TriPage.route()),
                    ),
                  ],
                  const SizedBox(height: DsfrSpacings.s3w),
                  if (aUnProfil) ...[
                    DsfrTuileCard(
                      leading: const DsfrTuileCardIcon(icon: DsfrIcons.userUserLine),
                      title: PocOrientationStrings.ideesProfil(
                        PocOrientationStrings.listeNaturelle(profil.dominants.map((type) => type.nom).toList()),
                      ),
                      description: PocOrientationStrings.ideesRevoir,
                      onTap: () => Navigator.push(context, RiasecResultatPage.route(profil)),
                    ),
                    const SizedBox(height: DsfrSpacings.s2w),
                  ],
                  DsfrTuileCard(
                    leading: const DsfrTuileCardIcon(icon: DsfrIcons.othersLightbulbLine),
                    title: aUnProfil ? PocOrientationStrings.ideesRefaireTest : PocOrientationStrings.ideesTest,
                    description: PocOrientationStrings.ideesTestDetail,
                    onTap: () => Navigator.push(context, TestRiasecPage.route()),
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                  DsfrTuileCard(
                    leading: const DsfrTuileCardIcon(icon: DsfrIcons.userUserHeartLine),
                    title: PocOrientationStrings.ideesCentres,
                    description: etat.centresInteret.isEmpty
                        ? PocOrientationStrings.ideesCentresDetail
                        : PocOrientationStrings.ideesCentresChoisis(etat.centresInteret),
                    onTap: () => Navigator.push(context, CentresInteretPage.route()),
                  ),
                  const SizedBox(height: DsfrSpacings.s4w),
                  PocSectionTitre(PocOrientationStrings.hubMetierEnTete),
                  const SizedBox(height: DsfrSpacings.s1w),
                  Text(
                    PocOrientationStrings.ideesRecherche,
                    style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                  // En démo, le champ « Métier » impose le boulanger et le choisit tout seul : la page sauterait sur sa
                  // fiche dès l'ouverture. On montre donc directement le métier de la démo.
                  if (state.demoState)
                    PocMetierTuile(
                      metier: RomeMetierResume(code: modeDemoMetier.codeRome, libelle: modeDemoMetier.libelle),
                      detail: PocOrientationStrings.hubMetierDemo,
                    )
                  else
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
                  PocMention(PocOrientationStrings.sourceRome),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
