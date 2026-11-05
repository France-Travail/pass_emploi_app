import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_loader_step.dart';
import 'package:pass_emploi_app/redux/app_reducer.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

void main() {
  testWidgets("une génération plus brève qu'un tic (mode démo) mène quand même à l'accueil", (tester) async {
    const plan = ActionPlan(id: "plan", greeting: "", objectives: []);
    final actions = <dynamic>[];
    final store = Store<AppState>(
      reducer,
      initialState: AppState.initialState().copyWith(actionPlanState: ActionPlanSuccessState(plan)),
      middleware: [
        (store, action, next) {
          actions.add(action);
          next(action);
          // Plan rendu dans la foulée, sans attente réseau : l'état « en cours » ne dure pas jusqu'au tic suivant.
          if (action is OnboardingQuestionnaireCompleteAction) {
            store.dispatch(ActionPlanLoadingAction());
            store.dispatch(ActionPlanSuccessAction(plan));
          }
        },
      ],
    );

    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: const MaterialApp(
          home: Scaffold(body: OnboardingQuestionnaireLoaderStep(answers: OnboardingQuestionnaireAnswers())),
        ),
      ),
    );
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(actions.whereType<OnboardingQuestionnaireFinishAction>(), hasLength(1));
  });
}
