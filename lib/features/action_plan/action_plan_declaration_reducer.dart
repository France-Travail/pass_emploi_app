import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_declaration_state.dart';

ActionPlanDeclarationState actionPlanDeclarationReducer(ActionPlanDeclarationState current, dynamic action) {
  if (action is ActionPlanDeclarationResetAction) return ActionPlanDeclarationNotInitializedState();
  if (action is ActionPlanDeclarationLoadingAction) return ActionPlanDeclarationLoadingState(action.actionId);
  if (action is ActionPlanDeclarationSuccessAction) return ActionPlanDeclarationSuccessState(action.actionId);
  if (action is ActionPlanDeclarationFailureAction) return ActionPlanDeclarationFailureState(action.actionId, action.reason);
  return current;
}
