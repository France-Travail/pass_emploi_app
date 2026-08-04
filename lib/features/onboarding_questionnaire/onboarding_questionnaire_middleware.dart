import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_repository.dart';
import 'package:pass_emploi_app/repositories/onboarding_questionnaire_repository.dart';
import 'package:redux/redux.dart';

class OnboardingQuestionnaireMiddleware extends MiddlewareClass<AppState> {
  final OnboardingQuestionnaireRepository _repository;
  final ActionPlanRepository _actionPlanRepository;

  OnboardingQuestionnaireMiddleware(this._repository, this._actionPlanRepository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    if (action is LoginSuccessAction && action.user.loginMode.isInvite()) {
      await _load(store);
    } else if (action is OnboardingQuestionnaireRequestAction) {
      await _load(store);
    } else if (action is OnboardingQuestionnaireCompleteAction) {
      await _complete(store, action.answers);
    } else if (action is OnboardingQuestionnaireFinishAction) {
      store.dispatch(OnboardingQuestionnaireSuccessAction(finished: true, answers: action.answers));
    } else if (action is OnboardingQuestionnaireResumeAction) {
      await _resume(store);
    } else if (action is OnboardingQuestionnaireAnswersUpdatedAction) {
      await _repository.saveAnswers(action.answers);
    }
  }

  Future<void> _load(Store<AppState> store) async {
    final answers = await _repository.getAnswers();
    final finished = await _repository.isFinished();
    store.dispatch(OnboardingQuestionnaireSuccessAction(finished: finished, answers: answers));
  }

  Future<void> _complete(Store<AppState> store, OnboardingQuestionnaireAnswers answers) async {
    await _repository.saveAnswers(answers);
    if (answers.canGenerateActionPlan) {
      final userId = store.state.userId();
      if (userId == null) {
        store.dispatch(ActionPlanLoadingAction());
        store.dispatch(ActionPlanFailureAction());
      } else {
        store.dispatch(ActionPlanLoadingAction());
        final plan = await _actionPlanRepository.generate(userId, answers);
        if (plan != null) {
          store.dispatch(ActionPlanSuccessAction(plan));
        } else {
          store.dispatch(ActionPlanFailureAction());
        }
      }
      // Persisted early so a kill during the 100% animation still skips the questionnaire on relaunch.
      // `finished: true` in state is deferred to [OnboardingQuestionnaireFinishAction] so the UI can show 100%.
      await _repository.setFinished(true);
    } else {
      store.dispatch(ActionPlanEmptyAction());
      await _repository.setFinished(true);
      // No loader when generate is skipped: mark finished immediately so the router leaves the questionnaire.
      store.dispatch(OnboardingQuestionnaireSuccessAction(finished: true, answers: answers));
    }
  }

  Future<void> _resume(Store<AppState> store) async {
    final answers = await _repository.getAnswers();
    await _repository.setFinished(false);
    store.dispatch(OnboardingQuestionnaireSuccessAction(finished: false, answers: answers));
  }
}
