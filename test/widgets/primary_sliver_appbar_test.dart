import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              const PrimarySliverAppbar(title: 'Bonjour\nLéa 👋', withNewNotifications: false),
              SliverList.list(children: [for (var i = 0; i < 40; i++) SizedBox(height: 80, child: Text('Item $i'))]),
            ],
          ),
        ),
      ),
    );
    // Laisse passer le focus automatique du titre (AutoFocusA11y).
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets("A11y 1.1 : l'emoji du titre n'est pas restitué", (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    expect(find.bySemanticsLabel('Bonjour\nLéa'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('A11y 10.2 : quand le titre reçoit le focus du lecteur d’écran, la page revient en haut', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);
    final position = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    position.jumpTo(1500);
    await tester.pump();

    final title = tester.getSemantics(find.bySemanticsLabel('Bonjour\nLéa'));
    title.owner!.performAction(title.id, SemanticsAction.didGainAccessibilityFocus);
    await tester.pump();

    expect(position.pixels, position.minScrollExtent);
    semantics.dispose();
  });

  testWidgets('le centre de notifications est masqué quand il n’est pas proposé', (tester) async {
    final semantics = tester.ensureSemantics();
    Future<void> pump({required bool withNotificationCenter}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                PrimarySliverAppbar(
                  title: 'Bonjour',
                  withNewNotifications: false,
                  withNotificationCenter: withNotificationCenter,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
    }

    await pump(withNotificationCenter: true);
    expect(find.bySemanticsLabel('Centre de notifications'), findsOneWidget);

    await pump(withNotificationCenter: false);
    expect(find.bySemanticsLabel('Centre de notifications'), findsNothing);
    semantics.dispose();
  });

  testWidgets('la pastille de nouvelles notifications est restituée dans le nom du bouton', (tester) async {
    final semantics = tester.ensureSemantics();
    Future<void> pump({required bool withNewNotifications}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [PrimarySliverAppbar(title: 'Bonjour', withNewNotifications: withNewNotifications)],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
    }

    await pump(withNewNotifications: true);
    expect(
      find.semantics.byPredicate((node) {
        final data = node.getSemanticsData();
        return data.flagsCollection.isButton && data.label == 'Centre de notifications, nouvelles notifications';
      }),
      findsOne,
    );

    await pump(withNewNotifications: false);
    expect(
      find.semantics.byPredicate((node) {
        final data = node.getSemanticsData();
        return data.flagsCollection.isButton && data.label == 'Centre de notifications';
      }),
      findsOne,
    );
    semantics.dispose();
  });
}
