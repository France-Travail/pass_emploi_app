import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/poc_orientation/marche_travail.dart';
import 'package:pass_emploi_app/poc_orientation/mes_pistes.dart';
import 'package:pass_emploi_app/poc_orientation/pages/centres_interet_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/test_riasec_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/tri_page.dart';
import 'package:pass_emploi_app/poc_orientation/parcours.dart';
import 'package:pass_emploi_app/poc_orientation/pistes_pour_toi.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/riasec.dart';
import 'package:pass_emploi_app/poc_orientation/rome_api_client.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

// Le résultat du test : le profil, puis ses métiers les plus proches qui rejoignent le tri. Revu plus tard
// (« Revoir mes résultats »), il ne rajoute rien.
class RiasecResultatPage extends StatefulWidget {
  const RiasecResultatPage({super.key, required this.profil, this.nouveauTest = false});

  final RiasecProfil profil;
  final bool nouveauTest;

  static Route<void> route(RiasecProfil profil, {bool nouveauTest = false}) {
    return MaterialPageRoute(builder: (_) => RiasecResultatPage(profil: profil, nouveauTest: nouveauTest));
  }

  @override
  State<RiasecResultatPage> createState() => _RiasecResultatPageState();
}

class _RiasecResultatPageState extends State<RiasecResultatPage> {
  late final bool _demo;
  Future<int>? _ajoutes;

  @override
  void initState() {
    super.initState();
    _demo = StoreProvider.of<AppState>(context, listen: false).state.demoState;
    // Le résultat est gardé avec les pistes : le jeune le retrouve, et peut le partager à son conseiller.
    MesPistes.instance.enregistrerProfilRiasec(widget.profil.scores);
    if (widget.nouveauTest && !widget.profil.estPlat) _ajoutes = _ajouterAuTri();
  }

  // En démo, seuls les métiers dont la fiche est dans la démo rejoignent le tri (aucun appel réseau).
  Future<int> _ajouterAuTri() async {
    final metiers = await RomeApiClient.instance.metiersAvecRiasec();
    final candidats = _demo ? metiers.where((metier) => aUneFicheDeDemo(metier.code)).toList() : metiers;
    final choisis = metiersDuTest(widget.profil, candidats, MesPistes.instance.value);
    MesPistes.instance.ajouterAuTri(
      SourceAjout.test,
      choisis,
      PocOrientationStrings.listeNaturelle(widget.profil.dominants.map((type) => type.nom).toList()),
    );
    return choisis.length;
  }

  @override
  Widget build(BuildContext context) {
    final profil = widget.profil;
    return PocScaffold(
      titre: PocOrientationStrings.resultatTitre,
      body: ListView(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        children: [
          if (profil.estPlat)
            ..._profilPlat(context)
          else ...[
            Semantics(
              headingLevel: 1,
              child: Text(
                PocOrientationStrings.resultatProfil(
                  profil.dominants.map((type) => type.nom).toList(),
                  egaliteEnTete: profil.egaliteEnTete,
                ),
                style: DsfrTextStyle.headline3(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ),
            const SizedBox(height: DsfrSpacings.s3w),
            for (final type in profil.dominants) ...[
              _CarteType(type: type),
              const SizedBox(height: DsfrSpacings.s2w),
            ],
            if (_ajoutes case final ajoutes?) ...[
              const SizedBox(height: DsfrSpacings.s1w),
              PocFuture<int>(
                future: ajoutes,
                onRetry: () => setState(() => _ajoutes = _ajouterAuTri()),
                builder: (context, nombre) => _MetiersAjoutes(nombre: nombre, demo: _demo),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
            ],
          ],
          const SizedBox(height: DsfrSpacings.s2w),
          PocSectionTitre(PocOrientationStrings.resultatScores),
          const SizedBox(height: DsfrSpacings.s2w),
          for (final type in profil.ordre) _BarreScore(type: type, score: profil.scores[type]!),
          const SizedBox(height: DsfrSpacings.s3w),
          Align(
            alignment: Alignment.centerLeft,
            child: DsfrButton(
              label: PocOrientationStrings.resultatRefaire,
              icon: DsfrIcons.systemRefreshLine,
              variant: DsfrButtonVariant.tertiary,
              size: DsfrComponentSize.md,
              onPressed: () => Navigator.pushReplacement(context, TestRiasecPage.route()),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s3w),
          PocMention(PocOrientationStrings.testAvertissement),
          const SizedBox(height: DsfrSpacings.s1w),
          PocMention(PocOrientationStrings.sourceRome),
        ],
      ),
    );
  }

  List<Widget> _profilPlat(BuildContext context) {
    return [
      Semantics(
        headingLevel: 1,
        child: Text(
          PocOrientationStrings.resultatPlatTitre,
          style: DsfrTextStyle.headline3(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
      ),
      const SizedBox(height: DsfrSpacings.s2w),
      Text(
        PocOrientationStrings.resultatPlatTexte,
        style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
      ),
      const SizedBox(height: DsfrSpacings.s3w),
      DsfrButton(
        label: PocOrientationStrings.ideesCentres,
        variant: DsfrButtonVariant.primary,
        size: DsfrComponentSize.lg,
        onPressed: () => Navigator.pushReplacement(context, CentresInteretPage.route()),
      ),
    ];
  }
}

class _MetiersAjoutes extends StatelessWidget {
  const _MetiersAjoutes({required this.nombre, required this.demo});

  final int nombre;
  final bool demo;

  @override
  Widget build(BuildContext context) {
    if (nombre == 0) {
      return DsfrAlert(
        type: DsfrAlertType.info,
        description: DsfrAlertDescriptionText(PocOrientationStrings.resultatAucunAjout),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsfrAlert(
          type: DsfrAlertType.success,
          title: PocOrientationStrings.resultatAjoutes(nombre),
          description: DsfrAlertDescriptionText(PocOrientationStrings.resultatAjoutesTexte),
        ),
        if (demo) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          PocMention(PocOrientationStrings.demoMetiersAjoutes),
        ],
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: PocOrientationStrings.faireLeTri,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: () => Navigator.push(context, TriPage.route(dAbord: SourcePiste.test)),
        ),
      ],
    );
  }
}

class _CarteType extends StatelessWidget {
  const _CarteType({required this.type});

  final Riasec type;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  type.lettre,
                  style: DsfrTextStyle.bodyLgBold(color: DsfrColorDecisions.textInvertedBlueFrance(context)),
                ),
              ),
            ),
            const SizedBox(width: DsfrSpacings.s2w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.nom, style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context))),
                  const SizedBox(height: DsfrSpacings.s1v),
                  Text(
                    type.description,
                    style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarreScore extends StatelessWidget {
  const _BarreScore({required this.type, required this.score});

  final Riasec type;
  final int score;

  @override
  Widget build(BuildContext context) {
    final style = DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context));
    return Semantics(
      label: '${type.nom} : $score sur ${RiasecProfil.scoreMaximum}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: DsfrSpacings.s1w),
        child: Row(
          children: [
            SizedBox(width: 112, child: Text(type.nom, style: style)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: score / RiasecProfil.scoreMaximum,
                  minHeight: 8,
                  color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
                  backgroundColor: DsfrColorDecisions.backgroundContrastGrey(context),
                ),
              ),
            ),
            const SizedBox(width: DsfrSpacings.s1w),
            SizedBox(
              width: 40,
              child: Text('$score/${RiasecProfil.scoreMaximum}', style: style, textAlign: TextAlign.end),
            ),
          ],
        ),
      ),
    );
  }
}
