import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/poc_orientation/donnees_parcours.dart';
import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/carte_a_trier.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';

// « Ça recrute près de chez toi ? » : les chiffres du métier autour de la ville de recherche du questionnaire.
// En démo, chiffres relevés sur Data Emploi (aucun appel réseau). Pour un vrai compte, le POC n'a pas l'API Marché du
// travail : il propose seulement la page Data Emploi du métier pour le département du jeune.

String? lienDataEmploiPourLeJeune(AppState state, MarcheTravail? marche, String codeRome) {
  if (marche != null) return marche.lienDataEmploi(codeRome);
  final departement = departementDe(communeDuJeune(state));
  return departement == null ? null : lienDataEmploiMetier('DEP', departement, codeRome);
}

// Dans le résumé de la fiche : « Ça recrute », les offres et le salaire. Le reste est dans « Tous les chiffres ».
class ResumePresDeChezToi extends StatelessWidget {
  const ResumePresDeChezToi({super.key, required this.fiche, required this.marche});

  final RomeFicheMetier fiche;
  final MarcheTravail? marche;

  @override
  Widget build(BuildContext context) {
    final marche = this.marche;
    final chiffres = marche?.chiffres(fiche.code);
    if (marche == null || chiffres == null) {
      final lien = lienDataEmploiPourLeJeune(StoreProvider.of<AppState>(context).state, marche, fiche.code);
      if (lien == null) return const SizedBox.shrink();
      return PocLienExterne(label: PocOrientationStrings.ficheVoirSiCaRecrute, onTap: () => launchExternalUrl(lien));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (marche.caRecrute(fiche.code)) ...[
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
        if (chiffres.offres12Mois case final offres?)
          FaitCourt(DsfrIcons.businessBriefcaseLine, PocOrientationStrings.faitOffres(nombreFrancais(offres), marche.ville)),
        if ((chiffres.salaireMin, chiffres.salaireMax) case (final min?, final max?))
          FaitCourt(
            DsfrIcons.financeMoneyEuroCircleLine,
            PocOrientationStrings.faitSalaire(nombreFrancais(min), nombreFrancais(max)),
          ),
      ],
    );
  }
}

// Tous les chiffres du métier près de chez le jeune, ou le lien vers Data Emploi quand le POC n'en a pas.
class PresDeChezToi extends StatelessWidget {
  const PresDeChezToi({super.key, required this.fiche, required this.marche, this.avecTitre = true});

  final RomeFicheMetier fiche;
  final MarcheTravail? marche;
  final bool avecTitre;

  @override
  Widget build(BuildContext context) {
    final marche = this.marche;
    final chiffres = marche?.chiffres(fiche.code);
    if (marche != null && chiffres != null) {
      return _AvecChiffres(fiche: fiche, marche: marche, chiffres: chiffres, avecTitre: avecTitre);
    }
    final lien = lienDataEmploiPourLeJeune(StoreProvider.of<AppState>(context).state, marche, fiche.code);
    if (lien == null) return const SizedBox.shrink();
    return _SansChiffres(lien: lien, avecTitre: avecTitre);
  }
}

class _AvecChiffres extends StatelessWidget {
  const _AvecChiffres({required this.fiche, required this.marche, required this.chiffres, required this.avecTitre});

  final RomeFicheMetier fiche;
  final MarcheTravail marche;
  final ChiffresMetier chiffres;
  final bool avecTitre;

  @override
  Widget build(BuildContext context) {
    final difficulte = chiffres.difficulte;
    final origines = chiffres.principalesOrigines;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (avecTitre) ...[
          PocSectionTitre(PocOrientationStrings.presTitre),
          const SizedBox(height: DsfrSpacings.s1w),
        ],
        Text(
          PocOrientationStrings.presTerritoire(marche.ville, marche.nomTerritoire),
          style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
        ),
        if (avecTitre && marche.caRecrute(fiche.code)) ...[
          const SizedBox(height: DsfrSpacings.s2w),
          Align(
            alignment: Alignment.centerLeft,
            child: DsfrBadge(
              label: PocOrientationStrings.caRecrute,
              type: DsfrBadgeType.success,
              size: DsfrComponentSize.sm,
            ),
          ),
        ],
        const SizedBox(height: DsfrSpacings.s2w),
        if (chiffres.offres12Mois case final offres?)
          _Fait(DsfrIcons.businessBriefcaseLine, PocOrientationStrings.presOffres(nombreFrancais(offres))),
        if (chiffres.demandeurs case final demandeurs?)
          _Fait(DsfrIcons.userTeamLine, PocOrientationStrings.presDemandeurs(nombreFrancais(demandeurs))),
        if ((chiffres.salaireMin, chiffres.salaireMax) case (final min?, final max?))
          _Fait(
            DsfrIcons.financeMoneyEuroCircleLine,
            PocOrientationStrings.presSalaire(nombreFrancais(min), nombreFrancais(max)),
          ),
        if (chiffres.partCdi case final cdi?) _Fait(DsfrIcons.documentFileTextLine, PocOrientationStrings.presCdi(cdi)),
        if (chiffres.accesEmploi6Mois case final acces?)
          _Fait(DsfrIcons.businessLineChartLine, PocOrientationStrings.presAcces(acces)),
        if (difficulte != null)
          _Fait(
            DsfrIcons.businessBarChartBoxLine,
            [
              PocOrientationStrings.presDifficulte(difficulte),
              if (difficulte.auMoinsMoyenne && origines.isNotEmpty) PocOrientationStrings.presOrigines(origines),
            ].join(' '),
          ),
        PocLienExterne(
          label: PocOrientationStrings.presVoirDataEmploi,
          onTap: () => launchExternalUrl(marche.lienDataEmploi(fiche.code)),
        ),
        const SizedBox(height: DsfrSpacings.s1w),
        PocMention(PocOrientationStrings.presSource(marche.periodeOffres, marche.nomTerritoire)),
        if (StoreProvider.of<AppState>(context).state.demoState) PocMention(PocOrientationStrings.presDemo),
      ],
    );
  }
}

class _SansChiffres extends StatelessWidget {
  const _SansChiffres({required this.lien, required this.avecTitre});

  final String lien;
  final bool avecTitre;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (avecTitre) ...[
          PocSectionTitre(PocOrientationStrings.presTitre),
          const SizedBox(height: DsfrSpacings.s1w),
        ],
        Text(
          PocOrientationStrings.presSansChiffres,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
        ),
        PocLienExterne(label: PocOrientationStrings.presVoirDataEmploi, onTap: () => launchExternalUrl(lien)),
      ],
    );
  }
}

class _Fait extends StatelessWidget {
  const _Fait(this.icone, this.texte);

  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsfrSpacings.s2w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Icon(icone, size: 20, color: DsfrColorDecisions.textActionHighBlueFrance(context)),
          ),
          const SizedBox(width: DsfrSpacings.s1w),
          Expanded(
            child: Text(texte, style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context))),
          ),
        ],
      ),
    );
  }
}
