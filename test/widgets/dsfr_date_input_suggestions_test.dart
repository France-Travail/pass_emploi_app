import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/presentation/model/date_input_source.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_date_input_suggestions.dart';

void main() {
  Future<void> pump(WidgetTester tester, {DateInputSource? dateSource, bool isInvalid = false}) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('fr', 'FR')],
        home: Scaffold(
          body: ListView(
            children: [
              DsfrDateInputSuggestions(
                label: 'Date (obligatoire)',
                hintText: 'Format jj/mm/aaaa',
                dateSource: dateSource ?? DateNotInitialized(),
                isInvalid: isInvalid,
                onDateChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('A11y 9.1 / 9.2 : le champ date porte son étiquette visible et son aide', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    final champ = tester.getSemantics(find.byType(TextField));
    expect(champ, isSemantics(isTextField: true));
    expect(champ.label, 'Date (obligatoire)');
    expect(champ.hint, 'Format jj/mm/aaaa');
    semantics.dispose();
  });

  testWidgets('A11y 9.1 : l’étiquette n’est pas restituée à part du champ', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    final noeudsEtiquette = find.semantics.byLabel('Date (obligatoire)').evaluate();
    expect(noeudsEtiquette, hasLength(1));
    expect(noeudsEtiquette.single, isSemantics(isTextField: true));
    semantics.dispose();
  });

  testWidgets('A11y 9.9 : le message d’erreur est restitué avec le champ', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, isInvalid: true);

    expect(tester.getSemantics(find.byType(TextField)).label, contains(Strings.dateMandatory));
    semantics.dispose();
  });

  testWidgets('A11y 9.6 : chaque suggestion reprend l’étiquette du champ après son libellé', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    for (final suggestion in [Strings.dateSuggestionAujourdhui, Strings.dateSuggestionDemain]) {
      expect(find.bySemanticsLabel(RegExp('^$suggestion \\(.*\\), Date \\(obligatoire\\)\$')), findsOneWidget);
    }
    semantics.dispose();
  });

  testWidgets('les suggestions restent des boutons distincts du champ', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    final demain = find.bySemanticsLabel(RegExp('^${Strings.dateSuggestionDemain}'));
    expect(demain, findsOneWidget);
    expect(tester.getSemantics(demain), isSemantics(isButton: true, hasSelectedState: true));
    expect(tester.getSemantics(find.byType(TextField)).label, isNot(contains(Strings.dateSuggestionDemain)));
    semantics.dispose();
  });
}
