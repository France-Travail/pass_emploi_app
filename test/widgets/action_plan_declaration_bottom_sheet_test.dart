import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_declaration_state.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_repository.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/action_plan_declaration_bottom_sheet.dart';

import '../doubles/spies.dart';
import '../dsl/app_state_dsl.dart';

void main() {
  const actionId = 'tache-1';

  ActionPlan plan() => ActionPlan(
        id: 'plan',
        greeting: '',
        objectives: [
          ActionPlanObjective(
            id: 'objective',
            title: 'Trouver un emploi',
            theme: 'EMPLOI',
            actions: [
              ActionPlanAction(
                id: actionId,
                label: 'Je crée mon CV',
                kind: ActionPlanActionKind.advice,
                declarationRequise: true,
                categorie: 'Emploi',
              ),
            ],
          ),
        ],
      );

  Future<StoreSpy> pump(WidgetTester tester, AppState state) async {
    final store = StoreSpy.withState(state);
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: const MaterialApp(
          home: Scaffold(body: ActionPlanDeclarationContent(actionId: actionId)),
        ),
      ),
    );
    return store;
  }

  AppState milo([ActionPlanDeclarationState? declaration]) => givenState().loggedInMiloUser().copyWith(
        actionPlanState: ActionPlanSuccessState(plan()),
        actionPlanDeclarationState: declaration ?? ActionPlanDeclarationNotInitializedState(),
      );

  AppState franceTravail() =>
      givenState().loggedInPoleEmploiUser().copyWith(actionPlanState: ActionPlanSuccessState(plan()));

  testWidgets('Mission Locale : tag, titre, date et description', (tester) async {
    await pump(tester, milo());

    expect(find.text('EMPLOI'), findsOneWidget);
    expect(find.text('Je crée mon CV'), findsOneWidget);
    expect(find.text(Strings.actionPlanDeclarationQuand), findsOneWidget);
    expect(find.text(Strings.actionPlanDeclarationDecrire), findsOneWidget);
  });

  testWidgets('France Travail : pas de description', (tester) async {
    await pump(tester, franceTravail());

    expect(find.text(Strings.actionPlanDeclarationDecrire), findsNothing);
  });

  testWidgets('France Travail : la date suffit pour déclarer', (tester) async {
    final store = await pump(tester, franceTravail());

    await tester.tap(find.text(Strings.dateSuggestionHier));
    await tester.pump();
    await tester.tap(find.text(Strings.markActionAsDone));
    await tester.pump();

    expect(store.dispatchedActions.whereType<ActionPlanDeclareAction>(), hasLength(1));
  });

  testWidgets('Mission Locale : pas de déclaration sans commentaire non vide', (tester) async {
    final store = await pump(tester, milo());

    await tester.tap(find.text(Strings.dateSuggestionHier));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, '   ');
    await tester.pump();
    await tester.tap(find.text(Strings.markActionAsDone));
    await tester.pump();

    expect(store.dispatchedActions.whereType<ActionPlanDeclareAction>(), isEmpty);
  });

  testWidgets('pendant le chargement, le bouton ne déclare pas une seconde fois', (tester) async {
    final store = await pump(tester, milo(ActionPlanDeclarationLoadingState()));

    await tester.tap(find.text(Strings.dateSuggestionHier));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, 'Mon CV');
    await tester.pump();
    await tester.tap(find.text(Strings.markActionAsDone), warnIfMissed: false);
    await tester.pump();

    expect(store.dispatchedActions.whereType<ActionPlanDeclareAction>(), isEmpty);
  });

  testWidgets("affiche le message d'échec", (tester) async {
    await pump(tester, milo(ActionPlanDeclarationFailureState(ActionPlanDeclarationFailureReason.solutionRetiree)));

    expect(find.text(Strings.actionPlanDeclarationSolutionRetiree), findsOneWidget);
  });

  testWidgets('affiche le succès', (tester) async {
    await pump(tester, milo(ActionPlanDeclarationSuccessState()));

    expect(find.text(Strings.actionPlanDeclarationSuccesEnregistree), findsOneWidget);
    expect(find.text(Strings.actionPlanDeclarationVoirAgenda), findsOneWidget);
    expect(find.text(Strings.actionPlanDeclarationRetourPlan), findsOneWidget);
  });
}
