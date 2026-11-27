import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/cgu.dart';

sealed class CguState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CguNotInitializedState extends CguState {}

class CguAlreadyAcceptedState extends CguState {}

class CguNeverAcceptedState extends CguState {
  /// La dernière tentative d'acceptation a échoué.
  final bool acceptFailed;

  CguNeverAcceptedState({this.acceptFailed = false});

  @override
  List<Object?> get props => [acceptFailed];
}

class CguUpdateRequiredState extends CguState {
  final Cgu updatedCgu;

  /// La dernière tentative d'acceptation a échoué.
  final bool acceptFailed;

  CguUpdateRequiredState(this.updatedCgu, {this.acceptFailed = false});

  @override
  List<Object?> get props => [updatedCgu, acceptFailed];
}
