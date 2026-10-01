import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_repository.dart';

sealed class ActionPlanDeclarationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ActionPlanDeclarationNotInitializedState extends ActionPlanDeclarationState {}

class ActionPlanDeclarationLoadingState extends ActionPlanDeclarationState {}

class ActionPlanDeclarationSuccessState extends ActionPlanDeclarationState {}

class ActionPlanDeclarationFailureState extends ActionPlanDeclarationState {
  final ActionPlanDeclarationFailureReason reason;

  ActionPlanDeclarationFailureState(this.reason);

  @override
  List<Object?> get props => [reason];
}
