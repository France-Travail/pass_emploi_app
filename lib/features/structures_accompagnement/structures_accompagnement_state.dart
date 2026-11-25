import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';

sealed class StructuresAccompagnementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StructuresAccompagnementNotInitializedState extends StructuresAccompagnementState {}

class StructuresAccompagnementLoadingState extends StructuresAccompagnementState {
  final StructuresAccompagnementRequest request;

  StructuresAccompagnementLoadingState(this.request);

  @override
  List<Object?> get props => [request];
}

class StructuresAccompagnementFailureState extends StructuresAccompagnementState {
  final StructuresAccompagnementRequest request;

  StructuresAccompagnementFailureState(this.request);

  @override
  List<Object?> get props => [request];
}

class StructuresAccompagnementSuccessState extends StructuresAccompagnementState {
  final StructuresAccompagnementRequest request;
  final List<StructureAccompagnement> result;

  StructuresAccompagnementSuccessState(this.request, this.result);

  @override
  List<Object?> get props => [request, result];
}
