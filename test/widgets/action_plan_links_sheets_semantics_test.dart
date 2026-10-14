import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/pages/accueil/invite/invite_action_plan_section.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/external_link_semantics.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/action_plan_feedback_bottom_sheet.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_profil_card.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_tuile_card.dart';

import '../doubles/spies.dart';
import '../dsl/app_state_dsl.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('ExternalLinkSemantics', () {
    Future<void> pump(WidgetTester tester) => tester.pumpWidget(
          MaterialApp(
            home: ExternalLinkSemantics(
              label: 'La Bonne Boîte',
              onTap: () {},
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        );

    testWidgets('Android : bouton avec indication de site externe', (tester) async {
      final handle = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await pump(tester);

      final data = tester.getSemantics(find.bySemanticsLabel('La Bonne Boîte')).getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isLink, isFalse);
      expect(data.hint, Strings.a11yOpensExternalSite);

      debugDefaultTargetPlatformOverride = null;
      handle.dispose();
    });

    testWidgets('iOS : rôle lien conservé', (tester) async {
      final handle = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await pump(tester);

      final data = tester.getSemantics(find.bySemanticsLabel('La Bonne Boîte')).getSemanticsData();
      expect(data.flagsCollection.isLink, isTrue);
      expect(data.flagsCollection.isButton, isFalse);
      expect(data.hint, isEmpty);

      debugDefaultTargetPlatformOverride = null;
      handle.dispose();
    });
  });

  group('ExternalLinkSemantics : indications selon la destination', () {
    final expected = {
      LinkDestination.website: Strings.a11yOpensExternalSite,
      LinkDestination.appStore: Strings.a11yOpensAppStore,
      LinkDestination.appSettings: Strings.a11yOpensAppSettings,
      LinkDestination.mailApp: Strings.a11yOpensMailApp,
      LinkDestination.phoneApp: Strings.a11yOpensPhoneApp,
    };

    for (final entry in expected.entries) {
      testWidgets('Android : ${entry.key.name}', (tester) async {
        final handle = tester.ensureSemantics();
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        await tester.pumpWidget(
          MaterialApp(
            home: ExternalLinkSemantics(
              label: 'Lien',
              destination: entry.key,
              onTap: () {},
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        );

        final data = tester.getSemantics(find.bySemanticsLabel('Lien')).getSemanticsData();
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.hint, entry.value);

        debugDefaultTargetPlatformOverride = null;
        handle.dispose();
      });
    }

    testWidgets('Android : navigation interne = bouton sans indication, iOS : lien', (tester) async {
      final handle = tester.ensureSemantics();
      Future<SemanticsData> pump() async {
        await tester.pumpWidget(
          MaterialApp(
            home: ExternalLinkSemantics(
              label: 'Offre',
              destination: LinkDestination.inApp,
              onTap: () {},
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        );
        return tester.getSemantics(find.bySemanticsLabel('Offre')).getSemanticsData();
      }

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      var data = await pump();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isLink, isFalse);
      expect(data.hint, isEmpty);

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      data = await pump();
      expect(data.flagsCollection.isLink, isTrue);
      expect(data.flagsCollection.isButton, isFalse);

      debugDefaultTargetPlatformOverride = null;
      handle.dispose();
    });

    test('LinkDestination.fromUri déduit la destination du schéma', () {
      expect(LinkDestination.fromUri(Uri.parse('mailto:a@b.fr')), LinkDestination.mailApp);
      expect(LinkDestination.fromUri(Uri.parse('tel:0102030405')), LinkDestination.phoneApp);
      expect(LinkDestination.fromUri(Uri.parse('https://exemple.fr')), LinkDestination.website);
    });
  });

  group('Tuiles et cartes avec semanticsLink', () {
    final cards = <String, Widget Function(LinkDestination?)>{
      'DsfrTuileCard': (destination) => DsfrTuileCard(
            leading: const SizedBox.shrink(),
            title: 'Réglages',
            onTap: () {},
            semanticsLink: true,
            semanticsLinkDestination: destination ?? LinkDestination.website,
          ),
      'DsfrProfilCard': (destination) => DsfrProfilCard(
            leading: const SizedBox.shrink(),
            title: 'Réglages',
            onTap: () {},
            semanticsLink: true,
            semanticsLinkDestination: destination ?? LinkDestination.website,
          ),
    };

    for (final entry in cards.entries) {
      testWidgets('${entry.key} Android : bouton avec indication de la destination', (tester) async {
        final handle = tester.ensureSemantics();
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: entry.value(LinkDestination.appSettings))));

        final data = tester.getSemantics(find.bySemanticsLabel('Réglages')).getSemanticsData();
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.flagsCollection.isLink, isFalse);
        expect(data.hint, Strings.a11yOpensAppSettings);

        debugDefaultTargetPlatformOverride = null;
        handle.dispose();
      });

      testWidgets('${entry.key} iOS : rôle lien conservé', (tester) async {
        final handle = tester.ensureSemantics();
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: entry.value(null))));

        final data = tester.getSemantics(find.bySemanticsLabel('Réglages')).getSemanticsData();
        expect(data.flagsCollection.isLink, isTrue);
        expect(data.flagsCollection.isButton, isFalse);
        expect(data.hint, isEmpty);

        debugDefaultTargetPlatformOverride = null;
        handle.dispose();
      });
    }

    testWidgets('PrimaryActionButton semanticsRoleLink : Android bouton avec indication, iOS lien', (tester) async {
      final handle = tester.ensureSemantics();
      Future<SemanticsData> pump() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrimaryActionButton(label: 'Boîte à outils', semanticsRoleLink: true, onPressed: () {}),
            ),
          ),
        );
        return tester.getSemantics(find.bySemanticsLabel('Boîte à outils')).getSemanticsData();
      }

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      var data = await pump();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.hint, Strings.a11yOpensExternalSite);

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      data = await pump();
      expect(data.flagsCollection.isLink, isTrue);
      expect(data.hint, isEmpty);

      debugDefaultTargetPlatformOverride = null;
      handle.dispose();
    });
  });

  group("Accordéon du plan d'action", () {
    final plan = ActionPlan(
      id: 'plan',
      greeting: '',
      objectives: [
        ActionPlanObjective(
          id: 'o',
          title: "Je cherche à m'orienter",
          theme: 'ORIENTER',
          actions: [ActionPlanAction(id: 'a', label: 'Action', kind: ActionPlanActionKind.advice)],
        ),
      ],
    );
    Finder headerFinder() => find.bySemanticsLabel(RegExp("Je cherche à m'orienter"));

    Future<void> pump(WidgetTester tester) => tester.pumpWidget(
          StoreProvider<AppState>(
            store: StoreSpy.withState(givenState()),
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: InviteActionPlanSection(
                    plan: plan,
                    onToggleDone: (_) {},
                    onDelete: (_) {},
                    onFeedback: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );

    testWidgets("Android : l'état est porté par value et annoncé au changement", (tester) async {
      final handle = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final announcements = <String>[];
      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility,
          (message) async {
        if (message is Map && message['type'] == 'announce') {
          announcements.add((message['data'] as Map)['message'] as String);
        }
        return null;
      });
      await pump(tester);

      var data = tester.getSemantics(headerFinder()).getSemanticsData();
      expect(data.value, Strings.a11yCollapsed);

      await tester.tap(headerFinder());
      await tester.pump(const Duration(seconds: 1));
      data = tester.getSemantics(headerFinder()).getSemanticsData();
      expect(data.value, Strings.a11yExpanded);
      expect(announcements, [Strings.a11yExpanded]);

      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, null);
      debugDefaultTargetPlatformOverride = null;
      handle.dispose();
    });

    testWidgets("iOS : expanded conservé, pas de value ni d'annonce", (tester) async {
      final handle = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final announcements = <Object?>[];
      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility,
          (message) async {
        if (message is Map && message['type'] == 'announce') announcements.add(message);
        return null;
      });
      await pump(tester);

      var data = tester.getSemantics(headerFinder()).getSemanticsData();
      expect(data.value, isEmpty);
      expect(data.flagsCollection.hasExpandedState, isTrue);
      expect(data.flagsCollection.isExpanded, isFalse);

      await tester.tap(headerFinder());
      await tester.pump(const Duration(seconds: 1));
      data = tester.getSemantics(headerFinder()).getSemanticsData();
      expect(data.flagsCollection.isExpanded, isTrue);
      expect(announcements, isEmpty);

      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, null);
      debugDefaultTargetPlatformOverride = null;
      handle.dispose();
    });
  });

  testWidgets('Feuille « Avant de continuer » : titre en en-tête', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ActionPlanFeedbackBottomSheet())));
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      tester.getSemantics(find.text(Strings.actionPlanFeedbackTitle)),
      containsSemantics(label: Strings.actionPlanFeedbackTitle, isHeader: true),
    );
    handle.dispose();
  });

  test('Le libellé de la barrière ne contient pas le rôle', () {
    expect(Strings.bottomSheetBarrierLabel, Strings.closeDialog);
  });
}
