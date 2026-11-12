import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/buttons/clear_field_button.dart';
import 'package:pass_emploi_app/widgets/dialogs/delete_user_dialog.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_information_badge.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_tertiary_navigation.dart';

import '../doubles/spies.dart';
import '../dsl/app_state_dsl.dart';

/// Correctifs de l'audit RAAM 1.1 Access42 du 15/10/2026.
void main() {
  group('Supprimer mon compte, fenêtre « Attention » (E18)', () {
    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: StoreSpy.withState(givenState()),
          child: const MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: DeleteAlertDialog())),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
    }

    testWidgets('A11y 9.9 : champ vide, « Supprimer » affiche l’erreur et remet le focus sur le champ', (tester) async {
      await pump(tester);

      await tester.tap(find.text(Strings.suppressionLabel));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text(Strings.mandatorySuppressionLabelError), findsOneWidget);
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.focusNode.hasFocus, isTrue);
    });

    testWidgets('A11y 9.9 : l’erreur est restituée avec le champ', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);

      await tester.tap(find.text(Strings.suppressionLabel));
      await tester.pump(const Duration(milliseconds: 200));

      final field = tester.getSemantics(find.byType(EditableText)).getSemanticsData();
      expect(field.flagsCollection.isTextField, isTrue);
      expect(field.label, contains(Strings.confirmationLabel));
      expect(field.label, contains(Strings.mandatorySuppressionLabelError));
      semantics.dispose();
    });

    testWidgets('A11y 7.1 : « Attention » est le titre de la fenêtre', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);

      expect(tester.getSemantics(find.text(Strings.warning)), isSemantics(isHeader: true));
      semantics.dispose();
    });
  });

  group('A11y 8.2 : texte à 200 %', () {
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

    testWidgets('les onglets de « Offres » passent à la ligne au lieu de sortir de l’écran (E12)', (tester) async {
      final semantics = tester.ensureSemantics();
      final labels = ['Recherche', 'Suivi des offres', 'Alertes'];
      await pumpAt200Percent(
        tester,
        DefaultTabController(
          length: labels.length,
          child: Scaffold(body: DsfrTertiaryNavigation(labels: labels)),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(TabBar), findsNothing);
      for (final label in labels) {
        final rect = tester.getRect(find.text(label));
        expect(rect.left, greaterThanOrEqualTo(0), reason: label);
        expect(rect.right, lessThanOrEqualTo(360), reason: label);
      }
      // Même restitution qu'un onglet Material : état sélectionné et position.
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Recherche, '))),
        isSemantics(label: 'Recherche, Tab 1 of 3', isSelected: true, hasTapAction: true),
      );

      await tester.tap(find.text('Alertes'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Alertes, '))),
        isSemantics(isSelected: true),
      );
      semantics.dispose();
    });

    testWidgets('sans agrandissement, les onglets restent un TabBar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(body: DsfrTertiaryNavigation(labels: ['Recherche', 'Suivi des offres', 'Alertes'])),
          ),
        ),
      );

      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('« Candidature envoyée » passe à la ligne au lieu d’être coupé (E12)', (tester) async {
      await pumpAt200Percent(
        tester,
        const Scaffold(
          body: SizedBox(width: 160, child: DsfrInformationBadge(label: 'Candidature envoyée')),
        ),
      );

      expect(tester.takeException(), isNull);
      final paragraph = tester.renderObject<RenderParagraph>(find.text('CANDIDATURE ENVOYÉE'));
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(paragraph.size.width, lessThanOrEqualTo(160));
    });
  });

  testWidgets('A11y 5.1 : le bouton d’effacement est un bouton nommé, distinct du champ (E08)', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ClearFieldButton(tooltip: Strings.a11yClearField('Ville ou code postal'), onPressed: () {}),
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.byTooltip('Effacer le champ « Ville ou code postal »')),
      isSemantics(
        tooltip: 'Effacer le champ « Ville ou code postal »',
        isButton: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });
}
