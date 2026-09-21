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
      store.dispatch(ActionPlanLoadingAction());
      final plan = await _repository.getStoredPlan();
      if (plan == null) {
        store.dispatch(ActionPlanEmptyAction());
      } else {
        store.dispatch(ActionPlanSuccessAction(plan));
      }
    } else if (action is ActionPlanGenerateAction) {
      final userId = store.state.userId();
      if (userId == null) {
        store.dispatch(ActionPlanFailureAction());
        return;
      }
      store.dispatch(ActionPlanLoadingAction());
      final plan = await _repository.generate(userId, action.answers);
      if (plan == null) {
        store.dispatch(ActionPlanFailureAction());
      } else {
        store.dispatch(ActionPlanSuccessAction(plan));
      }
    } else if (action is ActionPlanToggleDoneAction) {
      final before = _currentPlan(store);
      final plan = await _repository.toggleDone(action.actionId);
      if (plan != null) {
        store.dispatch(ActionPlanSuccessAction(plan));
        _track(before, plan, action.actionId, deleted: false);
      }
    } else if (action is ActionPlanDeleteAction) {
      final before = _currentPlan(store);
      final plan = await _repository.deleteAction(action.actionId);
      if (plan != null) {
        store.dispatch(ActionPlanSuccessAction(plan));
        _track(before, plan, action.actionId, deleted: true);
      }
    }
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
