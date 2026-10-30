import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/poc_orientation/pages/centres_interet_page.dart';
import 'package:pass_emploi_app/poc_orientation/pages/test_riasec_page.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/riasec.dart';
import 'package:pass_emploi_app/poc_orientation/rome_api_client.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';

class RiasecResultatPage extends StatefulWidget {
  const RiasecResultatPage({super.key, required this.profil});

  final RiasecProfil profil;

  static Route<void> route(RiasecProfil profil) => MaterialPageRoute(builder: (_) => RiasecResultatPage(profil: profil));

  @override
  State<RiasecResultatPage> createState() => _RiasecResultatPageState();
}

class _RiasecResultatPageState extends State<RiasecResultatPage> {
  late Future<List<RomeMetierResume>> _metiers = RomeApiClient.instance.metiersAvecRiasec();
  String? _domaine;

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
              header: true,
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
          ],
          const SizedBox(height: DsfrSpacings.s2w),
          PocSectionTitre(PocOrientationStrings.resultatScores),
          const SizedBox(height: DsfrSpacings.s2w),
          for (final type in profil.ordre) _BarreScore(type: type, score: profil.scores[type]!),
          if (!profil.estPlat) ...[
            const SizedBox(height: DsfrSpacings.s4w),
            PocSectionTitre(PocOrientationStrings.resultatMetiersTitre),
            const SizedBox(height: DsfrSpacings.s1w),
            Text(
              PocOrientationStrings.resultatExplication,
              style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            PocFuture<List<RomeMetierResume>>(
              future: _metiers,
              onRetry: () => setState(() => _metiers = RomeApiClient.instance.metiersAvecRiasec()),
              builder: (context, metiers) => _metiersFiltres(profil.metiersCorrespondants(metiers)),
            ),
          ],
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
        header: true,
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
        label: PocOrientationStrings.hubCentresTitre,
        variant: DsfrButtonVariant.primary,
        size: DsfrComponentSize.lg,
        onPressed: () => Navigator.pushReplacement(context, CentresInteretPage.route()),
      ),
    ];
  }

  Widget _metiersFiltres(List<RomeMetierResume> metiers) {
    final parDomaine = <String, int>{};
    for (final metier in metiers) {
      if (metier.grandDomaine case final domaine?) parDomaine[domaine] = (parDomaine[domaine] ?? 0) + 1;
    }
    final domaines = parDomaine.keys.toList()..sort((a, b) => parDomaine[b]!.compareTo(parDomaine[a]!));
    final affiches = _domaine == null ? metiers : metiers.where((metier) => metier.grandDomaine == _domaine).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FiltreDomaine(
                label: PocOrientationStrings.resultatTousLesDomaines(metiers.length),
                selectionne: _domaine == null,
                onTap: () => setState(() => _domaine = null),
              ),
              for (final domaine in domaines)
                _FiltreDomaine(
                  label: PocOrientationStrings.resultatDomaine(domaine, parDomaine[domaine]!),
                  selectionne: _domaine == domaine,
                  onTap: () => setState(() => _domaine = _domaine == domaine ? null : domaine),
                ),
            ],
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        PocListeMetiers(
          key: ValueKey(_domaine),
          metiers: [
            for (final metier in affiches)
              PocMetierAffiche(
                metier,
                [
                  PocOrientationStrings.profilDuMetier(
                    [metier.riasecMajeur, metier.riasecMineur]
                        .map(Riasec.deLettre)
                        .nonNulls
                        .map((type) => type.nom)
                        .toList(),
                  ),
                  if (metier.grandDomaine case final domaine?) domaine,
                ].join(' · '),
              ),
          ],
        ),
      ],
    );
  }
}

class _FiltreDomaine extends StatelessWidget {
  const _FiltreDomaine({required this.label, required this.selectionne, required this.onTap});

  final String label;
  final bool selectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: DsfrSpacings.s1w),
      child: DsfrTag(
        label: label,
        size: DsfrComponentSize.sm,
        isSelected: selectionne,
        onSelectionChanged: (_) => onTap(),
      ),
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
