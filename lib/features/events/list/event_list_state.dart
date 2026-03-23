import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/rendezvous.dart';
import 'package:pass_emploi_app/models/session_milo.dart';

abstract class EventListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EventListNotInitializedState extends EventListState {}

class EventListLoadingState extends EventListState {}

class EventListFailureState extends EventListState {}

class EventListSuccessState extends EventListState {
  final List<Rendezvous> animationsCollectives;
  final List<SessionMilo> sessionsMilos;
  final List<String> selectedAntennes;

  EventListSuccessState(this.animationsCollectives, this.sessionsMilos, {this.selectedAntennes = const []});

  @override
  List<Object?> get props => [animationsCollectives, sessionsMilos, selectedAntennes];

  EventListSuccessState copyWith({
    List<Rendezvous>? animationsCollectives,
    List<SessionMilo>? sessionsMilos,
    List<String>? selectedAntennes,
  }) {
    return EventListSuccessState(
      animationsCollectives ?? this.animationsCollectives,
      sessionsMilos ?? this.sessionsMilos,
      selectedAntennes: selectedAntennes ?? this.selectedAntennes,
    );
  }
}
