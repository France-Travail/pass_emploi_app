import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/features/mode_demo/plan_action/mode_demo_plan_action.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_loader_step.dart';
import 'package:pass_emploi_app/redux/app_reducer.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

void main() {
  test("seule la demande de génération du plan prend le temps d'une vraie génération", () {
    RequestOptions requete(String methode, String chemin) => RequestOptions(method: methode, path: chemin);
    final demo = ModeDemoPlanAction.instance;

    expect(demo.isGeneration(requete("POST", "/jeunes/SEVP/plan-action")), isTrue);
    expect(demo.isGeneration(requete("GET", "/jeunes/SEVP/plan-action")), isFalse);
    expect(demo.isGeneration(requete("PATCH", "/jeunes/SEVP/plan-action/taches/demo-tache-26")), isFalse);
  });

  testWidgets("avec le temps de génération de la démo, l'écran de génération mène à l'accueil", (tester) async {
    const plan = ActionPlan(id: ModeDemoPlanAction.planId, greeting: "", objectives: []);
    final actions = <dynamic>[];
    final store = Store<AppState>(
      reducer,
      initialState: AppState.initialState().copyWith(actionPlanState: ActionPlanSuccessState(plan)),
      middleware: [
        (store, action, next) {
          actions.add(action);
          next(action);
          if (action is OnboardingQuestionnaireCompleteAction) {
            store.dispatch(ActionPlanLoadingAction());
            Future<void>.delayed(
              ModeDemoPlanAction.generationDuration,
              () => store.dispatch(ActionPlanSuccessAction(plan)),
            );
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
    for (var i = 0; i < 80; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(actions.whereType<OnboardingQuestionnaireFinishAction>(), hasLength(1));
  });
}
