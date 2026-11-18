import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';

String _nombre(int nombre) => NumberFormat.decimalPattern('fr_FR').format(nombre);

// « Ça recrute près de chez toi ? » : les chiffres du métier autour de la ville de recherche du questionnaire.
// En démo, chiffres relevés sur Data Emploi (aucun appel réseau). Pour un vrai compte, le POC n'a pas l'API Marché du
// travail : il propose seulement la page Data Emploi du métier pour le département du jeune.
class PresDeChezToi extends StatefulWidget {
  const PresDeChezToi({super.key, required this.fiche});

  final RomeFicheMetier fiche;

  @override
  State<PresDeChezToi> createState() => _PresDeChezToiState();
}

class _PresDeChezToiState extends State<PresDeChezToi> {
  late final Future<MarcheTravail?> _marche;

  @override
  void initState() {
    super.initState();
    final demo = StoreProvider.of<AppState>(context, listen: false).state.demoState;
    _marche = demo ? MarcheTravailDemo.charger() : Future.value(null);
  }

  @override
  Widget build(BuildContext context) {
    final questionnaire = StoreProvider.of<AppState>(context).state.onboardingQuestionnaireState;
    final reponses = questionnaire is OnboardingQuestionnaireSuccessState ? questionnaire.answers : null;
    final commune = reponses?.villeRecherche ?? reponses?.habitation;
    return FutureBuilder<MarcheTravail?>(
      future: _marche,
      builder: (context, snapshot) {
        final marche = snapshot.data;
        if (marche != null && (commune == null || commune.code == marche.codeInseeVille)) {
          return _AvecChiffres(fiche: widget.fiche, marche: marche);
        }
        final departement = departementDe(commune?.code);
        if (snapshot.connectionState != ConnectionState.done || departement == null) return const SizedBox.shrink();
        return _SansChiffres(lien: lienDataEmploiMetier('DEP', departement, widget.fiche.code));
      },
    );
  }
}

class _AvecChiffres extends StatelessWidget {
  const _AvecChiffres({required this.fiche, required this.marche});

  final RomeFicheMetier fiche;
  final MarcheTravail marche;

  @override
  Widget build(BuildContext context) {
    final chiffres = marche.chiffres(fiche.code);
    final lien = marche.lienDataEmploi(fiche.code);
    if (chiffres == null) return _SansChiffres(lien: lien);
    final difficulte = chiffres.difficulte;
    final origines = chiffres.principalesOrigines;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PocSectionTitre(PocOrientationStrings.presTitre),
        const SizedBox(height: DsfrSpacings.s1w),
        Text(
          PocOrientationStrings.presTerritoire(marche.ville, marche.nomTerritoire),
          style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
        ),
        if (marche.caRecrute(fiche.code)) ...[
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
          _Fait(DsfrIcons.businessBriefcaseLine, PocOrientationStrings.presOffres(_nombre(offres))),
        if (chiffres.demandeurs case final demandeurs?)
          _Fait(DsfrIcons.userTeamLine, PocOrientationStrings.presDemandeurs(_nombre(demandeurs))),
        if ((chiffres.salaireMin, chiffres.salaireMax) case (final min?, final max?))
          _Fait(
            DsfrIcons.financeMoneyEuroCircleLine,
            PocOrientationStrings.presSalaire(_nombre(min), _nombre(max)),
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
        PocLienExterne(label: PocOrientationStrings.presVoirDataEmploi, onTap: () => launchExternalUrl(lien)),
        const SizedBox(height: DsfrSpacings.s1w),
        PocMention(PocOrientationStrings.presSource(marche.periodeOffres, marche.nomTerritoire)),
        if (StoreProvider.of<AppState>(context).state.demoState) PocMention(PocOrientationStrings.presDemo),
      ],
    );
  }
}

class _SansChiffres extends StatelessWidget {
  const _SansChiffres({required this.lien});

  final String lien;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PocSectionTitre(PocOrientationStrings.presTitre),
        const SizedBox(height: DsfrSpacings.s1w),
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
