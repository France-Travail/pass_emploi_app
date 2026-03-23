import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/events/list/event_list_actions.dart';
import 'package:pass_emploi_app/features/events/list/event_list_state.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

sealed class EventId extends Equatable {
  final String id;
  EventId(this.id);

  @override
  List<Object?> get props => [id];
}

class AnimationCollectiveId extends EventId {
  AnimationCollectiveId(super.id);
}

class SessionMiloId extends EventId {
  SessionMiloId(super.id);
}

class EventListPageViewModel extends Equatable {
  final DisplayState displayState;
  final List<EventId> eventIds;
  final List<String> availableAntennes;
  final List<String> selectedAntennes;
  final Function onRetry;
  final Function(List<String>) onUpdateFilters;
  final Function() onClearFilters;

  EventListPageViewModel({
    required this.displayState,
    required this.eventIds,
    required this.availableAntennes,
    required this.selectedAntennes,
    required this.onRetry,
    required this.onUpdateFilters,
    required this.onClearFilters,
  });

  factory EventListPageViewModel.create(Store<AppState> store) {
    final eventListState = store.state.eventListState;
    return EventListPageViewModel(
      displayState: _displayState(eventListState),
      eventIds: _eventIds(eventListState),
      availableAntennes: _availableAntennes(eventListState),
      selectedAntennes: _selectedAntennes(eventListState),
      onRetry: () => {store.dispatch(EventListRequestAction(DateTime.now(), forceRefresh: true))},
      onUpdateFilters: (antennes) => store.dispatch(EventListUpdateFiltersAction(antennes)),
      onClearFilters: () => store.dispatch(EventListClearFiltersAction()),
    );
  }

  bool get hasActiveFilters => selectedAntennes.isNotEmpty;

  int get activeFiltersCount => selectedAntennes.length;

  @override
  List<Object?> get props => [displayState, eventIds, availableAntennes, selectedAntennes];
}

DisplayState _displayState(EventListState eventListState) {
  if (eventListState is EventListFailureState) {
    return DisplayState.FAILURE;
  } else if (eventListState is EventListSuccessState) {
    if (eventListState.animationsCollectives.isEmpty && eventListState.sessionsMilos.isEmpty) {
      return DisplayState.EMPTY;
    } else {
      return DisplayState.CONTENT;
    }
  }
  return DisplayState.LOADING;
}

List<EventId> _eventIds(EventListState eventListState) {
  if (eventListState is! EventListSuccessState) {
    return [];
  }

  final allEvents = [
    ...eventListState.animationsCollectives.map((e) => (AnimationCollectiveId(e.id), e.date)),
    ...eventListState.sessionsMilos.map((e) => (SessionMiloId(e.id), e.dateDeDebut)),
  ].sortedBy((e) => e.$2).map((e) => e.$1);

  // Apply antenne filter if any filters are selected
  if (eventListState.selectedAntennes.isEmpty) {
    return allEvents.toList();
  }

  final filteredEvents = <EventId>[];
  for (final eventId in allEvents) {
    if (eventId is AnimationCollectiveId) {
      final event = eventListState.animationsCollectives.firstWhere((e) => e.id == eventId.id);
      if (event.antenne != null && eventListState.selectedAntennes.contains(event.antenne)) {
        filteredEvents.add(eventId);
      }
    } else if (eventId is SessionMiloId) {
      final event = eventListState.sessionsMilos.firstWhere((e) => e.id == eventId.id);
      if (event.antenne != null && eventListState.selectedAntennes.contains(event.antenne)) {
        filteredEvents.add(eventId);
      }
    }
  }

  return filteredEvents;
}

List<String> _availableAntennes(EventListState eventListState) {
  if (eventListState is! EventListSuccessState) {
    return [];
  }

  final antennes = <String>{};
  
  for (final animation in eventListState.animationsCollectives) {
    if (animation.antenne != null && animation.antenne!.trim().isNotEmpty) {
      antennes.add(animation.antenne!);
    }
  }
  
  for (final session in eventListState.sessionsMilos) {
    if (session.antenne != null && session.antenne!.trim().isNotEmpty) {
      antennes.add(session.antenne!);
    }
  }

  final sortedAntennes = antennes.toList()..sort();
  return sortedAntennes;
}

List<String> _selectedAntennes(EventListState eventListState) {
  if (eventListState is EventListSuccessState) {
    return eventListState.selectedAntennes;
  }
  return [];
}
