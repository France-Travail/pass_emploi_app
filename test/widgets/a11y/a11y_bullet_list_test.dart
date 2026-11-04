import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/widgets/a11y/a11y_bullet_list.dart';

void main() {
  group('A11yBulletList', () {
    testWidgets('A11y 7.2 : annonce la liste, puis chaque élément avec sa position, sans lire la puce', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: A11yBulletList(items: ['Un problème', 'Une suggestion', 'Autre'])),
        ),
      );

      expect(find.bySemanticsLabel('Liste de 3 éléments. Un problème, 1 sur 3'), findsOneWidget);
      expect(find.bySemanticsLabel('Une suggestion, 2 sur 3'), findsOneWidget);
      expect(find.bySemanticsLabel('Autre, 3 sur 3'), findsOneWidget);
      expect(find.bySemanticsLabel('•'), findsNothing);
      semantics.dispose();
    });
  });

  group('DescriptionBlock', () {
    test('regroupe les lignes à tirets consécutives en une liste', () {
      final blocks = DescriptionBlock.fromParagraphs([
        'Conditions du poste',
        '- Contrat : CDI',
        '- Lieu : Nieppe (59).',
        'Vous serez également amené à :',
        'o Définir les composants',
        '• Réaliser les calculs',
      ]);

      expect(blocks.map((b) => b.isList), [false, true, false, true]);
      expect(blocks[1].items, ['Contrat : CDI', 'Lieu : Nieppe (59).']);
      expect(blocks[1].lines, ['- Contrat : CDI', '- Lieu : Nieppe (59).']);
      expect(blocks[3].items, ['Définir les composants', 'Réaliser les calculs']);
    });

    test('ne prend pas pour une puce un mot qui commence par « o » ni un tiret seul', () {
      final blocks = DescriptionBlock.fromParagraphs(['ouvert le samedi', '-', 'Organisation : 35h']);

      expect(blocks.every((b) => !b.isList), isTrue);
    });
  });
}
