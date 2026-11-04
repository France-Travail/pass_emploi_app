import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/presentation/model/date_input_source.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/date_pickers/past_date_choice.dart';

void main() {
  Future<List<DateInputSource>> pump(WidgetTester tester, {String? aide}) async {
    final changes = <DateInputSource>[];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('fr', 'FR')],
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

  testWidgets('A11y 9.6 : la légende n’est pas un titre et chaque choix reprend la légende du groupe', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    expect(tester.getSemantics(find.text('Quand ?')), isNot(containsSemantics(isHeader: true)));
    expect(find.bySemanticsLabel(RegExp('^${Strings.dateSuggestionHier} \\(.*\\), Quand \\?\$')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^${Strings.dateSuggestionAujourdhui} \\(.*\\), Quand \\?\$')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('A11y 9.2 et 5.1 : « Autre date » est un bouton nommé par son étiquette, avec la légende et l’aide', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, aide: Strings.cannotFinishActionInFuture);

    final champ = tester.getSemantics(find.byType(OtherDateButton));
    expect(champ.label, '${Strings.otherDate}, Quand ?');
    expect(champ.hint, Strings.cannotFinishActionInFuture);
    expect(champ, containsSemantics(isButton: true, hasTapAction: true));
    expect(find.byType(TextField), findsNothing);
    semantics.dispose();
  });

  testWidgets('A11y 9.2 : la date choisie est restituée comme valeur de « Autre date »', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    await tester.tap(find.text(Strings.dateSuggestionHier));
    await tester.pump();

    final champ = tester.getSemantics(find.byType(OtherDateButton));
    expect(champ.value, isNotEmpty);
    expect(champ.value, isNot(contains('/')));
    semantics.dispose();
  });

  testWidgets('A11y 5.2 : « Autre date » s’atteint et s’active au clavier', (tester) async {
    await pump(tester);

    // Tab : Aujourd'hui, Hier, puis Autre date.
    for (var i = 0; i < 3; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('toucher l’étiquette « Autre date » ouvre le calendrier', (tester) async {
    await pump(tester);

    await tester.tap(find.text(Strings.otherDate));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
