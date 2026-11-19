import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/poc_orientation/contexte_jeune.dart';
import 'package:pass_emploi_app/poc_orientation/donnees_parcours.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pages/centres_interet_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/test_riasec_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/tri_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/trouver_des_idees_page.dart';
import 'package:pass_emploi_app/poc_orientation/parcours.dart';
import 'package:pass_emploi_app/poc_orientation/partage_conseiller.dart';
import 'package:pass_emploi_app/poc_orientation/pistes_pour_toi.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/poc_passerelles.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/carte_a_trier.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/piste_widgets.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_tuile_card.dart';

// « Explorer les métiers », en 3 temps : trouver des idées, faire le tri, avancer sur ses pistes. À chaque visite,
// l'accueil met en avant une seule chose à faire.
class ExplorerMetiersPage extends StatefulWidget {
  const ExplorerMetiersPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: nomRouteExplorerMetiers),
      builder: (_) => const ExplorerMetiersPage(),
    );
  }

  @override
  State<ExplorerMetiersPage> createState() => _ExplorerMetiersPageState();
}

class _ExplorerMetiersPageState extends State<ExplorerMetiersPage> {
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
      titre: PocOrientationStrings.hubTitre,
      body: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) => FutureBuilder<DonneesParcours>(
          future: _donnees,
          builder: (context, snapshot) {
            if (!snapshot.hasData || donneesDuJeuneEnChargement(state)) {
              return Center(child: CircularProgressIndicator(semanticsLabel: PocOrientationStrings.chargement));
            }
            final donnees = snapshot.data!;
            return ValueListenableBuilder<MesPistesEtat>(
              valueListenable: MesPistes.instance,
              builder: (context, etat, _) {
                final aTrier = metiersATrier(state, etat, donnees);
                final etape = etapeDuParcours(aTrier: aTrier.length, pistes: etat.quiTentent.length);
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
                    _EtapesDuParcours(enCours: etape),
                    const SizedBox(height: DsfrSpacings.s3w),
                    switch (etape) {
                      EtapeParcours.idees => _HeroIdees(neSaitPasEncore: ContexteJeune.depuis(state).neSaitPasEncore),
                      EtapeParcours.tri => _HeroTri(aTrier: aTrier),
                      EtapeParcours.avancer => _HeroAvancer(etat: etat),
                    },
                    // Des métiers arrivent alors qu'il avance déjà : un rappel, sans changer d'étape.
                    if (etape == EtapeParcours.avancer && aTrier.isNotEmpty) ...[
                      const SizedBox(height: DsfrSpacings.s2w),
                      RappelATrier(
                        texte: PocOrientationStrings.rappelATrier(
                          aTrier.length,
                          voisinsDe(aTrier, etat, donnees.marche),
                        ),
                        onTap: () => Navigator.push(context, TriPage.route()),
                      ),
                    ],
                    const SizedBox(height: DsfrSpacings.s4w),
                    _MesPistes(etat: etat),
                    if (etape != EtapeParcours.idees) ...[
                      const SizedBox(height: DsfrSpacings.s4w),
                      DsfrTuileCard(
                        leading: const DsfrTuileCardIcon(icon: DsfrIcons.othersLightbulbLine),
                        title: PocOrientationStrings.autresIdeesTitre,
                        description: PocOrientationStrings.autresIdeesSousTitre,
                        onTap: () => Navigator.push(context, TrouverDesIdeesPage.route()),
                      ),
                    ],
                    const SizedBox(height: DsfrSpacings.s4w),
                    PocMention(PocOrientationStrings.sourceRome),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// « 1. Idées 2. Tri 3. Avancer » : où le jeune en est.
class _EtapesDuParcours extends StatelessWidget {
  const _EtapesDuParcours({required this.enCours});

  final EtapeParcours enCours;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final etape in EtapeParcours.values)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: etape == EtapeParcours.values.last ? 0 : DsfrSpacings.s1w),
              child: Semantics(
                container: true,
                label: PocOrientationStrings.etapeParcoursLecteur(etape, enCours),
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: etape.index <= enCours.index
                            ? DsfrColorDecisions.backgroundActionHighBlueFrance(context)
                            : DsfrColorDecisions.borderDefaultGrey(context),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: DsfrSpacings.s1w),
                    Text(
                      '${etape.index + 1}. ${PocOrientationStrings.etapeParcours(etape)}',
                      style: etape == enCours
                          ? DsfrTextStyle.bodySmBold(color: DsfrColorDecisions.textTitleGrey(context))
                          : DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// La seule chose à faire, en grand : un titre, une phrase et son bouton.
class _Hero extends StatelessWidget {
  const _Hero({required this.titre, required this.texte, required this.actions});

  final String titre;
  final String texte;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.backgroundContrastInfo(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              PocOrientationStrings.tuEnEsLa,
              style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s1v),
            Semantics(
              headingLevel: 2,
              child: Text(titre, style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context))),
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            Text(texte, style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context))),
            const SizedBox(height: DsfrSpacings.s2w),
            ...actions,
          ],
        ),
      ),
    );
  }
}

class _HeroIdees extends StatelessWidget {
  const _HeroIdees({required this.neSaitPasEncore});

  final bool neSaitPasEncore;

  @override
  Widget build(BuildContext context) {
    return _Hero(
      titre: PocOrientationStrings.heroIdeesTitre,
      texte: PocOrientationStrings.heroIdeesTexte(neSaitPasEncore),
      actions: [
        DsfrButton(
          label: PocOrientationStrings.heroIdeesTest,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.push(context, TestRiasecPage.route()),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: PocOrientationStrings.heroIdeesCentres,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.push(context, CentresInteretPage.route()),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        DsfrButton(
          label: PocOrientationStrings.heroIdeesMetier,
          variant: DsfrButtonVariant.tertiaryWithoutBorder,
          size: DsfrComponentSize.md,
          onPressed: () => Navigator.push(context, TrouverDesIdeesPage.route()),
        ),
      ],
    );
  }
}

class _HeroTri extends StatelessWidget {
  const _HeroTri({required this.aTrier});

  final List<PisteProposee> aTrier;

  @override
  Widget build(BuildContext context) {
    return _Hero(
      titre: PocOrientationStrings.heroTriTitre,
      texte: PocOrientationStrings.heroTriTexte(aTrier.length, originesDeLaListe(aTrier)),
      actions: [
        DsfrButton(
          label: PocOrientationStrings.heroTriBouton,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.push(context, TriPage.route()),
        ),
      ],
    );
  }
}

// La prochaine étape de la piste la plus avancée ; quand tout est fait, place aux offres.
class _HeroAvancer extends StatelessWidget {
  const _HeroAvancer({required this.etat});

  final MesPistesEtat etat;

  @override
  Widget build(BuildContext context) {
    final prochaine = prochaineEtape(etat);
    if (prochaine == null) return CarteSeLancer(metier: etat.quiTentent.last.metier, avecMetier: true);
    return ProchaineEtapeCarte(piste: prochaine.piste, action: prochaine.action, avecMetier: true);
  }
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
        PocSectionTitre(PocOrientationStrings.mesPistesTitre(quiTentent.length)),
        const SizedBox(height: DsfrSpacings.s1w),
        if (quiTentent.isEmpty)
          Text(
            PocOrientationStrings.mesPistesVide,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
          ),
        for (final piste in quiTentent)
          PocMetierTuile(
            metier: piste.metier,
            avecStatut: false,
            detail: '${PocOrientationStrings.pisteOuJenSuis(piste.etapeEnCours)} · '
                '${PocOrientationStrings.pisteProgression(piste.nombreFaites, Piste.nombreActions)}',
          ),
        if (misDeCote.isNotEmpty) ...[
          const SizedBox(height: DsfrSpacings.s2w),
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
        ],
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
