import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/pages/accueil/invite/invite_action_plan_section.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/external_links.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

import '../../../dsl/app_state_dsl.dart';

void main() {
  group('Bandeau de feedback d’un objectif du plan', () {
    testWidgets('s’affiche sous la dernière action une fois l’objectif déplié', (tester) async {
      await _pumpSection(tester, _plan(actionsCount: 2));

      // Objectif replié : le contenu est construit mais masqué.
      expect(find.text(Strings.inviteAccueilObjectiveFeedbackYes).hitTestable(), findsNothing);

      await _expandObjective(tester);

      expect(find.text(Strings.inviteAccueilObjectiveFeedbackTitle), findsOneWidget);
      expect(find.text(Strings.inviteAccueilObjectiveFeedbackYes).hitTestable(), findsOneWidget);
      expect(
        tester.getTopLeft(find.text(Strings.inviteAccueilObjectiveFeedbackTitle)).dy,
        greaterThan(tester.getBottomLeft(find.text('Action 2')).dy),
      );
    });

    testWidgets('n’apparaît qu’une fois toutes les actions affichées', (tester) async {
      await _pumpSection(tester, _plan(actionsCount: 6));
      await _expandObjective(tester);

      expect(find.text(Strings.inviteAccueilObjectiveFeedbackTitle), findsNothing);

      await tester.tap(find.text(Strings.inviteAccueilAfficherPlus));
      await tester.pumpAndSettle();

      expect(find.text(Strings.inviteAccueilObjectiveFeedbackTitle), findsOneWidget);
    });

    testWidgets('« Oui » enregistre la réponse de l’objectif sans ouvrir de lien', (tester) async {
      final launchedUrls = _captureLaunchedUrls(tester);
      final answered = <String>[];
      await _pumpSection(tester, _plan(actionsCount: 2), onFeedback: answered.add);
      await _expandObjective(tester);

      await tester.tap(find.text(Strings.inviteAccueilObjectiveFeedbackYes));
      await tester.pumpAndSettle();

      expect(answered, ['objective-id']);
      expect(launchedUrls, isEmpty);
    });

    testWidgets('« Pas vraiment » ouvre le formulaire Tally et enregistre la réponse', (tester) async {
      final launchedUrls = _captureLaunchedUrls(tester);
      final answered = <String>[];
      await _pumpSection(tester, _plan(actionsCount: 2), onFeedback: answered.add);
      await _expandObjective(tester);

      await tester.tap(find.text(Strings.inviteAccueilObjectiveFeedbackNo));
      await tester.pumpAndSettle();

      expect(answered, ['objective-id']);
      expect(launchedUrls, [ExternalLinks.actionPlanObjectiveFeedback]);
    });

    testWidgets('affiche le remerciement à la place des boutons une fois la réponse donnée', (tester) async {
      await _pumpSection(tester, _plan(actionsCount: 2, feedbackGiven: true));
      await _expandObjective(tester);

      expect(find.text(Strings.inviteAccueilObjectiveFeedbackThanks), findsOneWidget);
      expect(find.text(Strings.inviteAccueilObjectiveFeedbackTitle), findsNothing);
      expect(find.text(Strings.inviteAccueilObjectiveFeedbackYes), findsNothing);
      expect(find.text(Strings.inviteAccueilObjectiveFeedbackNo), findsNothing);
    });

    testWidgets('« Pas vraiment » annonce l’ouverture du navigateur au lecteur d’écran', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpSection(tester, _plan(actionsCount: 2));
      await _expandObjective(tester);

      final yes = tester.getSemantics(find.bySemanticsLabel(Strings.inviteAccueilObjectiveFeedbackYes));
      expect(yes, containsSemantics(label: Strings.inviteAccueilObjectiveFeedbackYes, isButton: true));
      final no = tester.getSemantics(find.bySemanticsLabel(Strings.inviteAccueilObjectiveFeedbackNo));
      expect(
        no,
        containsSemantics(
          label: Strings.inviteAccueilObjectiveFeedbackNo,
          hint: Strings.inviteAccueilObjectiveFeedbackNoA11y,
          isButton: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });
  });
}

ActionPlan _plan({required int actionsCount, bool feedbackGiven = false}) {
  return ActionPlan(
    id: 'plan-id',
    greeting: 'Salut',
    objectives: [
      ActionPlanObjective(
        id: 'objective-id',
        title: 'Trouver un emploi',
        theme: 'EMPLOI',
        feedbackGiven: feedbackGiven,
        actions: [
          for (var i = 1; i <= actionsCount; i++)
            ActionPlanAction(id: 'action-$i', label: 'Action $i', kind: ActionPlanActionKind.advice),
        ],
      ),
    ],
  );
}

Future<void> _pumpSection(
  WidgetTester tester,
  ActionPlan plan, {
  void Function(String objectiveId)? onFeedback,
}) async {
  final store = Store<AppState>((state, action) => state, initialState: givenState());
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InviteActionPlanSection(
              plan: plan,
              onToggleDone: (_) {},
              onDelete: (_) {},
              onFeedback: onFeedback ?? (_) {},
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _expandObjective(WidgetTester tester) async {
  await tester.tap(find.text('Trouver un emploi'));
  await tester.pumpAndSettle();
}

List<String> _captureLaunchedUrls(WidgetTester tester) {
  final urls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/url_launcher'),
    (call) async {
      if (call.method == 'launch') urls.add((call.arguments as Map)['url'] as String);
      return true;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      null,
    ),
  );
  return urls;
}
