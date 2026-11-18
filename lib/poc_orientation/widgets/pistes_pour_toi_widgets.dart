import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/alerte/list/alerte_list_actions.dart';
import 'package:pass_emploi_app/features/alerte/list/alerte_list_state.dart';
import 'package:pass_emploi_app/features/favori/list/favori_list_actions.dart';
import 'package:pass_emploi_app/features/favori/list/favori_list_state.dart';
import 'package:pass_emploi_app/features/suggestions_recherche/list/suggestions_recherche_actions.dart';
import 'package:pass_emploi_app/features/suggestions_recherche/list/suggestions_recherche_state.dart';
import 'package:pass_emploi_app/poc_orientation/contexte_jeune.dart';
import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pages/fiche_metier_page.dart';
import 'package:pass_emploi_app/poc_orientation/pistes_pour_toi.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/piste_widgets.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

// Section « Des pistes pour toi » : des métiers tirés de ce que le jeune a déjà fait dans l'app.
// Rien ne s'affiche tant qu'il n'y a aucune piste à proposer.
class PistesPourToi extends StatefulWidget {
  const PistesPourToi({super.key});

  static const visiblesAuDepart = 4;

  @override
  State<PistesPourToi> createState() => _PistesPourToiState();
}

class _PistesPourToiState extends State<PistesPourToi> {
  late final Future<(List<ExperienceFranceTravail>, MarcheTravail?)> _donnees;
  bool _tout = false;

  @override
  void initState() {
    super.initState();
    final state = StoreProvider.of<AppState>(context, listen: false).state;
    _donnees = Future.wait([
      ParcoursFranceTravailDemo.concerne(state)
          ? ParcoursFranceTravailDemo.charger()
          : Future.value(<ExperienceFranceTravail>[]),
      state.demoState ? MarcheTravailDemo.charger() : Future.value(null),
    ]).then((resultats) => (resultats[0] as List<ExperienceFranceTravail>, resultats[1] as MarcheTravail?));
    // Favoris, recherches et suggestions : chargés comme le font leurs écrans (en démo, depuis les fichiers locaux).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final store = StoreProvider.of<AppState>(context, listen: false);
      if (store.state.favoriListState is! FavoriListSuccessState) store.dispatch(FavoriListRequestAction());
      if (store.state.alerteListState is! AlerteListSuccessState) store.dispatch(AlerteListRequestAction());
      if (store.state.suggestionsRechercheState is! SuggestionsRechercheSuccessState) {
        store.dispatch(SuggestionsRechercheRequestAction());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = StoreProvider.of<AppState>(context).state;
    return FutureBuilder<(List<ExperienceFranceTravail>, MarcheTravail?)>(
      future: _donnees,
      builder: (context, snapshot) {
        final (experiences, marche) = snapshot.data ?? (const <ExperienceFranceTravail>[], null);
        return ValueListenableBuilder<MesPistesEtat>(
          valueListenable: MesPistes.instance,
          builder: (context, mesPistes, _) {
            final contexte = ContexteJeune.depuis(state, experiencesFranceTravail: experiences);
            final pistes = proposerDesPistes(contexte, mesPistes, marche: marche);
            if (pistes.isEmpty) return const SizedBox.shrink();
            // Les métiers proches d'une piste aimée ont leur propre groupe, ceux qui recrutent le plus d'abord.
            int offres(PisteProposee piste) => marche?.chiffres(piste.metier.code)?.offres12Mois ?? 0;
            final proches = [
              for (final piste in pistes)
                if (piste.raisons.every((raison) => raison.source == SourcePiste.metierProche)) piste,
            ]..sort((a, b) => offres(b).compareTo(offres(a)));
            final principales = [
              for (final piste in pistes)
                if (!proches.contains(piste)) piste,
            ];
            final visibles = _tout ? principales : principales.take(PistesPourToi.visiblesAuDepart).toList();
            final autres = principales.length - PistesPourToi.visiblesAuDepart;
            return Padding(
              padding: const EdgeInsets.only(top: DsfrSpacings.s4w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PocSectionTitre(PocOrientationStrings.pistesPourToiTitre),
                  const SizedBox(height: DsfrSpacings.s1w),
                  Text(
                    PocOrientationStrings.pistesPourToiIntro,
                    style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                  for (final piste in visibles) ...[
                    _CartePisteProposee(piste: piste, caRecrute: marche?.caRecrute(piste.metier.code) ?? false),
                    const SizedBox(height: DsfrSpacings.s2w),
                  ],
                  if (autres > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: DsfrButton(
                        label: _tout
                            ? PocOrientationStrings.pistesPourToiVoirMoins
                            : PocOrientationStrings.pistesPourToiVoirPlus(autres),
                        icon: _tout ? DsfrIcons.systemArrowUpSLine : DsfrIcons.systemArrowDownSLine,
                        variant: DsfrButtonVariant.tertiaryWithoutBorder,
                        size: DsfrComponentSize.md,
                        onPressed: () => setState(() => _tout = !_tout),
                      ),
                    ),
                  if (proches.isNotEmpty) ...[
                    const SizedBox(height: DsfrSpacings.s2w),
                    Semantics(
                      headingLevel: 3,
                      child: Text(
                        PocOrientationStrings.pistesProchesTitre,
                        style: DsfrTextStyle.bodyLgBold(color: DsfrColorDecisions.textTitleGrey(context)),
                      ),
                    ),
                    const SizedBox(height: DsfrSpacings.s2w),
                    for (final piste in proches) ...[
                      _CartePisteProposee(piste: piste, caRecrute: marche?.caRecrute(piste.metier.code) ?? false),
                      const SizedBox(height: DsfrSpacings.s2w),
                    ],
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CartePisteProposee extends StatelessWidget {
  const _CartePisteProposee({required this.piste, required this.caRecrute});

  final PisteProposee piste;
  final bool caRecrute;

  @override
  Widget build(BuildContext context) {
    final metier = piste.metier;
    final mention = DsfrColorDecisions.textMentionGrey(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: true,
              label: metier.libelle,
              hint: PocOrientationStrings.ficheTitre,
              excludeSemantics: true,
              onTap: () => _ouvrir(context),
              child: InkWell(
                onTap: () => _ouvrir(context),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        metier.libelle,
                        style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleBlueFrance(context)),
                      ),
                    ),
                    const SizedBox(width: DsfrSpacings.s1w),
                    Icon(
                      DsfrIcons.systemArrowRightSLine,
                      size: 16,
                      color: DsfrColorDecisions.textTitleBlueFrance(context),
                    ),
                  ],
                ),
              ),
            ),
            if (caRecrute) ...[
              const SizedBox(height: DsfrSpacings.s1w),
              Align(
                alignment: Alignment.centerLeft,
                child: DsfrBadge(
                  label: PocOrientationStrings.caRecrute,
                  type: DsfrBadgeType.success,
                  size: DsfrComponentSize.sm,
                ),
              ),
            ],
            const SizedBox(height: DsfrSpacings.s1w),
            for (final raison in piste.raisons)
              Padding(
                padding: const EdgeInsets.only(top: DsfrSpacings.s1v),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(child: Icon(_icone(raison.source), size: 16, color: mention)),
                    const SizedBox(width: DsfrSpacings.s1w),
                    Expanded(
                      child: Text(raison.texte, style: DsfrTextStyle.bodySm(color: mention)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: DsfrSpacings.s2w),
            Wrap(
              spacing: DsfrSpacings.s2w,
              runSpacing: DsfrSpacings.s1w,
              children: [
                DsfrButton(
                  label: PocOrientationStrings.avisMeTente,
                  icon: DsfrIcons.healthHeartLine,
                  variant: DsfrButtonVariant.secondary,
                  size: DsfrComponentSize.sm,
                  onPressed: () => MesPistes.instance.meTente(metier),
                ),
                DsfrButton(
                  label: PocOrientationStrings.avisPasPourMoi,
                  icon: DsfrIcons.systemCloseLine,
                  variant: DsfrButtonVariant.tertiary,
                  size: DsfrComponentSize.sm,
                  onPressed: () => mettreDeCote(context, metier),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _ouvrir(BuildContext context) => Navigator.push(context, FicheMetierPage.route(piste.metier));

  static IconData _icone(SourcePiste source) => switch (source) {
    SourcePiste.conseiller => DsfrIcons.userUserLine,
    SourcePiste.franceTravail => DsfrIcons.businessBriefcaseLine,
    SourcePiste.parcoursFranceTravail => DsfrIcons.documentFileTextLine,
    SourcePiste.questionnaire => DsfrIcons.documentSurveyLine,
    SourcePiste.favori => DsfrIcons.healthHeartLine,
    SourcePiste.recherche => DsfrIcons.systemSearchLine,
    SourcePiste.diagoriente => DsfrIcons.othersLightbulbLine,
    SourcePiste.metierProche => DsfrIcons.mapRoadMapLine,
  };
}
