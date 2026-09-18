import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/accueil/message_informatif.dart';

sealed class CommunicationsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CommunicationsNotInitializedState extends CommunicationsState {}

class CommunicationsLoadingState extends CommunicationsState {}

class CommunicationsFailureState extends CommunicationsState {}

class CommunicationsSuccessState extends CommunicationsState {
  final MessageInformatif? messageInformatif;

  CommunicationsSuccessState(this.messageInformatif);

  @override
  List<Object?> get props => [messageInformatif];
}
