import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_tuile_card.dart';

void main() {
  Future<void> pump(WidgetTester tester, {VoidCallback? onDismiss}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DsfrTuileCard(
            leading: const SizedBox.shrink(),
            title: 'Es-tu satisfait ?',
            description: 'Je donne mon avis',
            onTap: () {},
            onDismiss: onDismiss,
            dismissSemanticLabel: 'Fermer : Es-tu satisfait ?',
          ),
        ),
      ),
    );
  }

  testWidgets('la tuile est un bouton qui porte son titre et sa description', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    expect(
      tester.getSemantics(find.bySemanticsLabel('Es-tu satisfait ?. Je donne mon avis')),
      containsSemantics(isButton: true, hasTapAction: true),
    );
    semantics.dispose();
  });

  testWidgets('A11y 5.1 : le bouton de fermeture est restitué et activable au lecteur d’écran', (tester) async {
    final semantics = tester.ensureSemantics();
    var dismissed = false;
    await pump(tester, onDismiss: () => dismissed = true);

    final fermer = find.bySemanticsLabel('Fermer : Es-tu satisfait ?');
    expect(tester.getSemantics(fermer), containsSemantics(isButton: true, hasTapAction: true));

    tester.semantics.tap(find.semantics.byLabel('Fermer : Es-tu satisfait ?'));
    expect(dismissed, isTrue);
    semantics.dispose();
  });
}
