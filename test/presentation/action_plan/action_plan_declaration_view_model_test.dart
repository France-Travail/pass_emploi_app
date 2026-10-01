import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_declaration_state.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/features/deep_link/deep_link_actions.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/presentation/action_plan/action_plan_declaration_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_repository.dart';
import 'package:pass_emploi_app/ui/strings.dart';

import '../../dsl/app_state_dsl.dart';

void main() {
  const actionId = 'tache-1';

  ActionPlan plan() => const ActionPlan(
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

  AppState milo([ActionPlanDeclarationState? declaration]) => givenState().loggedInMiloUser().copyWith(
        actionPlanState: ActionPlanSuccessState(plan()),
        actionPlanDeclarationState: declaration ?? ActionPlanDeclarationNotInitializedState(),
      );

  test('expose le libellé, la catégorie et demande un commentaire en Mission Locale', () {
    final viewModel = ActionPlanDeclarationViewModel.create(milo().spyStore(), actionId);

    expect(viewModel.titre, 'Je crée mon CV');
    expect(viewModel.categorie, 'Emploi');
    expect(viewModel.commentaireRequis, isTrue);
    expect(viewModel.displayState, DisplayState.EMPTY);
    expect(viewModel.messageErreur, isNull);
  });

  test("ne demande pas de commentaire à un jeune France Travail", () {
    final state = givenState().loggedInPoleEmploiUser().copyWith(actionPlanState: ActionPlanSuccessState(plan()));

    final viewModel = ActionPlanDeclarationViewModel.create(state.spyStore(), actionId);

    expect(viewModel.commentaireRequis, isFalse);
  });

  test('traduit chaque échec en message', () {
    for (final (reason, message) in [
      (ActionPlanDeclarationFailureReason.solutionRetiree, Strings.actionPlanDeclarationSolutionRetiree),
      (ActionPlanDeclarationFailureReason.indisponible, Strings.actionPlanDeclarationIndisponible),
      (ActionPlanDeclarationFailureReason.autre, Strings.miscellaneousErrorRetry),
    ]) {
      final viewModel = ActionPlanDeclarationViewModel.create(
        milo(ActionPlanDeclarationFailureState(actionId, reason)).spyStore(),
        actionId,
      );

      expect(viewModel.displayState, DisplayState.FAILURE, reason: reason.name);
      expect(viewModel.messageErreur, message, reason: reason.name);
    }
  });

  test('passe en chargement puis en succès', () {
    expect(
      ActionPlanDeclarationViewModel.create(milo(ActionPlanDeclarationLoadingState(actionId)).spyStore(), actionId)
          .displayState,
      DisplayState.LOADING,
    );
    expect(
      ActionPlanDeclarationViewModel.create(milo(ActionPlanDeclarationSuccessState(actionId)).spyStore(), actionId)
          .displayState,
      DisplayState.CONTENT,
    );
  });

  test("ignore l'état de déclaration d'une autre tâche", () {
    for (final declaration in [
      ActionPlanDeclarationFailureState('autre-tache', ActionPlanDeclarationFailureReason.indisponible),
      ActionPlanDeclarationSuccessState('autre-tache'),
      ActionPlanDeclarationLoadingState('autre-tache'),
    ]) {
      final viewModel = ActionPlanDeclarationViewModel.create(milo(declaration).spyStore(), actionId);

      expect(viewModel.displayState, DisplayState.EMPTY);
      expect(viewModel.messageErreur, isNull);
    }
  });

  test('déclare avec le commentaire trimé en Mission Locale', () {
    final store = milo().spyStore();
    final date = DateTime(2026, 9, 30);

    ActionPlanDeclarationViewModel.create(store, actionId).onDeclare(date, '  Mon CV  ');

    final action = store.dispatchedAction as ActionPlanDeclareAction;
    expect(action.actionId, actionId);
    expect(action.date, date);
    expect(action.commentaire, 'Mon CV');
  });

  test("déclare sans commentaire pour France Travail", () {
    final store = givenState()
        .loggedInPoleEmploiUser()
        .copyWith(actionPlanState: ActionPlanSuccessState(plan()))
        .spyStore();

    ActionPlanDeclarationViewModel.create(store, actionId).onDeclare(DateTime(2026, 9, 30), 'ignoré');

    expect((store.dispatchedAction as ActionPlanDeclareAction).commentaire, isNull);
  });

  test('voir mon agenda ouvre Mon suivi', () {
    final store = milo().spyStore();

    ActionPlanDeclarationViewModel.create(store, actionId).onVoirAgenda();

    expect(store.dispatchedAction, isA<HandleDeepLinkAction>());
  });
}
