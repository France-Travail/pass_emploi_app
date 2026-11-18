import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/mode_demo/mode_demo_offline.dart';
import 'package:pass_emploi_app/poc_orientation/contexte_jeune.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pages/centres_interet_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/fiche_metier_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/riasec_resultat_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/test_riasec_page.dart';
import 'package:pass_emploi_app/poc_orientation/partage_conseiller.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/poc_passerelles.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/pistes_pour_toi_widgets.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_tuile_card.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/metier_autocomplete.dart';

class ExplorerMetiersPage extends StatefulWidget {
  const ExplorerMetiersPage({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const ExplorerMetiersPage());

  @override
  State<ExplorerMetiersPage> createState() => _ExplorerMetiersPageState();
}

class _ExplorerMetiersPageState extends State<ExplorerMetiersPage> {
  @override
  void initState() {
    super.initState();
    ouvrirMesPistes(context);
  }

  @override
  Widget build(BuildContext context) {
    return PocScaffold(
      titre: PocOrientationStrings.hubTitre,
      body: ValueListenableBuilder<MesPistesEtat>(
        valueListenable: MesPistes.instance,
        builder: (context, etat, _) {
          // Dès qu'il a des pistes, le jeune les retrouve en premier.
          final pistesEnHaut = etat.pistes.isNotEmpty;
          final profil = etat.profilRiasec;
          return ListView(
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
              if (pistesEnHaut) ...[
                const SizedBox(height: DsfrSpacings.s4w),
                _MesPistes(etat: etat),
              ],
              const PistesPourToi(),
              const SizedBox(height: DsfrSpacings.s4w),
              PocSectionTitre(PocOrientationStrings.hubMetierEnTete),
              const SizedBox(height: DsfrSpacings.s2w),
              // En démo, le champ « Métier » impose le boulanger et le choisit tout seul : la page sauterait sur sa
              // fiche dès l'ouverture. On montre donc directement le métier de la démo.
              if (StoreProvider.of<AppState>(context).state.demoState)
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
              PocSectionTitre(PocOrientationStrings.hubPasEncore),
              const SizedBox(height: DsfrSpacings.s2w),
              if (_aReponduNePasSavoir(context)) ...[
                Text(
                  PocOrientationStrings.hubPasEncoreQuestionnaire,
                  style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
              ],
              if (profil != null && !profil.estPlat) ...[
                DsfrTuileCard(
                  leading: const DsfrTuileCardIcon(icon: DsfrIcons.userUserLine),
                  title: PocOrientationStrings.hubTonProfil(profil.dominants.map((type) => type.nom).toList()),
                  description: PocOrientationStrings.hubRevoirResultats,
                  onTap: () => Navigator.push(context, RiasecResultatPage.route(profil)),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
              ],
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
              if (!pistesEnHaut) ...[
                const SizedBox(height: DsfrSpacings.s4w),
                _MesPistes(etat: etat),
              ],
              const SizedBox(height: DsfrSpacings.s4w),
              PocMention(PocOrientationStrings.sourceRome),
            ],
          );
        },
      ),
    );
  }
}

// Le jeune a répondu « Je ne sais pas encore » au métier du questionnaire : on lui montre par où commencer.
bool _aReponduNePasSavoir(BuildContext context) {
  return ContexteJeune.depuis(StoreProvider.of<AppState>(context).state).neSaitPasEncore;
}

class _MesPistes extends StatelessWidget {
  const _MesPistes({required this.etat});

  final MesPistesEtat etat;

  @override
  Widget build(BuildContext context) {
    final quiTentent = etat.quiTentent;
    final misDeCote = etat.misDeCote;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PocSectionTitre(PocOrientationStrings.hubMesPistes),
        const SizedBox(height: DsfrSpacings.s2w),
        if (quiTentent.isEmpty)
          Text(
            PocOrientationStrings.hubMesPistesVide,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
          ),
        for (final piste in quiTentent) ...[
          _PisteTuile(piste: piste),
          const SizedBox(height: DsfrSpacings.s2w),
        ],
        if (misDeCote.isNotEmpty)
          DsfrAccordionsGroup(
            values: [
              DsfrAccordion(
                headerLabel: PocOrientationStrings.hubMisDeCote(misDeCote.length),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final piste in misDeCote)
                      PocMetierTuile(
                        metier: piste.metier,
                        avecStatut: false,
                        detail: piste.raisons.isEmpty ? null : PocOrientationStrings.pisteRaisons(piste.raisons),
                      ),
                  ],
                ),
              ),
            ],
          ),
        if (peutPartagerAuConseiller(context) && etat.aQuelqueChoseAPartager) ...[
          const SizedBox(height: DsfrSpacings.s3w),
          DsfrButton(
            label: PocOrientationStrings.hubPartager,
            icon: DsfrIcons.communicationChat3Line,
            variant: DsfrButtonVariant.secondary,
            size: DsfrComponentSize.lg,
            onPressed: () => afficherPartageConseiller(context),
          ),
        ],
      ],
    );
  }
}

class _PisteTuile extends StatelessWidget {
  const _PisteTuile({required this.piste});

  final Piste piste;

  @override
  Widget build(BuildContext context) {
    final prochaine = piste.prochaineAction;
    return DsfrTuileCard(
      leading: const DsfrTuileCardIcon(icon: DsfrIcons.healthHeartLine),
      title: piste.metier.libelle,
      description: [
        '${PocOrientationStrings.pisteOuJenSuis(piste.etapeEnCours)} · '
            '${PocOrientationStrings.pisteProgression(piste.nombreFaites, Piste.nombreActions)}',
        prochaine == null ? PocOrientationStrings.pisteALancer : PocOrientationStrings.pisteProchaineEtape(prochaine),
      ].join('\n'),
      onTap: () => Navigator.push(context, FicheMetierPage.route(piste.metier)),
    );
  }
}
