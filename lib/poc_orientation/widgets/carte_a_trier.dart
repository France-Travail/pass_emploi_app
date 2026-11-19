import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:intl/intl.dart';
import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/pistes_pour_toi.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/resume_metier.dart';
import 'package:pass_emploi_app/poc_orientation/rome_api_client.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

String nombreFrancais(int nombre) => NumberFormat.decimalPattern('fr_FR').format(nombre);

IconData iconeDeLaSource(SourcePiste source) => switch (source) {
  SourcePiste.conseiller => DsfrIcons.userUserLine,
  SourcePiste.franceTravail => DsfrIcons.businessBriefcaseLine,
  SourcePiste.parcoursFranceTravail => DsfrIcons.documentFileTextLine,
  SourcePiste.questionnaire => DsfrIcons.documentSurveyLine,
  SourcePiste.test => DsfrIcons.mapCompass3Line,
  SourcePiste.centresInteret => DsfrIcons.userUserHeartLine,
  SourcePiste.favori => DsfrIcons.healthHeartLine,
  SourcePiste.recherche => DsfrIcons.systemSearchLine,
  SourcePiste.diagoriente => DsfrIcons.othersLightbulbLine,
  SourcePiste.metierProche => DsfrIcons.mapRoadMapLine,
};

// Un métier à trier : l'essentiel pour décider (ce qu'on y fait, les conditions, s'il recrute, le salaire, l'accès)
// et pourquoi on le montre au jeune. Le résumé vient de la fiche ROME, chargée à part : la carte s'affiche sans elle.
class CarteATrier extends StatelessWidget {
  const CarteATrier({super.key, required this.piste, this.marche});

  final PisteProposee piste;
  final MarcheTravail? marche;

  @override
  Widget build(BuildContext context) {
    final metier = piste.metier;
    final chiffres = marche?.chiffres(metier.code);
    final mention = DsfrColorDecisions.textMentionGrey(context);
    return FutureBuilder<RomeFicheMetier>(
      future: RomeApiClient.instance.ficheMetier(metier.code),
      builder: (context, snapshot) {
        // En démo, un métier sans fiche reçoit celle du boulanger : on ne la montre pas sous un autre intitulé.
        final fiche = snapshot.data?.code == metier.code ? snapshot.data : null;
        final phrase = fiche == null ? null : phraseDuMetier(fiche);
        final conditions = fiche == null ? const <String>[] : conditionsMarquantes(fiche);
        final acces = fiche == null ? null : resumeAcces(fiche);
        return DecoratedBox(
          decoration: BoxDecoration(
            color: DsfrColorDecisions.backgroundDefaultGrey(context),
            border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DsfrSpacings.s2w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (marche?.caRecrute(metier.code) ?? false) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DsfrBadge(
                      label: PocOrientationStrings.caRecrute,
                      type: DsfrBadgeType.success,
                      size: DsfrComponentSize.sm,
                    ),
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                ],
                Semantics(
                  headingLevel: 2,
                  child: Text(
                    metier.libelle,
                    style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                ),
                if ((fiche?.domaine ?? metier.grandDomaine) case final domaine?) ...[
                  const SizedBox(height: DsfrSpacings.s1v),
                  Text(domaine, style: DsfrTextStyle.bodySm(color: mention)),
                ],
                if (phrase != null) ...[
                  const SizedBox(height: DsfrSpacings.s2w),
                  Text(
                    phrase,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                  ),
                ],
                if (conditions.isNotEmpty) ...[
                  const SizedBox(height: DsfrSpacings.s2w),
                  PastillesConditions(conditions),
                ],
                const SizedBox(height: DsfrSpacings.s2w),
                if (chiffres?.offres12Mois case final offres?)
                  FaitCourt(
                    DsfrIcons.businessBriefcaseLine,
                    PocOrientationStrings.faitOffres(nombreFrancais(offres), marche!.ville),
                  ),
                if ((chiffres?.salaireMin, chiffres?.salaireMax) case (final min?, final max?))
                  FaitCourt(
                    DsfrIcons.financeMoneyEuroCircleLine,
                    PocOrientationStrings.faitSalaire(nombreFrancais(min), nombreFrancais(max)),
                  ),
                // L'accès complet est sur la fiche : sur la carte, deux lignes suffisent pour décider.
                if (acces != null)
                  FaitCourt(DsfrIcons.documentBook2Line, PocOrientationStrings.faitAcces(acces), maxLignes: 2),
                const SizedBox(height: DsfrSpacings.s1w),
                Divider(color: DsfrColorDecisions.borderDefaultGrey(context), height: DsfrSpacings.s3w),
                Text(
                  PocOrientationStrings.triPourquoi,
                  style: DsfrTextStyle.bodySmBold(color: DsfrColorDecisions.textTitleGrey(context)),
                ),
                for (final raison in piste.raisons)
                  Padding(
                    padding: const EdgeInsets.only(top: DsfrSpacings.s1w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExcludeSemantics(child: Icon(iconeDeLaSource(raison.source), size: 16, color: mention)),
                        const SizedBox(width: DsfrSpacings.s1w),
                        Expanded(child: Text(raison.texte, style: DsfrTextStyle.bodySm(color: mention))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// « 5 nouveaux métiers à trier, voisins de Boulanger » : des métiers attendent dans le tri, sans changer d'étape.
class RappelATrier extends StatelessWidget {
  const RappelATrier({super.key, required this.texte, required this.onTap});

  final String texte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bleu = DsfrColorDecisions.textActionHighBlueFrance(context);
    return Semantics(
      container: true,
      button: true,
      label: texte,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: DsfrColorDecisions.borderActionHighBlueFrance(context)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w, vertical: DsfrSpacings.s3v),
              child: Row(
                children: [
                  Expanded(child: Text(texte, style: DsfrTextStyle.bodyMdBold(color: bleu))),
                  const SizedBox(width: DsfrSpacings.s1w),
                  Icon(DsfrIcons.systemArrowRightSLine, size: 16, color: bleu),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Les conditions qui comptent (travail de nuit, charges lourdes…), en petites pastilles.
class PastillesConditions extends StatelessWidget {
  const PastillesConditions(this.conditions, {super.key});

  final List<String> conditions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DsfrSpacings.s1w,
      runSpacing: DsfrSpacings.s1w,
      children: [
        for (final condition in conditions)
          DecoratedBox(
            decoration: BoxDecoration(
              color: DsfrColorDecisions.backgroundContrastGrey(context),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s1w, vertical: DsfrSpacings.s1v),
              child: Text(condition, style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textDefaultGrey(context))),
            ),
          ),
      ],
    );
  }
}

class FaitCourt extends StatelessWidget {
  const FaitCourt(this.icone, this.texte, {super.key, this.maxLignes});

  final IconData icone;
  final String texte;
  final int? maxLignes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Icon(icone, size: 18, color: DsfrColorDecisions.textActionHighBlueFrance(context)),
          ),
          const SizedBox(width: DsfrSpacings.s1w),
          Expanded(
            child: Text(
              texte,
              maxLines: maxLignes,
              overflow: maxLignes == null ? null : TextOverflow.ellipsis,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
            ),
          ),
        ],
      ),
    );
  }
}
