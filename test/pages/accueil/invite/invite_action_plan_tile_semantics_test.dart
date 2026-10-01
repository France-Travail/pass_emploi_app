import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/pages/accueil/invite/invite_action_plan_section.dart';
import 'package:pass_emploi_app/ui/strings.dart';

void main() {
  const caseKey = Key('case');

  Future<SemanticsHandle> pumpTile(WidgetTester tester, ActionPlanAction action) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InviteActionPlanActionTile(
            focusKey: const GlobalObjectKey(caseKey),
            action: action,
            onToggleDone: () {},
            onDelete: () {},
          ),
        ),
      ),
    );
    return semantics;
  }

  String hintDeLaCase(WidgetTester tester) =>
      tester.getSemantics(find.byKey(const GlobalObjectKey(caseKey))).hint;

  testWidgets('la case non cochée à déclarer annonce qu’elle ouvre le formulaire', (tester) async {
    final semantics = await pumpTile(
      tester,
      const ActionPlanAction(
        id: 'a',
        label: 'Je crée mon CV',
        kind: ActionPlanActionKind.advice,
        declarationRequise: true,
      ),
    );

    expect(hintDeLaCase(tester), Strings.actionPlanDeclarationOuvreFormulaireA11y);
    semantics.dispose();
  });

  testWidgets('la case cochée à déclarer garde son hint habituel', (tester) async {
    final semantics = await pumpTile(
      tester,
      const ActionPlanAction(
        id: 'a',
        label: 'Je crée mon CV',
        kind: ActionPlanActionKind.advice,
        declarationRequise: true,
        done: true,
        serviceName: 'Service',
      ),
    );

    expect(hintDeLaCase(tester), 'Service');
    semantics.dispose();
  });

  testWidgets('la case sans déclaration garde son hint habituel', (tester) async {
    final semantics = await pumpTile(
      tester,
      const ActionPlanAction(id: 'a', label: 'Je crée mon CV', kind: ActionPlanActionKind.advice, serviceName: 'Service'),
    );

    expect(hintDeLaCase(tester), 'Service');
    semantics.dispose();
  });
}
