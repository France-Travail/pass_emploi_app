import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/alerte/list/alerte_list_state.dart';
import 'package:pass_emploi_app/pages/alerte_page.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

import '../dsl/app_state_dsl.dart';

void main() {
  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final state = givenState().loggedIn().withSuggestionsRecherche().copyWith(alerteListState: AlerteListSuccessState([]));
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: state.spyStore(),
        child: MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('fr', 'FR')],
          home: Scaffold(body: AlertePage()),
        ),
      ),
    );
  }

  group('Suggestions d’alertes', () {
    testWidgets('A11y : le contenu d’une carte est restitué en un seul élément, titre de la carte', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);

      final carte = tester.getSemantics(
        find.bySemanticsLabel('Cariste, Emploi, Source : Profil France Travail, Localisation : Nord'),
      );
      expect(carte.headingLevel, 3);
      // Les tags et la localisation ne sont pas des éléments à part.
      for (final texte in ['Cariste', 'Emploi', 'Profil France Travail', 'Nord']) {
        expect(find.bySemanticsLabel(texte), findsNothing, reason: '« $texte » restitué à part');
      }
      expect(find.bySemanticsLabel('Refuser la suggestion d’alerte Cariste'), findsOneWidget);
      expect(find.bySemanticsLabel('Ajouter l’alerte Cariste'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('A11y : la source « Conseiller » et la localisation sont restituées', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);

      expect(
        find.bySemanticsLabel('Boulanger, Immersion, Source : Conseiller, Localisation : Valence'),
        findsOneWidget,
      );
      semantics.dispose();
    });
  });
}
