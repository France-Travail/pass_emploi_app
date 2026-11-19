import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/poc_orientation/conseils_freins.dart';
import 'package:pass_emploi_app/poc_orientation/donnees_parcours.dart';
import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/poc_passerelles.dart';
import 'package:pass_emploi_app/poc_orientation/resume_metier.dart';
import 'package:pass_emploi_app/poc_orientation/riasec.dart';
import 'package:pass_emploi_app/poc_orientation/rome_api_client.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/carte_a_trier.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/piste_widgets.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/pres_de_chez_toi.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

// La fiche, en résumé pour décider : ce qu'on y fait, les conditions qui comptent, si ça recrute près de chez soi,
// le salaire, l'accès. Puis l'avis du jeune et, pour une piste, sa prochaine étape. Tout le reste est plié.
class FicheMetierPage extends StatefulWidget {
  const FicheMetierPage({super.key, required this.metier});

  final RomeMetierResume metier;

  static Route<void> route(RomeMetierResume metier) => MaterialPageRoute(builder: (_) => FicheMetierPage(metier: metier));

  @override
  State<FicheMetierPage> createState() => _FicheMetierPageState();
}

class _FicheMetierPageState extends State<FicheMetierPage> {
  late Future<RomeFicheMetier> _fiche = RomeApiClient.instance.ficheMetier(widget.metier.code);
  late final Future<MarcheTravail?> _marche;

  @override
  void initState() {
    super.initState();
    ouvrirMesPistes(context);
    final demo = StoreProvider.of<AppState>(context, listen: false).state.demoState;
    _marche = demo ? MarcheTravailDemo.charger() : Future.value(null);
  }

  @override
  Widget build(BuildContext context) {
    return PocScaffold(
      titre: PocOrientationStrings.ficheTitre,
      body: PocFuture<RomeFicheMetier>(
        future: _fiche,
        onRetry: () => setState(() => _fiche = RomeApiClient.instance.ficheMetier(widget.metier.code)),
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        builder: (context, fiche) => FutureBuilder<MarcheTravail?>(
          future: _marche,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator(semanticsLabel: PocOrientationStrings.chargement));
            }
            final state = StoreProvider.of<AppState>(context).state;
            return _Contenu(fiche: fiche, marche: marchePourLeJeune(state, snapshot.data));
          },
        ),
      ),
    );
  }
}

class _Contenu extends StatelessWidget {
  const _Contenu({required this.fiche, required this.marche});

  final RomeFicheMetier fiche;
  final MarcheTravail? marche;

  @override
  Widget build(BuildContext context) {
    final phrase = phraseDuMetier(fiche);
    final conditions = conditionsMarquantes(fiche);
    final acces = resumeAcces(fiche);
    final chiffres = marche?.chiffres(fiche.code);
    final badges = [
      if (fiche.emploiReglemente)
        DsfrBadge(label: PocOrientationStrings.ficheReglemente, type: DsfrBadgeType.warning, size: DsfrComponentSize.sm),
      if (fiche.transitionEcologique)
        DsfrBadge(
          label: PocOrientationStrings.ficheTransitionEcologique,
          type: DsfrBadgeType.success,
          size: DsfrComponentSize.sm,
        ),
      if (fiche.transitionNumerique)
        DsfrBadge(
          label: PocOrientationStrings.ficheTransitionNumerique,
          type: DsfrBadgeType.information,
          size: DsfrComponentSize.sm,
        ),
    ];
    return ValueListenableBuilder<MesPistesEtat>(
      valueListenable: MesPistes.instance,
      builder: (context, etat, _) {
        final piste = etat.piste(fiche.code);
        final suivie = piste != null && piste.avis == AvisMetier.meTente ? piste : null;
        return ListView(
          padding: const EdgeInsets.all(DsfrSpacings.s2w),
          children: [
            if (badges.isNotEmpty) ...[
              Wrap(spacing: DsfrSpacings.s1w, runSpacing: DsfrSpacings.s1w, children: badges),
              const SizedBox(height: DsfrSpacings.s2w),
            ],
            Semantics(
              headingLevel: 1,
              child: Text(
                fiche.libelle,
                style: DsfrTextStyle.headline3(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ),
            if (fiche.domaine case final domaine?) ...[
              const SizedBox(height: DsfrSpacings.s1v),
              Text(domaine, style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context))),
            ],
            if (phrase != null) ...[
              const SizedBox(height: DsfrSpacings.s2w),
              Text(phrase, style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context))),
            ],
            if (conditions.isNotEmpty) ...[
              const SizedBox(height: DsfrSpacings.s2w),
              PastillesConditions(conditions),
            ],
            const SizedBox(height: DsfrSpacings.s3w),
            ResumePresDeChezToi(fiche: fiche, marche: marche),
            if (acces != null) FaitCourt(DsfrIcons.documentBook2Line, PocOrientationStrings.faitAcces(acces)),
            const SizedBox(height: DsfrSpacings.s3w),
            AvisSurLeMetier(fiche: fiche),
            if (suivie != null) ...[
              const SizedBox(height: DsfrSpacings.s3w),
              _ProchaineEtape(fiche: fiche, piste: suivie),
            ],
            const SizedBox(height: DsfrSpacings.s3w),
            DsfrAccordionsGroup(
              values: [
                DsfrAccordion(
                  headerLabel: PocOrientationStrings.ficheEtapes(suivie?.nombreFaites, Piste.nombreActions),
                  body: Padding(
                    padding: const EdgeInsets.only(bottom: DsfrSpacings.s2w),
                    child: AvancerSurLeMetier(fiche: fiche, avecTitre: false),
                  ),
                ),
                DsfrAccordion(headerLabel: PocOrientationStrings.ficheDetail, body: _Detail(fiche: fiche)),
                if (chiffres != null)
                  DsfrAccordion(
                    headerLabel: PocOrientationStrings.ficheTousLesChiffres(marche?.ville),
                    body: Padding(
                      padding: const EdgeInsets.only(bottom: DsfrSpacings.s2w),
                      child: PresDeChezToi(fiche: fiche, marche: marche, avecTitre: false),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DsfrSpacings.s3w),
            PocMention(PocOrientationStrings.ficheSource(fiche.code)),
          ],
        );
      },
    );
  }
}

// Pour une piste : une seule étape mise en avant, avec le conseil relié aux vraies conditions du métier.
class _ProchaineEtape extends StatelessWidget {
  const _ProchaineEtape({required this.fiche, required this.piste});

  final RomeFicheMetier fiche;
  final Piste piste;

  @override
  Widget build(BuildContext context) {
    final action = piste.prochaineAction;
    if (action == null) return CarteSeLancer(metier: fiche.resume);
    return ProchaineEtapeCarte(
      piste: piste,
      action: action,
      fiche: fiche,
      conseils: conseilsPourEtape(
        action.etape,
        reponsesAuQuestionnaire(context),
        sansDiplome: accessibleSansDiplome(fiche),
        efforts: effortsPhysiques(fiche),
      ),
    );
  }
}

// « Le métier en détail » : la fiche ROME complète, pliée sous le résumé.
class _Detail extends StatelessWidget {
  const _Detail({required this.fiche});

  final RomeFicheMetier fiche;

  @override
  Widget build(BuildContext context) {
    final texte = DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context));
    final sections = <List<Widget>>[
      if (fiche.enBref case final enBref? when !_enBrefAnnonceLaListe)
        [_SousTitre(PocOrientationStrings.ficheEnBref), DsfrHighlight(text: enBref, size: DsfrComponentSize.md)],
      if (fiche.auQuotidien.isNotEmpty)
        [
          _SousTitre(PocOrientationStrings.ficheQuotidien),
          if (_enBrefAnnonceLaListe) ...[
            Text(fiche.enBref!, style: texte),
            const SizedBox(height: DsfrSpacings.s1w),
          ],
          PocPuces(fiche.auQuotidien),
        ],
      if (fiche.competences.isNotEmpty)
        [_SousTitre(PocOrientationStrings.ficheCompetences), PocPuces(fiche.competences)],
      if (fiche.qualites.isNotEmpty) [_SousTitre(PocOrientationStrings.ficheQualites), PocPuces(fiche.qualites)],
      if (fiche.acces.isNotEmpty)
        [
          _SousTitre(PocOrientationStrings.ficheAcces),
          for (final ligne in fiche.acces)
            Padding(padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w), child: Text(ligne, style: texte)),
        ],
      if (fiche.contextes.isNotEmpty)
        [
          _SousTitre(PocOrientationStrings.ficheConditions),
          for (final groupe in fiche.contextes) ...[
            Text(groupe.categorie, style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context))),
            const SizedBox(height: DsfrSpacings.s1w),
            PocPuces(groupe.libelles),
          ],
        ],
      if (fiche.centresInteret.isNotEmpty)
        [_SousTitre(PocOrientationStrings.ficheCentresInteret), PocPuces(fiche.centresInteret)],
      if (_profilRiasec() case final profil?) [_SousTitre(PocOrientationStrings.ficheProfil), Text(profil, style: texte)],
      if (fiche.appellations.isNotEmpty)
        [_SousTitre(PocOrientationStrings.ficheAussiAppele), Text(fiche.appellations.join(' · '), style: texte)],
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: DsfrSpacings.s2w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, section) in sections.indexed) ...[
            if (index > 0) const SizedBox(height: DsfrSpacings.s3w),
            ...section,
          ],
        ],
      ),
    );
  }

  // Certaines définitions ROME s'arrêtent sur « Ainsi, il : » et annoncent la liste qui suit.
  bool get _enBrefAnnonceLaListe => fiche.auQuotidien.isNotEmpty && (fiche.enBref?.trimRight().endsWith(':') ?? false);

  String? _profilRiasec() {
    final types = [fiche.riasecMajeur, fiche.riasecMineur].map(Riasec.deLettre).nonNulls.toList();
    if (types.isEmpty) return null;
    return '${types.map((type) => type.lettre).join(' + ')} : ${types.map((type) => type.nom).join(' et ')}';
  }
}

class _SousTitre extends StatelessWidget {
  const _SousTitre(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w),
      child: Semantics(
        headingLevel: 3,
        child: Text(texte, style: DsfrTextStyle.bodyLgBold(color: DsfrColorDecisions.textTitleGrey(context))),
      ),
    );
  }
}
