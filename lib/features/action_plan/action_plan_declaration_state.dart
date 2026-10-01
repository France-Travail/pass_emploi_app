import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_repository.dart';

sealed class ActionPlanDeclarationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ActionPlanDeclarationNotInitializedState extends ActionPlanDeclarationState {}

class ActionPlanDeclarationLoadingState extends ActionPlanDeclarationState {
  final String actionId;

  ActionPlanDeclarationLoadingState(this.actionId);

  @override
  List<Object?> get props => [actionId];
}

class ActionPlanDeclarationSuccessState extends ActionPlanDeclarationState {
  final String actionId;

  ActionPlanDeclarationSuccessState(this.actionId);

  @override
  List<Object?> get props => [actionId];
}

class ActionPlanDeclarationFailureState extends ActionPlanDeclarationState {
  final String actionId;
  final ActionPlanDeclarationFailureReason reason;

  ActionPlanDeclarationFailureState(this.actionId, this.reason);

  @override
  List<Object?> get props => [actionId, reason];
}
