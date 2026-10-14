import 'package:equatable/equatable.dart';

sealed class RepriseCompteInviteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RepriseCompteInviteNotInitializedState extends RepriseCompteInviteState {}

class RepriseCompteInviteLoadingState extends RepriseCompteInviteState {}

class RepriseCompteInviteFailureState extends RepriseCompteInviteState {
  final String message;

  RepriseCompteInviteFailureState(this.message);

  @override
  List<Object?> get props => [message];
}

class RepriseCompteInviteWrongDeviceClockState extends RepriseCompteInviteState {}
