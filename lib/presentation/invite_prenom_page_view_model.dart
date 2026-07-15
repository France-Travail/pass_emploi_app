import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/invite_prenom/invite_prenom_actions.dart';
import 'package:pass_emploi_app/features/invite_prenom/invite_prenom_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

enum InvitePrenomDisplayState { loading, content, error, updated }

class InvitePrenomPageViewModel extends Equatable {
  final InvitePrenomDisplayState displayState;
  final String prenom;
  final bool withUpdateError;
  final void Function() onRetry;
  final void Function(String prenom) onUpdate;

  InvitePrenomPageViewModel({
    required this.displayState,
    required this.prenom,
    required this.withUpdateError,
    required this.onRetry,
    required this.onUpdate,
  });

  factory InvitePrenomPageViewModel.create(Store<AppState> store) {
    final state = store.state.invitePrenomState;
    return InvitePrenomPageViewModel(
      displayState: _displayState(state),
      prenom: _prenom(state),
      withUpdateError: state is InvitePrenomUpdateFailureState,
      onRetry: () => store.dispatch(InvitePrenomRequestAction()),
      onUpdate: (prenom) => store.dispatch(InvitePrenomUpdateRequestAction(prenom)),
    );
  }

  @override
  List<Object?> get props => [displayState, prenom, withUpdateError];
}

InvitePrenomDisplayState _displayState(InvitePrenomState state) {
  return switch (state) {
    InvitePrenomNotInitializedState() => InvitePrenomDisplayState.loading,
    InvitePrenomLoadingState() => InvitePrenomDisplayState.loading,
    InvitePrenomFailureState() => InvitePrenomDisplayState.error,
    InvitePrenomSuccessState() => InvitePrenomDisplayState.content,
    InvitePrenomUpdateFailureState() => InvitePrenomDisplayState.content,
    InvitePrenomUpdatedState() => InvitePrenomDisplayState.updated,
  };
}

String _prenom(InvitePrenomState state) {
  return switch (state) {
    InvitePrenomSuccessState() => state.prenom,
    InvitePrenomUpdatedState() => state.prenom,
    InvitePrenomUpdateFailureState() => state.prenom,
    _ => '',
  };
}
