import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/evenement_emploi/evenement_emploi_type.dart';
import 'package:pass_emploi_app/pages/evenement_emploi/evenement_emploi_filtres_page.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';

import '../doubles/fixtures.dart';
import '../dsl/app_state_dsl.dart';

void main() {
  Future<void> pump(WidgetTester tester) async {
    final store = givenState().successRechercheEvenementEmploiState(results: [mockEvenementEmploi()]).store();
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('fr', 'FR')],
          home: Scaffold(body: EvenementEmploiFiltresPage()),
        ),
      ),
    );
  }

  testWidgets('A11y 9.6 : les choix de « Type d’événements » reprennent le nom du groupe', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    final groupe = Strings.evenementEmploiFiltresType;
    expect(find.bySemanticsLabel('${Strings.evenementEmploiTypeAll}, $groupe'), findsOneWidget);
    for (final type in EvenementEmploiType.values) {
      expect(find.bySemanticsLabel('${type.label}, $groupe'), findsOneWidget);
    }
    semantics.dispose();
  });

  testWidgets('A11y 9.6 : les choix de « Modalités d’accès » reprennent le nom du groupe', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    final groupe = Strings.evenementEmploiFiltresModalites;
    expect(find.bySemanticsLabel('${Strings.evenementEmploiModaliteEnPhysique}, $groupe'), findsOneWidget);
    expect(find.bySemanticsLabel('${Strings.evenementEmploiModaliteADistance}, $groupe'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('A11y 5.1 / 9.1 / 9.6 : les champs de la « Période » sont des boutons nommés avec la section', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    final periode = Strings.evenementEmploiFiltresDate;
    for (final etiquette in [Strings.evenementEmploiFiltresDateDebut, Strings.evenementEmploiFiltresDateFin]) {
      expect(
        tester.getSemantics(find.bySemanticsLabel('$etiquette, $periode')),
        isSemantics(isButton: true, hasTapAction: true, hasEnabledState: true, isEnabled: true),
      );
    }
    semantics.dispose();
  });
}
