import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';

sealed class ActionPlanState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ActionPlanNotInitializedState extends ActionPlanState {}

class ActionPlanLoadingState extends ActionPlanState {}

class ActionPlanSuccessState extends ActionPlanState {
  final ActionPlan plan;

  ActionPlanSuccessState(this.plan);

  @override
  List<Object?> get props => [plan];
}

class ActionPlanEmptyState extends ActionPlanState {}

class ActionPlanFailureState extends ActionPlanState {}
