import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_date_picker_field.dart';

void main() {
  late TextEditingController controller;
  late List<DateTime> changes;

  setUp(() {
    controller = TextEditingController();
    changes = [];
  });

  Future<void> pump(
    WidgetTester tester, {
    bool enabled = true,
    String? groupLabel,
    String? hintText,
    DsfrComponentState composantState = const DsfrComponentState.none(),
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('fr', 'FR')],
        home: Scaffold(
          body: ListView(
            children: [
              DsfrDatePickerField(
                label: 'Date de début',
                groupLabel: groupLabel,
                hintText: hintText,
                controller: controller,
                enabled: enabled,
                composantState: composantState,
                firstDate: DateTime(2026, 1, 1),
                lastDate: DateTime(2026, 12, 31),
                initialDate: DateTime(2026, 11, 19),
                onChanged: changes.add,
              ),
            ],
          ),
        ),
      ),
    );
  }

  SemanticsNode champ(WidgetTester tester) => tester.getSemantics(find.byType(DsfrDatePickerField));

  testWidgets('A11y 5.1 / 9.1 / 9.6 : un seul bouton, nommé par son étiquette puis le nom du groupe', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, groupLabel: 'Période', hintText: 'Format jj/mm/aaaa');

    expect(
      champ(tester),
      isSemantics(
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        label: 'Date de début, Période',
        hint: 'Format jj/mm/aaaa',
      ),
    );
    expect(find.byType(TextField), findsOneWidget, reason: 'apparence du champ DSFR conservée');
    expect(find.semantics.byFlag(SemanticsFlag.isTextField), findsNothing, reason: 'plus de champ de saisie sans nom');
    semantics.dispose();
  });

  testWidgets('A11y 5.1 : désactivé, le bouton porte lui-même l’état et n’a pas d’action', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, enabled: false, groupLabel: 'Date de début');

    expect(
      champ(tester),
      isSemantics(isButton: true, hasEnabledState: true, isEnabled: false, hasTapAction: false),
    );
    semantics.dispose();
  });

  testWidgets('A11y 9.9 : le message d’erreur fait partie du nom', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, composantState: const DsfrComponentState.error(errorMessage: 'La date est obligatoire'));

    expect(champ(tester).label, 'Date de début, La date est obligatoire');
    semantics.dispose();
  });

  testWidgets('la date choisie est la valeur du bouton, lue en toutes lettres', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);
    expect(champ(tester).value, isEmpty);

    controller.text = '20/11/2026';
    await tester.pump();

    expect(champ(tester).value, isNotEmpty);
    expect(champ(tester).value, isNot(contains('/')));
    semantics.dispose();
  });

  testWidgets('l’action « toucher » du lecteur d’écran ouvre le calendrier et enregistre la date', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    tester.semantics.tap(find.semantics.byLabel('Date de début'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.tap(find.text('20'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(changes, [DateTime(2026, 11, 20)]);
    expect(controller.text, '20/11/2026');
    semantics.dispose();
  });
}
