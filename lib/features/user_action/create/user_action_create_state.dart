sealed class UserActionCreateState {}

class UserActionCreateNotInitializedState extends UserActionCreateState {}

class UserActionCreateLoadingState extends UserActionCreateState {}

class UserActionCreateSuccessState extends UserActionCreateState {
  final String userActionCreatedId;
  final String actionContent;

  UserActionCreateSuccessState(this.userActionCreatedId, {this.actionContent = ''});
}

class UserActionCreateFailureState extends UserActionCreateState {}
