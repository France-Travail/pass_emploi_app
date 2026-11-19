import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_selectable_card.dart';

void main() {
  Future<void> pump(WidgetTester tester, {String? groupLabel}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              DsfrSelectableCard(label: 'Par téléphone', selected: true, groupLabel: groupLabel, onTap: () {}),
              DsfrSelectableCard(label: 'Par e-mail', groupLabel: groupLabel, onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }

  String nomRestitue(WidgetTester tester, String libelle) =>
      tester.getSemantics(find.text(libelle)).getSemanticsData().label;

  testWidgets('A11y 9.6 : avec un groupe, le nom est le libellé suivi de la consigne du groupe', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, groupLabel: 'Comment');

    expect(nomRestitue(tester, 'Par téléphone'), 'Par téléphone\nComment');
    expect(nomRestitue(tester, 'Par e-mail'), 'Par e-mail\nComment');
    expect(
      tester.getSemantics(find.text('Par téléphone')),
      isSemantics(isButton: true, hasSelectedState: true, isSelected: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('sans groupe, le nom est le libellé visible', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    expect(nomRestitue(tester, 'Par téléphone'), 'Par téléphone');
    semantics.dispose();
  });
}
