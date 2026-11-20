import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_checkbox_rich.dart';
import 'package:pass_emploi_app/widgets/a11y/group_label_semantics.dart';

void main() {
  Widget radio(String label, int value, {int? groupValue = 1}) => DsfrRadioButton<int>(
        label: label,
        value: value,
        groupValue: groupValue,
        size: DsfrComponentSize.md,
        onChanged: (_) {},
      );

  Future<void> pump(WidgetTester tester, List<Widget> children) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ),
    );
  }

  /// Nom transmis à TalkBack / VoiceOver : celui du nœud fusionné, avec ses descendants.
  String nomRestitue(WidgetTester tester, Finder finder) => tester.getSemantics(finder).getSemanticsData().label;

  testWidgets('A11y 9.6 : le nom d’un radio DSFR est son libellé visible suivi du nom du groupe', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, [
      GroupLabelSemantics(groupLabel: 'Où en es-tu ?', child: radio('J’ai postulé', 1)),
      GroupLabelSemantics(groupLabel: 'Où en es-tu ?', child: radio('Ça m’intéresse', 2)),
    ]);

    final radios = find.byType(DsfrRadioButton<int>);
    expect(nomRestitue(tester, radios.at(0)), 'J’ai postulé\nOù en es-tu ?');
    expect(nomRestitue(tester, radios.at(1)), 'Ça m’intéresse\nOù en es-tu ?');
    semantics.dispose();
  });

  testWidgets('le rôle, l’état et l’action du radio sont conservés', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, [
      GroupLabelSemantics(groupLabel: 'Où en es-tu ?', child: radio('J’ai postulé', 1)),
      GroupLabelSemantics(groupLabel: 'Où en es-tu ?', child: radio('Ça m’intéresse', 2)),
    ]);

    final radios = find.byType(DsfrRadioButton<int>);
    expect(
      tester.getSemantics(radios.at(0)),
      isSemantics(hasCheckedState: true, isChecked: true, isInMutuallyExclusiveGroup: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(radios.at(1)),
      isSemantics(hasCheckedState: true, isChecked: false, isInMutuallyExclusiveGroup: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('radio riche avec description : libellé, description, puis nom du groupe', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, [
      GroupLabelSemantics(
        groupLabel: 'Où en es-tu ?',
        child: DsfrRadioRichButton<int>(
          title: 'Au lycée',
          description: 'En seconde',
          value: 1,
          groupValue: 1,
          size: DsfrComponentSize.md,
          isExpanded: true,
          onChanged: (_) {},
        ),
      ),
    ]);

    final choix = find.byType(DsfrRadioRichButton<int>);
    expect(nomRestitue(tester, choix), 'Au lycée\nEn seconde\nOù en es-tu ?');
    expect(tester.getSemantics(choix), isSemantics(hasCheckedState: true, isChecked: true, hasTapAction: true));
    semantics.dispose();
  });

  testWidgets('case à cocher qui fournit son propre nœud : le nom du groupe reste après le libellé', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, [
      GroupLabelSemantics(
        groupLabel: 'Comment peut-on t’aider ?',
        child: OnboardingQuestionnaireCheckboxRich(
          label: 'Trouver un emploi',
          value: true,
          size: DsfrComponentSize.md,
          onChanged: (_) {},
        ),
      ),
    ]);

    final choix = find.byType(OnboardingQuestionnaireCheckboxRich);
    expect(nomRestitue(tester, choix), 'Trouver un emploi\nComment peut-on t’aider ?');
    expect(tester.getSemantics(choix), isSemantics(hasCheckedState: true, isChecked: true, hasTapAction: true));
    semantics.dispose();
  });

  testWidgets('la mise en page du choix est inchangée', (tester) async {
    await pump(tester, [radio('J’ai postulé', 1)]);
    final sansGroupe = tester.getSize(find.byType(DsfrRadioButton<int>));

    await pump(tester, [GroupLabelSemantics(groupLabel: 'Où en es-tu ?', child: radio('J’ai postulé', 1))]);
    final avecGroupe = tester.getSize(find.byType(DsfrRadioButton<int>));

    expect(avecGroupe, sansGroupe);
    expect(tester.getSize(find.byType(GroupLabelSemantics)), sansGroupe);
  });
}
