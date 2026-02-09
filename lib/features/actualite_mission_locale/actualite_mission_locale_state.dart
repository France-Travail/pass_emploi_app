import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/actualite_mission_locale.dart';

sealed class ActualiteMissionLocaleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ActualiteMissionLocaleNotInitializedState extends ActualiteMissionLocaleState {}

class ActualiteMissionLocaleLoadingState extends ActualiteMissionLocaleState {}

class ActualiteMissionLocaleFailureState extends ActualiteMissionLocaleState {}

class ActualiteMissionLocaleSuccessState extends ActualiteMissionLocaleState {
  final List<ActualiteMissionLocale> result;

  ActualiteMissionLocaleSuccessState(this.result);

  @override
  List<Object?> get props => [result];
}
