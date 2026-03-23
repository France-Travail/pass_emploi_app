import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/events/list/event_list_actions.dart';
import 'package:pass_emploi_app/features/events/list/event_list_state.dart';
import 'package:pass_emploi_app/presentation/checkbox_value_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

class EventFiltersViewModel extends Equatable {
  final DisplayState displayState;
  final List<CheckboxValueViewModel<String>> antenneFiltres;
  final Function(List<String>) updateFiltres;
  final Function() clearFiltres;

  EventFiltersViewModel({
    required this.displayState,
    required this.antenneFiltres,
    required this.updateFiltres,
    required this.clearFiltres,
  });

  factory EventFiltersViewModel.create(Store<AppState> store) {
    return EventFiltersViewModel(
      displayState: DisplayState.CONTENT,
      antenneFiltres: _createAntenneFiltres(store),
      updateFiltres: (antennes) => store.dispatch(EventListUpdateFiltersAction(antennes)),
      clearFiltres: () => store.dispatch(EventListClearFiltersAction()),
    );
  }

  @override
  List<Object?> get props => [displayState, antenneFiltres];
}

List<CheckboxValueViewModel<String>> _createAntenneFiltres(Store<AppState> store) {
  final eventListState = store.state.eventListState;

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

  return sortedAntennes.map((antenne) {
    return CheckboxValueViewModel<String>(
      value: antenne,
      label: antenne,
      isInitiallyChecked: eventListState.selectedAntennes.contains(antenne),
    );
  }).toList();
}
