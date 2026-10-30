import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/poc_orientation/pages/riasec_resultat_page.dart';
import 'package:pass_emploi_app/poc_orientation/poc_orientation_strings.dart';
import 'package:pass_emploi_app/poc_orientation/riasec.dart';
import 'package:pass_emploi_app/poc_orientation/widgets/poc_widgets.dart';

class TestRiasecPage extends StatefulWidget {
  const TestRiasecPage({super.key});

  static Route<void> route() => MaterialPageRoute(builder: (_) => const TestRiasecPage());

  @override
  State<TestRiasecPage> createState() => _TestRiasecPageState();
}

class _TestRiasecPageState extends State<TestRiasecPage> {
  final _reponses = List<RiasecReponse?>.filled(riasecQuestions.length, null);
  int? _index;

  @override
  Widget build(BuildContext context) {
    final index = _index;
    return PocScaffold(
      titre: PocOrientationStrings.testTitre,
      body: index == null ? _Accueil(onCommencer: () => setState(() => _index = 0)) : _question(index),
    );
  }

  Widget _question(int index) {
    final question = riasecQuestions[index];
    return ListView(
      padding: const EdgeInsets.all(DsfrSpacings.s2w),
      children: [
        DsfrStepper(
          currentStep: index + 1,
          stepsCount: riasecQuestions.length,
          stepTitle: PocOrientationStrings.testConsigne,
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        Semantics(
          liveRegion: true,
          header: true,
          child: Text(
            question.texte,
            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        for (final reponse in RiasecReponse.values) ...[
          SizedBox(
            width: double.infinity,
            child: DsfrButton(
              label: _libelle(reponse),
              variant: _reponses[index] == reponse ? DsfrButtonVariant.primary : DsfrButtonVariant.secondary,
              size: DsfrComponentSize.lg,
              onPressed: () => _repondre(index, reponse),
            ),
          ),
          const SizedBox(height: DsfrSpacings.s2w),
        ],
        if (index > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: DsfrButton(
              label: PocOrientationStrings.testPrecedente,
              icon: DsfrIcons.systemArrowLeftLine,
              variant: DsfrButtonVariant.tertiaryWithoutBorder,
              size: DsfrComponentSize.md,
              onPressed: () => setState(() => _index = index - 1),
            ),
          ),
        const SizedBox(height: DsfrSpacings.s4w),
        PocMention(PocOrientationStrings.testAvertissement),
      ],
    );
  }

  String _libelle(RiasecReponse reponse) {
    return switch (reponse) {
      RiasecReponse.jaime => PocOrientationStrings.testJaime,
      RiasecReponse.caDepend => PocOrientationStrings.testCaDepend,
      RiasecReponse.jaimePas => PocOrientationStrings.testJaimePas,
    };
  }

  void _repondre(int index, RiasecReponse reponse) {
    _reponses[index] = reponse;
    if (index < riasecQuestions.length - 1) {
      setState(() => _index = index + 1);
      return;
    }
    Navigator.pushReplacement(context, RiasecResultatPage.route(RiasecProfil.depuis(_reponses)));
  }
}

class _Accueil extends StatelessWidget {
  const _Accueil({required this.onCommencer});

  final VoidCallback onCommencer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(DsfrSpacings.s2w),
      children: [
        Semantics(
          header: true,
          child: Text(
            PocOrientationStrings.testIntroTitre,
            style: DsfrTextStyle.headline3(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s3w),
        PocPuces(PocOrientationStrings.testIntroPoints),
        const SizedBox(height: DsfrSpacings.s2w),
        Wrap(
          spacing: DsfrSpacings.s1w,
          runSpacing: DsfrSpacings.s1w,
          children: [
            for (final type in Riasec.values)
              DsfrBadge(label: '${type.lettre} · ${type.nom}', type: DsfrBadgeType.information, size: DsfrComponentSize.sm),
          ],
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        DsfrButton(
          label: PocOrientationStrings.testCommencer,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: onCommencer,
        ),
        const SizedBox(height: DsfrSpacings.s4w),
        PocMention(PocOrientationStrings.testAvertissement),
      ],
    );
  }
}
