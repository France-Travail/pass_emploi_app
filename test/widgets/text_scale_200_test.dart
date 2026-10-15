import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/comptage_des_heures_card.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_navigation.dart';
import 'package:pass_emploi_app/widgets/dsfr/emoji_solution_tile.dart';
import 'package:redux/redux.dart';

import '../doubles/fixtures.dart';
import '../dsl/app_state_dsl.dart';

void main() {
  Future<void> pumpAt200Percent(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
          child: app!,
        ),
        home: child,
      ),
    );
  }

  RenderParagraph paragraphOf(WidgetTester tester, String text) {
    return tester.renderObject<RenderParagraph>(find.text(text));
  }

  testWidgets('A11y 8.2 : à 200 %, les libellés de la barre de navigation ne sont jamais coupés en plein mot',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final labels = [
      Strings.menuAccueil,
      Strings.menuMonSuivi,
      Strings.menuSolutions,
      Strings.menuEvenements,
      Strings.menuChat,
    ];
    await pumpAt200Percent(
      tester,
      Scaffold(
        bottomNavigationBar: DsfrBottomNavigation(
          currentIndex: 0,
          onTap: (_) {},
          items: [
            for (final label in labels)
              DsfrBottomNavigationItem(
                icon: DsfrIcons.buildingsHome4Line,
                activeIcon: DsfrIcons.buildingsHome4Fill,
                label: label,
              ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    for (final label in labels) {
      // Le mot entier est un seul Text d'une seule ligne, réduit si besoin pour tenir dans la tuile.
      final paragraph = paragraphOf(tester, label);
      expect(paragraph.didExceedMaxLines, isFalse, reason: label);
      expect(paragraph.getMinIntrinsicHeight(double.infinity), paragraph.size.height, reason: label);
      final fitted = find.ancestor(of: find.text(label), matching: find.byType(FittedBox));
      expect(tester.getSize(fitted).width, lessThanOrEqualTo(360 / labels.length), reason: label);
      // L'état sélectionné et le libellé restent restitués par un seul nœud.
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    expect(
      tester.getSemantics(find.bySemanticsLabel(Strings.menuAccueil)),
      containsSemantics(label: Strings.menuAccueil, isButton: true, isSelected: true),
    );
    semantics.dispose();
  });

  testWidgets('A11y 8.2 : à 200 %, les tuiles de catégorie affichent le texte en entier', (tester) async {
    const title = 'Recherche, candidatures et entretiens';
    const subtitle = 'Définir un projet professionnel et se former';
    await pumpAt200Percent(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: EmojiSolutionGrid(
            tiles: [
              EmojiSolutionTile(
                title: title,
                subtitle: subtitle,
                emoji: '🔎',
                emojiBackground: Colors.blue,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(paragraphOf(tester, title).didExceedMaxLines, isFalse);
    expect(paragraphOf(tester, subtitle).didExceedMaxLines, isFalse);
    // Le titre est affiché sur autant de lignes que nécessaire, sans hauteur figée.
    expect(paragraphOf(tester, title).size.height, greaterThan(paragraphOf(tester, subtitle).size.height));
  });

  testWidgets('A11y 8.2 : à 200 %, « réalisée » et « validée » ne sont pas coupés et sont lus en un seul nœud',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final state = givenState().loggedInMiloUser().withComptageDesHeuresSuccess(
          comptageDesHeures: mockComptageDesHeures(nbHeuresValidees: 0, nbHeuresDeclarees: 20),
        );
    final store = Store<AppState>((state, _) => state, initialState: state);
    await pumpAt200Percent(
      tester,
      StoreProvider<AppState>(
        store: store,
        child: const Scaffold(body: SingleChildScrollView(child: ComptageDesHeuresCard())),
      ),
    );

    expect(tester.takeException(), isNull);
    for (final label in [Strings.declaredHours, Strings.realizedHours]) {
      // Aucun mot coupé : le mot tient sur une seule ligne.
      final paragraph = paragraphOf(tester, label);
      expect(paragraph.size.height, paragraph.getMinIntrinsicHeight(double.infinity), reason: label);
      final fitted = find.ancestor(of: find.text(label), matching: find.byType(FittedBox));
      expect(tester.getSize(fitted).width, lessThanOrEqualTo(tester.getSize(find.byType(ComptageDesHeuresCard)).width / 2));
    }
    expect(find.bySemanticsLabel('20 heures réalisées'), findsOneWidget);
    expect(find.bySemanticsLabel('0 heure validée'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('A11y 8.2 : à 200 %, « Retour » tient sur une ligne', (tester) async {
    await pumpAt200Percent(tester, const Scaffold(appBar: BackAppBar()));

    final retour = paragraphOf(tester, Strings.back);
    expect(retour.getMaxIntrinsicWidth(double.infinity), lessThanOrEqualTo(retour.size.width));
  });
}
