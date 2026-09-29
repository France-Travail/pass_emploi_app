import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_actions.dart';
import 'package:pass_emploi_app/features/fonctionnalites/fonctionnalites_actions.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/fonctionnalite.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_tracker.dart';
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
    } else if (action is FonctionnalitesSuccessAction && action.actives.contains(Fonctionnalite.planAction)) {
      // Fonctionnalites are fetched at login, at launch when already logged in and back to foreground:
      // the plan is synced with the server each time, unless the questionnaire is being filled.
      if (!_isQuestionnaireInProgress(store)) await _syncWithServer(store);
    } else if (action is RequestLogoutAction) {
      await _clear();
    } else if (action is OnboardingQuestionnaireRequestAction) {
      await _syncWithServer(store);
    } else if (action is OnboardingQuestionnaireCompleteAction) {
      await _complete(store, action.answers);
    } else if (action is OnboardingQuestionnaireFinishAction) {
      store.dispatch(OnboardingQuestionnaireSuccessAction(finished: true, everFinished: true, answers: action.answers));
    } else if (action is OnboardingQuestionnaireResumeAction) {
      await _resume(store);
    } else if (action is OnboardingQuestionnaireAnswersUpdatedAction) {
      await _repository.saveAnswers(action.answers);
    }
  }

  Future<void> _clear() async {
    await _repository.clear();
    await _actionPlanRepository.clear();
  }

  Future<void> _load(Store<AppState> store) async {
    final answers = await _repository.getAnswers();
    final finished = await _repository.isFinished();
    final everFinished = await _repository.hasEverFinished();
    store.dispatch(
      OnboardingQuestionnaireSuccessAction(finished: finished, everFinished: everFinished, answers: answers),
    );
  }

  bool _isQuestionnaireInProgress(Store<AppState> store) {
    final state = store.state.onboardingQuestionnaireState;
    return state is OnboardingQuestionnaireSuccessState && !state.finished;
  }

  Future<void> _syncWithServer(Store<AppState> store) async {
    final userId = store.state.userId();
    if (userId == null || store.state.isInviteLoginMode()) return _load(store);

    // A plan already displayed is refreshed silently, and so is a retry after a failure:
    // a loading state before the questionnaire is loaded would replace the app by the splash screen.
    final actionPlanState = store.state.actionPlanState;
    if (actionPlanState is! ActionPlanSuccessState && actionPlanState is! ActionPlanFailureState) {
      store.dispatch(ActionPlanLoadingAction());
    }
    switch (await _actionPlanRepository.fetch(userId)) {
      case ActionPlanFetchFound(:final plan):
        await _repository.setFinished(true);
        store.dispatch(ActionPlanSuccessAction(plan));
        await _load(store);
      case ActionPlanFetchNotFound():
        if (await _repository.isFinished()) {
          await _repository.setFinished(false);
          await _actionPlanRepository.clear();
        }
        store.dispatch(ActionPlanEmptyAction());
        await _load(store);
      case ActionPlanFetchFailure():
        store.dispatch(ActionPlanFailureAction());
    }
  }

  Future<void> _complete(Store<AppState> store, OnboardingQuestionnaireAnswers answers) async {
    final tracker = OnboardingQuestionnaireTracker(isUpdate: await _repository.hasEverFinished());
    await _repository.saveAnswers(answers);
    _persistRechercheCriteres(store, answers);
    if (answers.canGenerateActionPlan) {
      final userId = store.state.userId();
      if (userId == null) {
        store.dispatch(ActionPlanLoadingAction());
        store.dispatch(ActionPlanFailureAction());
        tracker.trackGenerationOutcome(OnboardingQuestionnaireGenerationOutcome.echec);
      } else {
        store.dispatch(ActionPlanLoadingAction());
        final plan = await _actionPlanRepository.generate(
          userId,
          answers,
          keepLocalProgress: store.state.isInviteLoginMode(),
        );
        if (plan != null) {
          store.dispatch(ActionPlanSuccessAction(plan));
          tracker.trackGenerationOutcome(
            plan.objectives.isEmpty
                ? OnboardingQuestionnaireGenerationOutcome.planVide
                : OnboardingQuestionnaireGenerationOutcome.planGenere,
            objectivesCount: plan.objectives.length,
          );
        } else {
          store.dispatch(ActionPlanFailureAction());
          tracker.trackGenerationOutcome(OnboardingQuestionnaireGenerationOutcome.echec);
        }
      }

      await _repository.setFinished(true);
    } else {
      tracker.trackGenerationOutcome(OnboardingQuestionnaireGenerationOutcome.impossible);
      store.dispatch(ActionPlanEmptyAction());
      await _repository.setFinished(true);

      store.dispatch(OnboardingQuestionnaireSuccessAction(finished: true, everFinished: true, answers: answers));
    }
  }

  void _persistRechercheCriteres(Store<AppState> store, OnboardingQuestionnaireAnswers answers) {
    final criteres = CriteresRechercheUtilisateur.fromOnboardingAnswers(answers);
    if (!criteres.hasAny) return;
    store.dispatch(CriteresRecherchePersistWriteAction(criteres));
  }

  Future<void> _resume(Store<AppState> store) async {
    final answers = await _repository.getAnswers();
    await _repository.setFinished(false);
    final everFinished = await _repository.hasEverFinished();
    store.dispatch(OnboardingQuestionnaireSuccessAction(finished: false, everFinished: everFinished, answers: answers));
  }
}
