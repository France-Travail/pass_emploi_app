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
    Future<void> pump(WidgetTester tester, {String? url = 'https://labonneboite.francetravail.fr'}) =>
        tester.pumpWidget(
          MaterialApp(
            home: ExternalLinkSemantics(
              label: 'La Bonne Boîte',
              url: url,
              onTap: () {},
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        );

    testWidgets('Android : rôle lien natif (URLSpan via linkUrl), sans indication de navigateur', (tester) async {
      final handle = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await pump(tester);

      final data = tester.getSemantics(find.bySemanticsLabel('La Bonne Boîte')).getSemanticsData();
      expect(data.flagsCollection.isLink, isTrue);
      expect(data.flagsCollection.isButton, isFalse);
      expect(data.linkUrl, Uri.parse('https://labonneboite.francetravail.fr'));
      expect(data.hint, isEmpty);

      debugDefaultTargetPlatformOverride = null;
      handle.dispose();
    });

    testWidgets('Android : sans adresse, repli sur un bouton', (tester) async {
      final handle = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await pump(tester, url: null);

      final data = tester.getSemantics(find.bySemanticsLabel('La Bonne Boîte')).getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isLink, isFalse);

      debugDefaultTargetPlatformOverride = null;
      handle.dispose();
    });

    testWidgets('iOS : rôle lien', (tester) async {
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

    testWidgets('indication explicite (destination non dite par le libellé)', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: ExternalLinkSemantics(
            label: 'Pas vraiment',
            hint: 'Ouvre un formulaire de retour',
            url: 'https://tally.so/r/x',
            onTap: () {},
            child: const SizedBox(width: 50, height: 50),
          ),
        ),
      );

      final data = tester.getSemantics(find.bySemanticsLabel('Pas vraiment')).getSemanticsData();
      expect(data.hint, 'Ouvre un formulaire de retour');
      handle.dispose();
    });
  });

  group('ExternalLinkSemantics : rôle selon la destination', () {
    final urls = {
      LinkDestination.website: 'https://exemple.fr',
      LinkDestination.appStore: 'market://details?id=fr.fabrique.social.gouv.passemploi',
      LinkDestination.mailApp: 'mailto:a@b.fr',
      LinkDestination.phoneApp: 'tel:0102030405',
    };

    for (final entry in urls.entries) {
      testWidgets('Android : ${entry.key.name} = lien, sans indication', (tester) async {
        final handle = tester.ensureSemantics();
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        await tester.pumpWidget(
          MaterialApp(
            home: ExternalLinkSemantics(
              label: 'Lien',
              url: entry.value,
              destination: entry.key,
              onTap: () {},
              child: const SizedBox(width: 50, height: 50),
            ),
          ),
        );

        final data = tester.getSemantics(find.bySemanticsLabel('Lien')).getSemanticsData();
        expect(data.flagsCollection.isLink, isTrue);
        expect(data.flagsCollection.isButton, isFalse);
        expect(data.hint, isEmpty);

        debugDefaultTargetPlatformOverride = null;
        handle.dispose();
      });
    }

    testWidgets("Android : réglages de l'application = bouton avec indication", (tester) async {
      final handle = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(
        MaterialApp(
          home: ExternalLinkSemantics(
            label: 'Réglages',
            destination: LinkDestination.appSettings,
            onTap: () {},
            child: const SizedBox(width: 50, height: 50),
          ),
        ),
      );

      final data = tester.getSemantics(find.bySemanticsLabel('Réglages')).getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.hint, Strings.a11yOpensAppSettings);

      debugDefaultTargetPlatformOverride = null;
      handle.dispose();
    });

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

    testWidgets(
        "Android : l'état termine le nom, dans une région live relue au changement (pas d'annonce dépréciée)",
        (tester) async {
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
      expect(data.label, endsWith(', ${Strings.a11yCollapsed}'));
      expect(data.flagsCollection.isLiveRegion, isTrue);
      expect(data.flagsCollection.isButton, isTrue);

      await tester.tap(headerFinder());
      await tester.pump(const Duration(seconds: 1));
      data = tester.getSemantics(headerFinder()).getSemanticsData();
      expect(data.label, endsWith(', ${Strings.a11yExpanded}'));
      expect(announcements, isEmpty);

      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, null);
      debugDefaultTargetPlatformOverride = null;
      handle.dispose();
    });

    testWidgets("iOS : l'état est porté par value (expanded ignoré par le moteur) et annoncé au changement",
        (tester) async {
      final handle = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
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
      // L'annonce part du nouveau rendu : on laisse passer son délai.
      await tester.pump(const Duration(milliseconds: 200));
      data = tester.getSemantics(headerFinder()).getSemanticsData();
      expect(data.value, Strings.a11yExpanded);
      expect(announcements, [Strings.a11yExpanded]);

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
