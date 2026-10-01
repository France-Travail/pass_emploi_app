import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:redux/redux.dart';

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
          home: Scaffold(body: ActionPlanDeclarationBottomSheet(actionId: actionId)),
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
    expect(find.text(Strings.actionPlanDeclarationDecrireAide), findsOneWidget);
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
    final store = await pump(tester, milo(ActionPlanDeclarationLoadingState(actionId)));

    await tester.tap(find.text(Strings.dateSuggestionHier));
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, 'Mon CV');
    await tester.pump();
    await tester.tap(find.text(Strings.markActionAsDone), warnIfMissed: false);
    await tester.pump();

    expect(store.dispatchedActions.whereType<ActionPlanDeclareAction>(), isEmpty);
  });

  testWidgets('pendant le chargement, la bottomsheet ne peut pas être fermée', (tester) async {
    await pump(tester, milo(ActionPlanDeclarationLoadingState(actionId)));

    expect(find.text(Strings.close), findsNothing);
    expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isFalse);
  });

  testWidgets("hors chargement, la bottomsheet peut être fermée", (tester) async {
    await pump(tester, milo());

    expect(find.text(Strings.close), findsOneWidget);
    expect(tester.widget<PopScope>(find.byType(PopScope)).canPop, isTrue);
  });

  testWidgets('pendant le chargement, affiche un indicateur', (tester) async {
    await pump(tester, milo(ActionPlanDeclarationLoadingState(actionId)));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets("affiche le message d'échec", (tester) async {
    await pump(tester, milo(ActionPlanDeclarationFailureState(actionId, ActionPlanDeclarationFailureReason.solutionRetiree)));

    expect(find.text(Strings.actionPlanDeclarationSolutionRetiree), findsOneWidget);
  });

  testWidgets('affiche le succès', (tester) async {
    await pump(tester, milo(ActionPlanDeclarationSuccessState(actionId)));

    expect(find.text(Strings.actionPlanDeclarationSuccesEnregistree), findsOneWidget);
    expect(find.text(Strings.actionPlanDeclarationVoirAgenda), findsOneWidget);
    expect(find.text(Strings.actionPlanDeclarationRetourPlan), findsOneWidget);
  });

  testWidgets('le bouton Marquer comme terminé est fixé en bas, hors du contenu défilant', (tester) async {
    await pump(tester, milo());

    expect(
      find.ancestor(of: find.text(Strings.markActionAsDone), matching: find.byType(SingleChildScrollView)),
      findsNothing,
    );
    expect(
      find.ancestor(of: find.text(Strings.actionPlanDeclarationQuand), matching: find.byType(SingleChildScrollView)),
      findsOneWidget,
    );
  });

  testWidgets("show réinitialise la déclaration avant d'ouvrir la bottomsheet", (tester) async {
    final store = StoreSpy.withState(
      milo(ActionPlanDeclarationFailureState(actionId, ActionPlanDeclarationFailureReason.autre)),
    );
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => ActionPlanDeclarationBottomSheet.show(context, actionId),
              child: const Text('ouvrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ouvrir'));
    await tester.pumpAndSettle();

    expect(store.dispatchedActions.whereType<ActionPlanDeclarationResetAction>(), hasLength(1));
    expect(find.byType(ActionPlanDeclarationBottomSheet), findsOneWidget);
  });

  group("annonces pour lecteur d'écran", () {
    Future<List<String>> pumpEtCapteAnnonces(WidgetTester tester, AppState initial, List<AppState> transitions) async {
      final annonces = <String>[];
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (message) async {
        final map = message as Map;
        if (map['type'] == 'announce') annonces.add((map['data'] as Map)['message'] as String);
        return null;
      });
      addTearDown(() => messenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, null));
      final store = Store<AppState>((state, action) => action is AppState ? action : state, initialState: initial);
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(home: Scaffold(body: ActionPlanDeclarationBottomSheet(actionId: actionId))),
        ),
      );
      for (final transition in transitions) {
        store.dispatch(transition);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
      }
      return annonces;
    }

    testWidgets("annonce le message d'échec", (tester) async {
      final annonces = await pumpEtCapteAnnonces(tester, milo(), [
        milo(ActionPlanDeclarationLoadingState(actionId)),
        milo(ActionPlanDeclarationFailureState(actionId, ActionPlanDeclarationFailureReason.solutionRetiree)),
      ]);

      expect(annonces, [Strings.actionPlanDeclarationSolutionRetiree]);
    });

    testWidgets('annonce la confirmation au succès', (tester) async {
      final annonces = await pumpEtCapteAnnonces(tester, milo(), [
        milo(ActionPlanDeclarationLoadingState(actionId)),
        milo(ActionPlanDeclarationSuccessState(actionId)),
      ]);

      final prenom = milo().user()!.firstName;
      expect(annonces, [
        '${Strings.userActionConfirmationTitle(prenom)} ${Strings.actionPlanDeclarationSuccesEnregistree}',
      ]);
    });
  });
}
