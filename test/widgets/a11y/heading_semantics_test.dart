import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_section_title.dart';
import 'package:pass_emploi_app/widgets/textes.dart';

/// A11y 9.1 (RAAM) : titres restitués par TalkBack et VoiceOver.
///
/// Depuis Flutter 3.38 (Android) et 3.47 (iOS), `Semantics(header: true)` n'a plus d'effet sur mobile : seul
/// `headingLevel` > 0 produit un titre (`AccessibilityNodeInfo.setHeading` / `UIAccessibilityTraitHeader`).
/// https://docs.flutter.dev/release/breaking-changes/semantics-header-heading-level
void main() {
  test('aucun `header: true` dans lib/ : utiliser `headingLevel`', () {
    final headerTrue = RegExp(r'\bheader\s*:\s*true\b');
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (headerTrue.hasMatch(lines[i])) offenders.add('${file.path}:${i + 1}');
      }
    }
    expect(offenders, isEmpty, reason: '`header: true` est ignoré sur Android et iOS, utiliser `headingLevel`.');
  });

  group('Titres des composants partagés', () {
    Future<int> headingLevelOf(WidgetTester tester, String text, Widget widget) async {
      await tester.pumpWidget(MaterialApp(home: widget));
      // Laisse passer la demande de focus différée d'AutoFocusA11y.
      await tester.pump(const Duration(milliseconds: 200));
      return tester.getSemantics(find.text(text)).headingLevel;
    }

    testWidgets('SecondaryAppBar : le titre est un titre de niveau 1', (tester) async {
      final semantics = tester.ensureSemantics();
      final level = await headingLevelOf(tester, 'Titre', const Scaffold(appBar: SecondaryAppBar(title: 'Titre')));
      expect(level, 1);
      semantics.dispose();
    });

    testWidgets('PrimaryAppBar : le titre est un titre de niveau 1', (tester) async {
      final semantics = tester.ensureSemantics();
      final level = await headingLevelOf(tester, 'Titre', const Scaffold(appBar: PrimaryAppBar(title: 'Titre')));
      expect(level, 1);
      semantics.dispose();
    });

    testWidgets('PageTitle : titre de niveau 1', (tester) async {
      final semantics = tester.ensureSemantics();
      final level = await headingLevelOf(tester, 'Titre', const Scaffold(body: PageTitle('Titre')));
      expect(level, 1);
      semantics.dispose();
    });

    testWidgets('LargeSectionTitle : titre de niveau 2', (tester) async {
      final semantics = tester.ensureSemantics();
      final level = await headingLevelOf(tester, 'Section', const Scaffold(body: LargeSectionTitle('Section')));
      expect(level, 2);
      semantics.dispose();
    });

    testWidgets('OffreDetailsSectionTitle : section (headline4) au niveau 2, sous-section au niveau 3', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                OffreDetailsSectionTitle('Profil'),
                OffreDetailsSectionTitle('Expérience', size: OffreDetailsSectionTitleSize.headline6),
              ],
            ),
          ),
        ),
      );
      expect(tester.getSemantics(find.text('Profil')).headingLevel, 2);
      expect(tester.getSemantics(find.text('Expérience')).headingLevel, 3);
      semantics.dispose();
    });
  });
}
