import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pages/formations_metier_page.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/poc_passerelles.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_tuile_card.dart';

// En haut de la fiche : le jeune dit si le métier le tente. « Ça me tente » en fait une piste, « Pas pour moi » le
// met de côté avec ses raisons. Un second appui sur le bouton choisi retire l'avis.
class AvisSurLeMetier extends StatelessWidget {
  const AvisSurLeMetier({super.key, required this.fiche});

  final RomeFicheMetier fiche;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MesPistesEtat>(
      valueListenable: MesPistes.instance,
      builder: (context, etat, _) {
        final piste = etat.piste(fiche.code);
        final avis = piste?.avis;
        final statut = switch (avis) {
          AvisMetier.meTente => PocOrientationStrings.avisDansMesPistes,
          AvisMetier.pasPourMoi =>
            piste!.raisons.isEmpty
                ? PocOrientationStrings.avisMisDeCote
                : PocOrientationStrings.avisMisDeCoteRaisons(piste.raisons),
          null => null,
        };
        return DecoratedBox(
          decoration: BoxDecoration(
            color: DsfrColorDecisions.backgroundAltBlueFrance(context),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DsfrSpacings.s2w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  headingLevel: 2,
                  child: Text(
                    PocOrientationStrings.avisTitre,
                    style: DsfrTextStyle.bodyLgBold(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
                Wrap(
                  spacing: DsfrSpacings.s2w,
                  runSpacing: DsfrSpacings.s1w,
                  children: [
                    _BoutonAvis(
                      label: PocOrientationStrings.avisMeTente,
                      icone: DsfrIcons.healthHeartLine,
                      choisi: avis == AvisMetier.meTente,
                      onPressed: () {
                        if (avis == AvisMetier.meTente) {
                          MesPistes.instance.oublier(fiche.code);
                        } else {
                          MesPistes.instance.meTente(fiche.resume);
                        }
                      },
                    ),
                    _BoutonAvis(
                      label: PocOrientationStrings.avisPasPourMoi,
                      icone: DsfrIcons.systemCloseLine,
                      choisi: avis == AvisMetier.pasPourMoi,
                      onPressed: () {
                        if (avis == AvisMetier.pasPourMoi) {
                          MesPistes.instance.oublier(fiche.code);
                        } else {
                          mettreDeCote(context, fiche.resume);
                        }
                      },
                    ),
                  ],
                ),
                if (statut != null) ...[
                  const SizedBox(height: DsfrSpacings.s2w),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      statut,
                      style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BoutonAvis extends StatelessWidget {
  const _BoutonAvis({required this.label, required this.icone, required this.choisi, required this.onPressed});

  final String label;
  final IconData icone;
  final bool choisi;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: choisi,
      child: DsfrButton(
        label: label,
        icon: choisi ? DsfrIcons.systemCheckLine : icone,
        variant: choisi ? DsfrButtonVariant.primary : DsfrButtonVariant.secondary,
        size: DsfrComponentSize.md,
        onPressed: onPressed,
      ),
    );
  }
}

Future<void> mettreDeCote(
  BuildContext context,
  RomeMetierResume metier, {
  Set<RaisonPasPourMoi> raisons = const {},
}) async {
  final choisies = await showPassEmploiBottomSheet<Set<RaisonPasPourMoi>>(
    context: context,
    builder: (_) => BottomSheetWrapper(
      title: PocOrientationStrings.raisonsTitre,
      body: RaisonsPasPourMoi(initiales: raisons),
    ),
  );
  if (choisies != null) MesPistes.instance.pasPourMoi(metier, choisies);
}

class RaisonsPasPourMoi extends StatefulWidget {
  const RaisonsPasPourMoi({super.key, this.initiales = const {}});

  final Set<RaisonPasPourMoi> initiales;

  @override
  State<RaisonsPasPourMoi> createState() => _RaisonsPasPourMoiState();
}

class _RaisonsPasPourMoiState extends State<RaisonsPasPourMoi> {
  late final Set<RaisonPasPourMoi> _choisies = {...widget.initiales};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: DsfrSpacings.s2w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            headingLevel: 2,
            child: Text(
              PocOrientationStrings.raisonsQuestion,
              style: DsfrTextStyle.bodyLgBold(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s1w),
          Text(
            PocOrientationStrings.raisonsIntro,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          for (final raison in RaisonPasPourMoi.values)
            Padding(
              padding: const EdgeInsets.only(bottom: DsfrSpacings.s2w),
              child: DsfrCheckbox(
                label: raison.libelle,
                size: DsfrComponentSize.md,
                value: _choisies.contains(raison),
                onChanged: (choisie) => setState(() => choisie ? _choisies.add(raison) : _choisies.remove(raison)),
              ),
            ),
          const SizedBox(height: DsfrSpacings.s1w),
          DsfrButton(
            label: PocOrientationStrings.raisonsValider,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: () => Navigator.pop(context, {..._choisies}),
          ),
          const SizedBox(height: DsfrSpacings.s1w),
          DsfrButton(
            label: PocOrientationStrings.raisonsAnnuler,
            variant: DsfrButtonVariant.tertiaryWithoutBorder,
            size: DsfrComponentSize.lg,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// Après un test (échange avec un pro, immersion), le jeune dit si le métier le tente toujours : c'est là qu'il
// tranche. « Non » le met de côté, avec « Je l'ai testé et ça ne m'a pas plu » déjà coché.
Future<void> demanderApresTest(BuildContext context, RomeMetierResume metier) async {
  final continuer = await showPassEmploiBottomSheet<bool>(
    context: context,
    builder: (_) => BottomSheetWrapper(
      title: PocOrientationStrings.apresTestTitre,
      body: _ApresTest(metier: metier),
    ),
  );
  if (continuer == false && context.mounted) {
    await mettreDeCote(context, metier, raisons: {RaisonPasPourMoi.teste});
  }
}

class _ApresTest extends StatelessWidget {
  const _ApresTest({required this.metier});

  final RomeMetierResume metier;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: DsfrSpacings.s2w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            headingLevel: 2,
            child: Text(
              PocOrientationStrings.apresTestQuestion(metier.libelle),
              style: DsfrTextStyle.bodyLgBold(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s3w),
          DsfrButton(
            label: PocOrientationStrings.apresTestOui,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: () => Navigator.pop(context, true),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrButton(
            label: PocOrientationStrings.apresTestNon,
            variant: DsfrButtonVariant.secondary,
            size: DsfrComponentSize.lg,
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }
}

// En bas de la fiche : les étapes pour avancer sur le métier. Pour une piste, chaque étape se coche.
class AvancerSurLeMetier extends StatelessWidget {
  const AvancerSurLeMetier({super.key, required this.fiche});

  final RomeFicheMetier fiche;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MesPistesEtat>(
      valueListenable: MesPistes.instance,
      builder: (context, etat, _) {
        final piste = etat.piste(fiche.code);
        final suivie = piste != null && piste.avis == AvisMetier.meTente ? piste : null;
        final texte = DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PocSectionTitre(PocOrientationStrings.etapesTitre),
            const SizedBox(height: DsfrSpacings.s1w),
            Text(
              suivie == null
                  ? PocOrientationStrings.etapesHorsPiste
                  : PocOrientationStrings.etapesProgression(suivie.nombreFaites, Piste.nombreActions),
              style: texte,
            ),
            for (final etape in EtapePiste.values) ...[
              const SizedBox(height: DsfrSpacings.s3w),
              _EtapeTitre(PocOrientationStrings.etapeTitre(etape)),
              for (final action in ActionPiste.values.where((action) => action.etape == etape)) ...[
                if (action != ActionPiste.lireFiche) ...[
                  const SizedBox(height: DsfrSpacings.s2w),
                  _TuileAction(fiche: fiche, action: action),
                ],
                if (suivie != null) ...[
                  const SizedBox(height: DsfrSpacings.s1w),
                  _CaseAction(fiche: fiche, piste: suivie, action: action),
                ],
              ],
              if (etape == EtapePiste.seFormer) ...[
                const SizedBox(height: DsfrSpacings.s2w),
                Text(
                  PocOrientationStrings.ficheAutresSources,
                  style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                ),
                const SizedBox(height: DsfrSpacings.s1w),
                PocLienExterne(
                  label: PocOrientationStrings.ficheFormationAlternance,
                  onTap: () => ouvrirFormationsAlternance(fiche),
                ),
                PocLienExterne(
                  label: PocOrientationStrings.ficheFormationContinue,
                  onTap: () => ouvrirFormationsFranceTravail(fiche),
                ),
                PocLienExterne(label: PocOrientationStrings.ficheFormationInitiale, onTap: ouvrirFormationsOnisep),
              ],
            ],
            const SizedBox(height: DsfrSpacings.s3w),
            _EtapeTitre(PocOrientationStrings.etapeSeLancer),
            const SizedBox(height: DsfrSpacings.s2w),
            DsfrButton(
              label: PocOrientationStrings.ficheVoirOffres,
              icon: DsfrIcons.businessBriefcaseLine,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.lg,
              onPressed: () => ouvrirRechercheOffres(context, fiche, alternance: false),
            ),
            if (peutChercherAlternance(context)) ...[
              const SizedBox(height: DsfrSpacings.s2w),
              DsfrButton(
                label: PocOrientationStrings.ficheAlternance,
                variant: DsfrButtonVariant.secondary,
                size: DsfrComponentSize.lg,
                onPressed: () => ouvrirRechercheOffres(context, fiche, alternance: true),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _EtapeTitre extends StatelessWidget {
  const _EtapeTitre(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      headingLevel: 3,
      child: Text(texte, style: DsfrTextStyle.bodyLgBold(color: DsfrColorDecisions.textTitleGrey(context))),
    );
  }
}

class _TuileAction extends StatelessWidget {
  const _TuileAction({required this.fiche, required this.action});

  final RomeFicheMetier fiche;
  final ActionPiste action;

  @override
  Widget build(BuildContext context) {
    final lien = switch (action) {
      ActionPiste.voirVideo => lienVideosMetier(fiche),
      ActionPiste.echangerAvecUnPro => lienEchangerAvecUnPro(fiche),
      _ => null,
    };
    return DsfrTuileCard(
      leading: DsfrTuileCardIcon(icon: _icone),
      title: PocOrientationStrings.actionTitre(action),
      description: PocOrientationStrings.actionDescription(action),
      descriptionIcon: lien != null ? DsfrIcons.systemExternalLinkLine : DsfrIcons.systemArrowRightSLine,
      semanticsLink: lien != null,
      semanticsLinkUrl: lien,
      onTap: () {
        switch (action) {
          case ActionPiste.faireUneImmersion:
            ouvrirRechercheImmersion(context, fiche);
          case ActionPiste.regarderLesFormations:
            Navigator.push(context, FormationsMetierPage.route(fiche));
          case ActionPiste.voirVideo || ActionPiste.echangerAvecUnPro || ActionPiste.lireFiche:
            if (lien != null) launchExternalUrl(lien);
        }
      },
    );
  }

  IconData get _icone => switch (action) {
    ActionPiste.lireFiche => DsfrIcons.documentFileTextLine,
    ActionPiste.voirVideo => DsfrIcons.mediaPlayCircleLine,
    ActionPiste.echangerAvecUnPro => DsfrIcons.communicationQuestionAnswerLine,
    ActionPiste.faireUneImmersion => DsfrIcons.mapMapPin2Line,
    ActionPiste.regarderLesFormations => DsfrIcons.documentBook2Line,
  };
}

class _CaseAction extends StatelessWidget {
  const _CaseAction({required this.fiche, required this.piste, required this.action});

  final RomeFicheMetier fiche;
  final Piste piste;
  final ActionPiste action;

  @override
  Widget build(BuildContext context) {
    return DsfrCheckbox(
      label: PocOrientationStrings.actionFaite(action),
      size: DsfrComponentSize.md,
      value: piste.faites.contains(action),
      onChanged: (faite) {
        MesPistes.instance.marquer(piste.code, action, faite: faite);
        if (faite && action.estUnTest) demanderApresTest(context, piste.metier);
      },
    );
  }
}
