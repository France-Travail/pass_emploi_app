import 'package:equatable/equatable.dart';

sealed class AutoDesinscriptionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AutoDesinscriptionNotInitializedState extends AutoDesinscriptionState {}

class AutoDesinscriptionLoadingState extends AutoDesinscriptionState {}

class AutoDesinscriptionFailureState extends AutoDesinscriptionState {}

class AutoDesinscriptionSuccessState extends AutoDesinscriptionState {
  final bool result;

  AutoDesinscriptionSuccessState(this.result);

  @override
  List<Object?> get props => [result];
}
