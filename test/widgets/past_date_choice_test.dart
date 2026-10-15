import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/presentation/model/date_input_source.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/date_pickers/past_date_choice.dart';

void main() {
  Future<List<DateInputSource>> pump(WidgetTester tester, {String? aide}) async {
    final changes = <DateInputSource>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PastDateChoice(title: 'Quand ?', aide: aide, onDateChanged: changes.add),
        ),
      ),
    );
    return changes;
  }

  testWidgets('affiche le titre et les suggestions Hier / Aujourd’hui', (tester) async {
    await pump(tester);

    expect(find.text('Quand ?'), findsOneWidget);
    expect(find.text(Strings.dateSuggestionHier), findsOneWidget);
    expect(find.text(Strings.dateSuggestionAujourdhui), findsOneWidget);
    expect(find.text(Strings.otherDate), findsOneWidget);
  });

  testWidgets('choisir Hier remonte la date d’hier', (tester) async {
    final changes = await pump(tester);

    await tester.tap(find.text(Strings.dateSuggestionHier));
    await tester.pump();

    final yesterday = DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 1)));
    expect(DateUtils.dateOnly(changes.last.selectedDate), yesterday);
    expect(changes.last.isValid, isTrue);
  });

  testWidgets('sans aide, le texte d’aide n’est pas affiché', (tester) async {
    await pump(tester);

    expect(find.text(Strings.cannotFinishActionInFuture), findsNothing);
  });

  testWidgets('avec aide, le texte d’aide est affiché', (tester) async {
    await pump(tester, aide: 'X');

    expect(find.text('X'), findsOneWidget);
  });

  testWidgets('A11y 5.5 : la suggestion choisie est restituée comme sélectionnée', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);
    final hier = find.bySemanticsLabel(RegExp('^${Strings.dateSuggestionHier} \\('));

    expect(tester.getSemantics(hier), containsSemantics(isButton: true, hasSelectedState: true, isSelected: false));

    await tester.tap(find.text(Strings.dateSuggestionHier));
    await tester.pump();

    expect(tester.getSemantics(hier), containsSemantics(isButton: true, hasSelectedState: true, isSelected: true));
    semantics.dispose();
  });

  testWidgets('A11y 9.2 et 5.1 : le champ « Autre date » porte son libellé, son aide et un rôle de bouton', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, aide: Strings.cannotFinishActionInFuture);

    final champ = tester.getSemantics(find.byType(TextField));
    expect(champ.label, Strings.otherDate);
    expect(champ.hint, Strings.cannotFinishActionInFuture);
    expect(champ, containsSemantics(isButton: true, hasTapAction: true));
    semantics.dispose();
  });
}
