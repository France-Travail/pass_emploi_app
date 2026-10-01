import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_declaration_state.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_repository.dart';

import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../utils/test_setup.dart';

void main() {
  late MockActionPlanRepository repository;

  const actionId = '11111111-1111-1111-1111-111111111111';

  ActionPlan planWith({required bool done}) {
    return ActionPlan(
      id: 'plan',
      greeting: '',
      objectives: [
        ActionPlanObjective(
          id: 'objective',
          title: 'Trouver une alternance',
          theme: 'ALTERNANCE',
          actions: [ActionPlanAction(id: actionId, label: 'A', kind: ActionPlanActionKind.advice, done: done)],
        ),
      ],
    );
  }

  setUp(() {
    repository = MockActionPlanRepository();
  });

  Future<AppState> dispatchAndWait(
    AppState initialState,
    dynamic action,
    bool Function(ActionPlanState) until,
  ) async {
    final factory = TestStoreFactory()..actionPlanRepository = repository;
    final store = factory.initializeReduxStore(initialState: initialState);
    final result = store.onChange.firstWhere((state) => until(state.actionPlanState));
    store.dispatch(action);
    return result;
  }

  bool isSuccess(ActionPlanState state) => state is ActionPlanSuccessState;

  void dispatchFrom(AppState initialState, dynamic action) {
    final factory = TestStoreFactory()..actionPlanRepository = repository;
    factory.initializeReduxStore(initialState: initialState).dispatch(action);
  }

  bool isFailure(ActionPlanState state) => state is ActionPlanFailureState;

  group('for a jeune accompagné', () {
    final loggedIn = givenState().loggedInMiloUser();
    final withUncheckedPlan = loggedIn.copyWith(actionPlanState: ActionPlanSuccessState(planWith(done: false)));
    final withCheckedPlan = loggedIn.copyWith(actionPlanState: ActionPlanSuccessState(planWith(done: true)));

    test('request keeps the plan synced with the server and never reads the stored one', () async {
      final factory = TestStoreFactory()..actionPlanRepository = repository;
      final store = factory.initializeReduxStore(
        initialState: loggedIn.copyWith(actionPlanState: ActionPlanFailureState()),
      );

      store.dispatch(ActionPlanRequestAction());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(store.state.actionPlanState, isA<ActionPlanFailureState>());
      verifyNever(() => repository.getStoredPlan());
      verifyNever(() => repository.fetch(any()));
    });

    group('declare', () {
      final date = DateTime(2026, 9, 30);

      Future<AppState> declareAndWait(AppState initialState, bool Function(ActionPlanDeclarationState) until) async {
        final factory = TestStoreFactory()..actionPlanRepository = repository;
        final store = factory.initializeReduxStore(initialState: initialState);
        final result = store.onChange.firstWhere((state) => until(state.actionPlanDeclarationState));
        store.dispatch(ActionPlanDeclareAction(actionId, date, 'Mon CV'));
        return result;
      }

      test('declares on the server, checks the action locally, then succeeds', () async {
        when(() => repository.toggleDone(actionId)).thenAnswer((_) async => planWith(done: true));

        final state = await declareAndWait(
          withUncheckedPlan,
          (state) => state is ActionPlanDeclarationSuccessState,
        );

        verify(() => repository.sendDeclaration(loggedIn.userId()!, actionId, date: date, commentaire: 'Mon CV'))
            .called(1);
        expect(state.actionPlanState, ActionPlanSuccessState(planWith(done: true)));
      });

      test('keeps the plan untouched and fails with the reason when the server refuses', () async {
        when(
          () => repository.sendDeclaration(any(), any(), date: any(named: 'date'), commentaire: any(named: 'commentaire')),
        ).thenAnswer((_) async => ActionPlanDeclarationFailure(ActionPlanDeclarationFailureReason.solutionRetiree));

        final state = await declareAndWait(
          withUncheckedPlan,
          (state) => state is ActionPlanDeclarationFailureState,
        );

        expect(
          state.actionPlanDeclarationState,
          ActionPlanDeclarationFailureState(ActionPlanDeclarationFailureReason.solutionRetiree),
        );
        expect(state.actionPlanState, ActionPlanSuccessState(planWith(done: false)));
        verifyNever(() => repository.toggleDone(any()));
      });

      test('fails without calling the server when the action is not in the plan', () async {
        final state = await declareAndWait(
          loggedIn.copyWith(actionPlanState: ActionPlanEmptyState()),
          (state) => state is ActionPlanDeclarationFailureState,
        );

        expect(
          state.actionPlanDeclarationState,
          ActionPlanDeclarationFailureState(ActionPlanDeclarationFailureReason.autre),
        );
        verifyNever(
          () => repository.sendDeclaration(any(), any(), date: any(named: 'date'), commentaire: any(named: 'commentaire')),
        );
      });

      test('reset brings the declaration back to not initialized', () async {
        final factory = TestStoreFactory()..actionPlanRepository = repository;
        final store = factory.initializeReduxStore(
          initialState: withUncheckedPlan.copyWith(
            actionPlanDeclarationState: ActionPlanDeclarationFailureState(ActionPlanDeclarationFailureReason.autre),
          ),
        );

        store.dispatch(ActionPlanDeclarationResetAction());

        expect(store.state.actionPlanDeclarationState, ActionPlanDeclarationNotInitializedState());
      });
    });

    group('toggle', () {
      test('checks the action on the server then locally', () async {
        when(() => repository.toggleDone(actionId)).thenAnswer((_) async => planWith(done: true));

        dispatchFrom(withUncheckedPlan, ActionPlanToggleDoneAction(actionId));

        await untilCalled(() => repository.toggleDone(actionId));
        verify(() => repository.sendDone(loggedIn.userId()!, actionId, done: true)).called(1);
      });

      test('unchecks the action on the server', () async {
        when(() => repository.toggleDone(actionId)).thenAnswer((_) async => planWith(done: false));

        dispatchFrom(withCheckedPlan, ActionPlanToggleDoneAction(actionId));

        await untilCalled(() => repository.toggleDone(actionId));
        verify(() => repository.sendDone(loggedIn.userId()!, actionId, done: false)).called(1);
      });

      test('shows failure and keeps local plan untouched when the server fails', () async {
        when(() => repository.sendDone(any(), any(), done: any(named: 'done'))).thenAnswer((_) async => false);

        final state = await dispatchAndWait(withUncheckedPlan, ActionPlanToggleDoneAction(actionId), isFailure);

        expect(state.actionPlanState, isA<ActionPlanFailureState>());
        verifyNever(() => repository.toggleDone(any()));
      });
    });

    group('delete', () {
      test('deletes the action on the server then locally', () async {
        when(() => repository.deleteAction(actionId)).thenAnswer((_) async => planWith(done: false));

        dispatchFrom(withUncheckedPlan, ActionPlanDeleteAction(actionId));

        await untilCalled(() => repository.deleteAction(actionId));
        verify(() => repository.sendDelete(loggedIn.userId()!, actionId)).called(1);
      });

      test('shows failure and keeps local plan untouched when the server fails', () async {
        when(() => repository.sendDelete(any(), any())).thenAnswer((_) async => false);

        final state = await dispatchAndWait(withUncheckedPlan, ActionPlanDeleteAction(actionId), isFailure);

        expect(state.actionPlanState, isA<ActionPlanFailureState>());
        verifyNever(() => repository.deleteAction(any()));
      });
    });

    test('generates the plan without keeping local progress', () async {
      const answers = OnboardingQuestionnaireAnswers(
        situation: QuestionnaireSituation.lycee,
        objectifs: {QuestionnaireObjectif.emploi},
      );
      when(
        () => repository.generate(any(), any(), keepLocalProgress: any(named: 'keepLocalProgress')),
      ).thenAnswer((_) async => planWith(done: false));

      await dispatchAndWait(loggedIn, ActionPlanGenerateAction(answers), isSuccess);

      verify(() => repository.generate(loggedIn.userId()!, answers, keepLocalProgress: false)).called(1);
    });
  });

  group('for an invite', () {
    final invite = givenState().loggedInUser(loginMode: LoginMode.INVITE);
    final withPlan = invite.copyWith(actionPlanState: ActionPlanSuccessState(planWith(done: false)));

    test('request loads the stored plan', () async {
      when(() => repository.getStoredPlan()).thenAnswer((_) async => planWith(done: true));

      await dispatchAndWait(invite, ActionPlanRequestAction(), isSuccess);

      verify(() => repository.getStoredPlan()).called(1);
      verifyNever(() => repository.fetch(any()));
    });

    test('toggle stays local', () async {
      when(() => repository.toggleDone(actionId)).thenAnswer((_) async => planWith(done: true));

      dispatchFrom(withPlan, ActionPlanToggleDoneAction(actionId));

      await untilCalled(() => repository.toggleDone(actionId));
      verifyNever(() => repository.sendDone(any(), any(), done: any(named: 'done')));
    });

    test('delete stays local', () async {
      when(() => repository.deleteAction(actionId)).thenAnswer((_) async => planWith(done: false));

      dispatchFrom(withPlan, ActionPlanDeleteAction(actionId));

      await untilCalled(() => repository.deleteAction(actionId));
      verifyNever(() => repository.sendDelete(any(), any()));
    });
  });
}
