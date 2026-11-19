import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/widgets/radio_list_tile.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required int? groupValue, String? groupLabel}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              CustomRadioGroup<int>(
                title: 'Atelier',
                groupLabel: groupLabel,
                value: 1,
                groupValue: groupValue,
                onChanged: (_) {},
              ),
              CustomRadioGroup<int>(
                title: 'Forum',
                groupLabel: groupLabel,
                value: 2,
                groupValue: groupValue,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('A11y 9.6 : chaque choix reprend le nom du groupe après son libellé visible', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, groupValue: 1, groupLabel: 'Type d’événements');

    expect(find.bySemanticsLabel('Atelier, Type d’événements'), findsOneWidget);
    expect(find.bySemanticsLabel('Forum, Type d’événements'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('sans nom de groupe, le nom est le libellé visible', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, groupValue: 1);

    expect(find.bySemanticsLabel('Atelier'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('A11y 5.1 / 5.5 : bouton radio natif, état coché ou non, sans état écrit dans le nom', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, groupValue: 1, groupLabel: 'Type d’événements');

    final atelier = tester.getSemantics(find.bySemanticsLabel('Atelier, Type d’événements'));
    final forum = tester.getSemantics(find.bySemanticsLabel('Forum, Type d’événements'));
    expect(
      atelier,
      isSemantics(
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    expect(forum, isSemantics(hasCheckedState: true, isChecked: false, isInMutuallyExclusiveGroup: true));
    expect(atelier, isNot(isSemantics(isButton: true)));
    expect(atelier.label, isNot(contains('électionné')));
    semantics.dispose();
  });
}
