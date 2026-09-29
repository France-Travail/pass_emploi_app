import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_tracking.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_repository.dart';
import 'package:redux/redux.dart';

class ActionPlanMiddleware extends MiddlewareClass<AppState> {
  final ActionPlanRepository _repository;

  ActionPlanMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    if (action is ActionPlanRequestAction) {
      // For a jeune accompagné, the plan is synced with the server by the onboarding questionnaire middleware.
      if (_persistedPlanUserId(store) != null) return;
      await _loadStoredPlan(store);
    } else if (action is ActionPlanGenerateAction) {
      final userId = store.state.userId();
      if (userId == null) {
        store.dispatch(ActionPlanFailureAction());
        return;
      }
      store.dispatch(ActionPlanLoadingAction());
      final plan = await _repository.generate(
        userId,
        action.answers,
        keepLocalProgress: store.state.isInviteLoginMode(),
      );
      if (plan == null) {
        store.dispatch(ActionPlanFailureAction());
      } else {
        store.dispatch(ActionPlanSuccessAction(plan));
      }
    } else if (action is ActionPlanToggleDoneAction) {
      final before = _currentPlan(store);
      final userId = _persistedPlanUserId(store);
      if (userId != null) {
        final current = before?.findAction(action.actionId);
        if (current == null) return;
        final sent = await _repository.sendDone(userId, action.actionId, done: !current.done);
        if (!sent) {
          store.dispatch(ActionPlanFailureAction());
          return;
        }
      }
      final plan = await _repository.toggleDone(action.actionId);
      if (plan != null) {
        store.dispatch(ActionPlanSuccessAction(plan));
        _track(before, plan, action.actionId, deleted: false);
      }
    } else if (action is ActionPlanDeleteAction) {
      final before = _currentPlan(store);
      final userId = _persistedPlanUserId(store);
      if (userId != null) {
        if (before?.findAction(action.actionId) == null) return;
        final sent = await _repository.sendDelete(userId, action.actionId);
        if (!sent) {
          store.dispatch(ActionPlanFailureAction());
          return;
        }
      }
      final plan = await _repository.deleteAction(action.actionId);
      if (plan != null) {
        store.dispatch(ActionPlanSuccessAction(plan));
        _track(before, plan, action.actionId, deleted: true);
      }
    } else if (action is ActionPlanFeedbackAction) {
      final plan = await _repository.giveFeedback(action.objectiveId);
      if (plan != null) store.dispatch(ActionPlanSuccessAction(plan));
    }
  }

  Future<void> _loadStoredPlan(Store<AppState> store) async {
    store.dispatch(ActionPlanLoadingAction());
    final plan = await _repository.getStoredPlan();
    if (plan == null) {
      store.dispatch(ActionPlanEmptyAction());
    } else {
      store.dispatch(ActionPlanSuccessAction(plan));
    }
  }

  String? _persistedPlanUserId(Store<AppState> store) {
    if (store.state.isInviteLoginMode()) return null;
    return store.state.userId();
  }

  ActionPlan? _currentPlan(Store<AppState> store) {
    final state = store.state.actionPlanState;
    return state is ActionPlanSuccessState ? state.plan : null;
  }

  void _track(ActionPlan? before, ActionPlan after, String actionId, {required bool deleted}) {
    for (final event in actionPlanChangeEvents(before: before, after: after, actionId: actionId, deleted: deleted)) {
      event.send();
    }
  }
}
