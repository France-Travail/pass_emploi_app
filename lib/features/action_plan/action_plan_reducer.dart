import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';

ActionPlanState actionPlanReducer(ActionPlanState current, dynamic action) {
  if (action is ActionPlanLoadingAction) return ActionPlanLoadingState();
  if (action is ActionPlanSuccessAction) return ActionPlanSuccessState(action.plan);
  if (action is ActionPlanEmptyAction) return ActionPlanEmptyState();
  if (action is ActionPlanFailureAction) return ActionPlanFailureState();
  return current;
}
