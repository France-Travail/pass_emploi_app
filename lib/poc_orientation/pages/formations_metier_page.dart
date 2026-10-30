import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_state.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/poc_orientation/inserjeunes.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/location_autocomplete.dart';

class FormationsMetierPage extends StatefulWidget {
  const FormationsMetierPage({super.key, required this.fiche});

  final RomeFicheMetier fiche;

  static Route<void> route(RomeFicheMetier fiche) => MaterialPageRoute(builder: (_) => FormationsMetierPage(fiche: fiche));

  @override
  State<FormationsMetierPage> createState() => _FormationsMetierPageState();
}

class _FormationsMetierPageState extends State<FormationsMetierPage> {
  late final _motsCles = motsClesFormation(widget.fiche);
  Location? _lieu;
  bool _toutLeTerritoire = false;
  bool _lieuInitialise = false;
  Future<List<FormationInserJeunes>>? _formations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lieuInitialise) return;
    _lieuInitialise = true;
    _lieu = StoreProvider.of<AppState>(context).getLastLocationSelected(allowDepartment: true);
    _charger();
  }

  void _charger() {
    final departement = departementDe(_lieu);
    _formations = departement == null && !_toutLeTerritoire
        ? null
        : InserJeunesClient.instance.formations(
            motsCles: _motsCles,
            departement: _toutLeTerritoire ? null : departement,
          );
  }

  @override
  Widget build(BuildContext context) {
    final formations = _formations;
    return PocScaffold(
      titre: PocOrientationStrings.formationsTitre,
      body: ListView(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        children: [
          Semantics(
            header: true,
            child: Text(
              widget.fiche.libelle,
              style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s1w),
          Text(
            PocOrientationStrings.formationsIntro,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
          const SizedBox(height: DsfrSpacings.s3w),
          LocationAutocomplete(
            title: PocOrientationStrings.formationsLieu,
            hint: PocOrientationStrings.formationsLieuAide,
            initialValue: _lieu,
            onLocationSelected: (lieu) => setState(() {
              _lieu = lieu;
              _toutLeTerritoire = false;
              _charger();
            }),
          ),
          const SizedBox(height: DsfrSpacings.s3w),
          if (formations == null) ...[
            Text(
              PocOrientationStrings.formationsChoisirLieu,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
            ),
            _boutonToutLeTerritoire(),
          ] else
            PocFuture<List<FormationInserJeunes>>(
              future: formations,
              onRetry: () => setState(_charger),
              builder: (context, resultats) => _resultats(context, resultats),
            ),
        ],
      ),
    );
  }

  Widget _boutonToutLeTerritoire() {
    return Align(
      alignment: Alignment.centerLeft,
      child: DsfrButton(
        label: PocOrientationStrings.formationsToutLeTerritoire,
        variant: DsfrButtonVariant.tertiaryWithoutBorder,
        size: DsfrComponentSize.md,
        onPressed: () => setState(() {
          _toutLeTerritoire = true;
          _charger();
        }),
      ),
    );
  }

  Widget _resultats(BuildContext context, List<FormationInserJeunes> formations) {
    if (formations.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            PocOrientationStrings.formationsAucune,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
          if (!_toutLeTerritoire) _boutonToutLeTerritoire(),
        ],
      );
    }
    final parDiplome = <String, List<FormationInserJeunes>>{};
    for (final formation in formations) {
      parDiplome.putIfAbsent(formation.cleDiplome, () => []).add(formation);
    }
    final diplomes = parDiplome.values.toList()
      ..sort((a, b) {
        final ecart = a.first.rangDiplome.compareTo(b.first.rangDiplome);
        return ecart != 0 ? ecart : a.first.diplome.compareTo(b.first.diplome);
      });
    final annee = formations.map((formation) => formation.annee).reduce((a, b) => a.compareTo(b) >= 0 ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final diplome in diplomes) ...[
          PocSectionTitre(diplome.first.diplome),
          const SizedBox(height: DsfrSpacings.s1w),
          for (final formation in diplome..sort(_resultatsPublieDabord)) _LigneFormation(formation: formation),
          const SizedBox(height: DsfrSpacings.s3w),
        ],
        PocMention(PocOrientationStrings.formationsSource(annee)),
      ],
    );
  }

  static int _resultatsPublieDabord(FormationInserJeunes a, FormationInserJeunes b) {
    if (a.aDesResultats != b.aDesResultats) return a.aDesResultats ? -1 : 1;
    final ecartEmploi = (b.tauxEmploi6Mois ?? -1).compareTo(a.tauxEmploi6Mois ?? -1);
    return ecartEmploi != 0 ? ecartEmploi : (b.tauxPoursuiteEtudes ?? -1).compareTo(a.tauxPoursuiteEtudes ?? -1);
  }
}

class _LigneFormation extends StatelessWidget {
  const _LigneFormation({required this.formation});

  final FormationInserJeunes formation;

  @override
  Widget build(BuildContext context) {
    final chiffres = [
      if (formation.tauxEmploi6Mois case final taux?) PocOrientationStrings.formationsEmploi(taux.round()),
      if (formation.tauxPoursuiteEtudes case final taux? when taux > 0)
        PocOrientationStrings.formationsPoursuite(taux.round()),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: DsfrColorDecisions.borderDefaultGrey(context))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s2w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formation.etablissement,
              style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s1v),
            Text(
              formation.apprentissage
                  ? PocOrientationStrings.formationsApprentissage
                  : PocOrientationStrings.formationsLyceePro,
              style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            if (chiffres.isEmpty)
              Text(
                PocOrientationStrings.formationsNonPublie,
                style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
              )
            else
              for (final chiffre in chiffres)
                Text(chiffre, style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textActionHighBlueFrance(context))),
          ],
        ),
      ),
    );
  }
}
