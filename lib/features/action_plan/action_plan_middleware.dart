import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
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
      store.dispatch(ActionPlanLoadingAction());
      final plan = await _repository.generate(action.answers);
      if (plan == null) {
        store.dispatch(ActionPlanFailureAction());
      } else {
        store.dispatch(ActionPlanSuccessAction(plan));
      }
    } else if (action is ActionPlanToggleDoneAction) {
      final plan = await _repository.toggleDone(action.actionId);
      if (plan != null) store.dispatch(ActionPlanSuccessAction(plan));
    } else if (action is ActionPlanDeleteAction) {
      final plan = await _repository.deleteAction(action.actionId);
      if (plan != null) store.dispatch(ActionPlanSuccessAction(plan));
    }
  }
}
