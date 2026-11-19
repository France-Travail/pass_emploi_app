import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/poc_orientation/conseils_freins.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pages/fiche_metier_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/formations_metier_page.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/poc_passerelles.dart';
import 'package:pass_emploi_app/poc_orientation/resume_metier.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/bottom_sheets.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_tuile_card.dart';

OnboardingQuestionnaireAnswers? reponsesAuQuestionnaire(BuildContext context) {
  final questionnaire = StoreProvider.of<AppState>(context).state.onboardingQuestionnaireState;
  return questionnaire is OnboardingQuestionnaireSuccessState ? questionnaire.answers : null;
}

// Sur la fiche : le jeune dit si le métier le tente. « Ça me tente » en fait une piste, « Pas pour moi » le met de
// côté avec ses raisons. Un second appui sur le bouton choisi retire l'avis.
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
        return Column(
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
            Row(
              children: [
                Expanded(
                  child: _BoutonAvis(
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
                ),
                const SizedBox(width: DsfrSpacings.s2w),
                Expanded(
                  child: _BoutonAvis(
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
                ),
              ],
            ),
            if (statut != null) ...[
              const SizedBox(height: DsfrSpacings.s1w),
              Semantics(
                liveRegion: true,
                child: Text(statut, style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context))),
              ),
            ],
          ],
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

// La fenêtre « Pas pour toi ? » : null si le jeune annule, sinon les raisons choisies (peut-être aucune).
Future<Set<RaisonPasPourMoi>?> choisirRaisons(BuildContext context, {Set<RaisonPasPourMoi> raisons = const {}}) {
  return showPassEmploiBottomSheet<Set<RaisonPasPourMoi>>(
    context: context,
    builder: (_) => BottomSheetWrapper(
      title: PocOrientationStrings.raisonsTitre,
      body: RaisonsPasPourMoi(initiales: raisons),
    ),
  );
}

// true si le métier a bien été mis de côté.
Future<bool> mettreDeCote(
  BuildContext context,
  RomeMetierResume metier, {
  Set<RaisonPasPourMoi> raisons = const {},
}) async {
  final choisies = await choisirRaisons(context, raisons: raisons);
  if (choisies == null) return false;
  MesPistes.instance.pasPourMoi(metier, choisies);
  return true;
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

// Fait l'action d'une étape. Sans la fiche (depuis l'accueil), les formations passent par la fiche du métier.
void faireAction(BuildContext context, RomeMetierResume metier, ActionPiste action, {RomeFicheMetier? fiche}) {
  switch (action) {
    case ActionPiste.voirVideo:
      launchExternalUrl(lienVideosMetier(metier));
    case ActionPiste.echangerAvecUnPro:
      launchExternalUrl(lienEchangerAvecUnPro(metier));
    case ActionPiste.faireUneImmersion:
      ouvrirRechercheImmersion(context, metier);
    case ActionPiste.regarderLesFormations:
      Navigator.push(context, fiche != null ? FormationsMetierPage.route(fiche) : FicheMetierPage.route(metier));
    case ActionPiste.lireFiche:
      if (fiche == null) Navigator.push(context, FicheMetierPage.route(metier));
  }
}

bool _versUnAutreSite(ActionPiste action) => action == ActionPiste.voirVideo || action == ActionPiste.echangerAvecUnPro;

// « Ta prochaine étape » : une seule action mise en avant, son bouton, sa case « c'est fait » et le conseil qui va
// avec. Sur l'accueil (sans fiche) elle rappelle aussi le métier.
class ProchaineEtapeCarte extends StatelessWidget {
  const ProchaineEtapeCarte({
    super.key,
    required this.piste,
    required this.action,
    this.fiche,
    this.conseils = const [],
    this.avecMetier = false,
  });

  final Piste piste;
  final ActionPiste action;
  final RomeFicheMetier? fiche;
  final List<String> conseils;
  final bool avecMetier;

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
              PocOrientationStrings.heroAvancerLabel,
              style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s1v),
            Semantics(
              headingLevel: 2,
              child: Text(
                PocOrientationStrings.actionTitre(action),
                style: DsfrTextStyle.headline5(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ),
            if (avecMetier) ...[
              const SizedBox(height: DsfrSpacings.s1v),
              Text(
                piste.metier.libelle,
                style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textActionHighBlueFrance(context)),
              ),
            ],
            const SizedBox(height: DsfrSpacings.s1w),
            Text(
              PocOrientationStrings.actionDescription(action),
              style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
            ),
            for (final conseil in conseils) ConseilFrein(conseil),
            const SizedBox(height: DsfrSpacings.s2w),
            DsfrButton(
              label: PocOrientationStrings.actionBouton(action),
              icon: _versUnAutreSite(action) ? DsfrIcons.systemExternalLinkLine : null,
              iconLocation: DsfrButtonIconLocation.right,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.lg,
              onPressed: () => faireAction(context, piste.metier, action, fiche: fiche),
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            CaseAction(piste: piste, action: action),
            if (avecMetier) ...[
              const SizedBox(height: DsfrSpacings.s1w),
              Align(
                alignment: Alignment.centerLeft,
                child: DsfrButton(
                  label: PocOrientationStrings.voirLaFiche,
                  variant: DsfrButtonVariant.tertiaryWithoutBorder,
                  size: DsfrComponentSize.md,
                  onPressed: () => Navigator.push(context, FicheMetierPage.route(piste.metier)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Toutes les étapes sont faites : il reste à se lancer, avec les offres d'emploi ou d'alternance.
class CarteSeLancer extends StatelessWidget {
  const CarteSeLancer({super.key, required this.metier, this.avecMetier = false});

  final RomeMetierResume metier;
  final bool avecMetier;

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
              PocOrientationStrings.heroAvancerLabel,
              style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s1v),
            Semantics(
              headingLevel: 2,
              child: Text(
                PocOrientationStrings.heroLancerTitre,
                style: DsfrTextStyle.headline5(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ),
            if (avecMetier) ...[
              const SizedBox(height: DsfrSpacings.s1v),
              Text(
                metier.libelle,
                style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textActionHighBlueFrance(context)),
              ),
            ],
            const SizedBox(height: DsfrSpacings.s1w),
            Text(
              avecMetier ? PocOrientationStrings.heroLancerTexte : PocOrientationStrings.lancerTexteMetier,
              style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            DsfrButton(
              label: PocOrientationStrings.ficheVoirOffres,
              icon: DsfrIcons.businessBriefcaseLine,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.lg,
              onPressed: () => ouvrirRechercheOffres(context, metier, alternance: false),
            ),
            if (peutChercherAlternance(context)) ...[
              const SizedBox(height: DsfrSpacings.s2w),
              DsfrButton(
                label: PocOrientationStrings.ficheAlternance,
                variant: DsfrButtonVariant.secondary,
                size: DsfrComponentSize.lg,
                onPressed: () => ouvrirRechercheOffres(context, metier, alternance: true),
              ),
            ],
            if (avecMetier) ...[
              const SizedBox(height: DsfrSpacings.s1w),
              Align(
                alignment: Alignment.centerLeft,
                child: DsfrButton(
                  label: PocOrientationStrings.voirLaFiche,
                  variant: DsfrButtonVariant.tertiaryWithoutBorder,
                  size: DsfrComponentSize.md,
                  onPressed: () => Navigator.push(context, FicheMetierPage.route(metier)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Toutes les étapes pour avancer sur le métier. Pour une piste, chaque étape se coche.
class AvancerSurLeMetier extends StatelessWidget {
  const AvancerSurLeMetier({super.key, required this.fiche, this.avecTitre = true});

  final RomeFicheMetier fiche;
  final bool avecTitre;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MesPistesEtat>(
      valueListenable: MesPistes.instance,
      builder: (context, etat, _) {
        final piste = etat.piste(fiche.code);
        final suivie = piste != null && piste.avis == AvisMetier.meTente ? piste : null;
        final reponses = reponsesAuQuestionnaire(context);
        final sansDiplome = accessibleSansDiplome(fiche);
        final efforts = effortsPhysiques(fiche);
        final texte = DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (avecTitre) ...[
              PocSectionTitre(PocOrientationStrings.etapesTitre),
              const SizedBox(height: DsfrSpacings.s1w),
            ],
            Text(
              suivie == null
                  ? PocOrientationStrings.etapesHorsPiste
                  : PocOrientationStrings.etapesProgression(suivie.nombreFaites, Piste.nombreActions),
              style: texte,
            ),
            for (final etape in EtapePiste.values) ...[
              const SizedBox(height: DsfrSpacings.s3w),
              _EtapeTitre(PocOrientationStrings.etapeTitre(etape)),
              for (final conseil in conseilsPourEtape(etape, reponses, sansDiplome: sansDiplome, efforts: efforts))
                ConseilFrein(conseil),
              for (final action in ActionPiste.values.where((action) => action.etape == etape)) ...[
                if (action != ActionPiste.lireFiche) ...[
                  const SizedBox(height: DsfrSpacings.s2w),
                  TuileAction(fiche: fiche, action: action),
                ],
                if (suivie != null) ...[
                  const SizedBox(height: DsfrSpacings.s1w),
                  CaseAction(piste: suivie, action: action),
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
                  onTap: () => ouvrirFormationsAlternance(fiche.resume),
                ),
                PocLienExterne(
                  label: PocOrientationStrings.ficheFormationContinue,
                  onTap: () => ouvrirFormationsFranceTravail(fiche.resume),
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
              onPressed: () => ouvrirRechercheOffres(context, fiche.resume, alternance: false),
            ),
            if (peutChercherAlternance(context)) ...[
              const SizedBox(height: DsfrSpacings.s2w),
              DsfrButton(
                label: PocOrientationStrings.ficheAlternance,
                variant: DsfrButtonVariant.secondary,
                size: DsfrComponentSize.lg,
                onPressed: () => ouvrirRechercheOffres(context, fiche.resume, alternance: true),
              ),
            ],
          ],
        );
      },
    );
  }
}

// Conseil tiré des freins du questionnaire, à côté de l'étape où il sert.
class ConseilFrein extends StatelessWidget {
  const ConseilFrein(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DsfrSpacings.s2w),
      child: Semantics(
        label: PocOrientationStrings.conseilPourLecteur(texte),
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: DsfrColorDecisions.backgroundDefaultGrey(context),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DsfrSpacings.s2w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  DsfrIcons.othersLightbulbLine,
                  size: 20,
                  color: DsfrColorDecisions.textActionHighBlueFrance(context),
                ),
                const SizedBox(width: DsfrSpacings.s1w),
                Expanded(
                  child: Text(texte, style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context))),
                ),
              ],
            ),
          ),
        ),
      ),
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

class TuileAction extends StatelessWidget {
  const TuileAction({super.key, required this.fiche, required this.action});

  final RomeFicheMetier fiche;
  final ActionPiste action;

  @override
  Widget build(BuildContext context) {
    final lien = switch (action) {
      ActionPiste.voirVideo => lienVideosMetier(fiche.resume),
      ActionPiste.echangerAvecUnPro => lienEchangerAvecUnPro(fiche.resume),
      _ => null,
    };
    return DsfrTuileCard(
      leading: DsfrTuileCardIcon(icon: _icone),
      title: PocOrientationStrings.actionTitre(action),
      description: PocOrientationStrings.actionDescription(action),
      descriptionIcon: lien != null ? DsfrIcons.systemExternalLinkLine : DsfrIcons.systemArrowRightSLine,
      semanticsLink: lien != null,
      semanticsLinkUrl: lien,
      onTap: () => faireAction(context, fiche.resume, action, fiche: fiche),
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

class CaseAction extends StatelessWidget {
  const CaseAction({super.key, required this.piste, required this.action});

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
