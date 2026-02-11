import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_state.dart';
import 'package:pass_emploi_app/models/actualite_mission_locale.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';
import 'package:redux/redux.dart';

class ActualiteMissionLocaleViewModel extends Equatable {
  ActualiteMissionLocaleViewModel({
    required this.displayState,
    required this.actualites,
    required this.onRetry,
  });

  final DisplayState displayState;
  final List<ActualiteMissionLocaleItemViewModel> actualites;
  final VoidCallback onRetry;

  factory ActualiteMissionLocaleViewModel.create(Store<AppState> store) {
    final state = store.state.actualiteMissionLocaleState;
    return ActualiteMissionLocaleViewModel(
      displayState: _displayState(state),
      actualites: _actualites(state),
      onRetry: () => store.dispatch(ActualiteMissionLocaleRequestAction()),
    );
  }

  @override
  List<Object?> get props => [displayState, actualites];
}

DisplayState _displayState(ActualiteMissionLocaleState state) {
  return switch (state) {
    ActualiteMissionLocaleNotInitializedState() => DisplayState.LOADING,
    ActualiteMissionLocaleLoadingState() => DisplayState.LOADING,
    ActualiteMissionLocaleFailureState() => DisplayState.FAILURE,
    ActualiteMissionLocaleSuccessState() => state.result.isEmpty ? DisplayState.EMPTY : DisplayState.CONTENT,
  };
}

List<ActualiteMissionLocaleItemViewModel> _actualites(ActualiteMissionLocaleState state) {
  if (state is! ActualiteMissionLocaleSuccessState) return [];
  final sorted = [...state.result]..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
  return sorted.map(ActualiteMissionLocaleItemViewModel.fromModel).toList();
}

class ActualiteMissionLocaleItemViewModel extends Equatable {
  final String titre;
  final String corps;
  final String lien;
  final String titreDuLien;
  final String nomConseiller;
  final String dateCreation;

  ActualiteMissionLocaleItemViewModel({
    required this.titre,
    required this.corps,
    required this.lien,
    required this.titreDuLien,
    required this.nomConseiller,
    required this.dateCreation,
  });

  factory ActualiteMissionLocaleItemViewModel.fromModel(ActualiteMissionLocale actualite) {
    return ActualiteMissionLocaleItemViewModel(
      titre: actualite.titre,
      corps: actualite.corps,
      lien: actualite.lien,
      titreDuLien: actualite.titreDuLien,
      nomConseiller: actualite.nomConseiller,
      dateCreation: actualite.dateCreation.toDayWithFullMonthContextualized(),
    );
  }

  @override
  List<Object?> get props => [titre, corps, lien, titreDuLien, nomConseiller, dateCreation];
}
