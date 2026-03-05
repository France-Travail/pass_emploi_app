import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/auto_desinscription/auto_desinscription_actions.dart';
import 'package:pass_emploi_app/features/auto_desinscription/auto_desinscription_state.dart';
import 'package:pass_emploi_app/features/rendezvous/details/rendezvous_details_state.dart';
import 'package:pass_emploi_app/features/session_milo_details/session_milo_details_state.dart';
import 'package:pass_emploi_app/models/rendezvous.dart';
import 'package:pass_emploi_app/presentation/rendezvous/rendezvous_state_source.dart';
import 'package:pass_emploi_app/presentation/rendezvous/rendezvous_store_extension.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';
import 'package:redux/redux.dart';

enum AutoDesinscriptionDisplayState {
  initial,
  loading,
  failure,
  success,
}

class AutoDesinscriptionViewModel extends Equatable {
  final AutoDesinscriptionDisplayState displayState;
  final void Function(String motif) desinscribe;
  final String date;
  final String hourAndDuration;
  final String? title;

  factory AutoDesinscriptionViewModel.create(
    Store<AppState> store, {
    required RendezvousStateSource source,
    required String rdvId,
  }) {
    final rdv = _getRendezvous(store, source, rdvId);
    if (rdv == null) return AutoDesinscriptionViewModel.empty();

    return AutoDesinscriptionViewModel(
      displayState: _displayState(store),
      desinscribe: (motif) => store.dispatch(AutoDesinscriptionRequestAction(eventId: rdvId, motif: motif)),
      title: rdv.title,
      date: rdv.date.toDayWithFullMonthContextualized(),
      hourAndDuration: _hours(rdv),
    );
  }

  factory AutoDesinscriptionViewModel.empty() {
    return AutoDesinscriptionViewModel(
      displayState: AutoDesinscriptionDisplayState.loading,
      desinscribe: (_) {},
      date: "",
      hourAndDuration: "",
      title: null,
    );
  }

  AutoDesinscriptionViewModel({
    required this.displayState,
    required this.desinscribe,
    required this.date,
    required this.hourAndDuration,
    required this.title,
  });

  @override
  List<Object?> get props => [
    displayState,
    date,
    hourAndDuration,
    title,
  ];
}

AutoDesinscriptionDisplayState _displayState(Store<AppState> store) {
  return switch (store.state.autoDesinscriptionState) {
    AutoDesinscriptionNotInitializedState() => AutoDesinscriptionDisplayState.initial,
    AutoDesinscriptionLoadingState() => AutoDesinscriptionDisplayState.loading,
    AutoDesinscriptionFailureState() => AutoDesinscriptionDisplayState.failure,
    AutoDesinscriptionSuccessState() => AutoDesinscriptionDisplayState.success,
  };
}

Rendezvous? _getRendezvous(Store<AppState> store, RendezvousStateSource source, String rdvId) {
  return _shouldGetRendezvous(source, store) ? store.getRendezvous(source, rdvId) : null;
}

bool _shouldGetRendezvous(RendezvousStateSource source, Store<AppState> store) {
  return switch (source) {
    RendezvousStateSource.noSource => store.state.rendezvousDetailsState is RendezvousDetailsSuccessState,
    RendezvousStateSource.sessionMiloDetails => store.state.sessionMiloDetailsState is SessionMiloDetailsSuccessState,
    _ => true,
  };
}

String _hours(Rendezvous rdv) {
  final heureDebut = rdv.date.toHourWithHSeparator();
  final heureFin = rdv.duration != null && rdv.duration != 0
      ? rdv.date.add(Duration(minutes: rdv.duration!)).toHourWithHSeparator()
      : null;
  final period = "$heureDebut${heureFin != null ? " - $heureFin" : ""}";
  return period;
}
