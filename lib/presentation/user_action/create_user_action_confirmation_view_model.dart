import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/user_action/create/user_action_create_state.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

class CreateActionSuccessViewModel extends Equatable {
  final String actionId;
  final DisplayState displayState;
  final String firstName;
  final String actionContent;

  CreateActionSuccessViewModel({
    required this.actionId,
    required this.displayState,
    required this.firstName,
    required this.actionContent,
  });

  factory CreateActionSuccessViewModel.create(Store<AppState> store) {
    final createState = store.state.userActionCreateState;
    final successState = createState is UserActionCreateSuccessState ? createState : null;
    return CreateActionSuccessViewModel(
      actionId: successState?.userActionCreatedId ?? "",
      displayState: _displayState(store),
      firstName: store.state.user()?.firstName ?? "",
      actionContent: successState?.actionContent ?? "",
    );
  }

  @override
  List<Object?> get props => [actionId, displayState, firstName, actionContent];
}

DisplayState _displayState(Store<AppState> store) {
  final createState = store.state.userActionCreateState;
  return switch (createState) {
    UserActionCreateNotInitializedState() => DisplayState.LOADING,
    UserActionCreateLoadingState() => DisplayState.LOADING,
    UserActionCreateSuccessState() => DisplayState.CONTENT,
    UserActionCreateFailureState() => DisplayState.FAILURE,
  };
}
