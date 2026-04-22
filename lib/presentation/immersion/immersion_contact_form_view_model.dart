import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/contact_immersion/contact_immersion_actions.dart';
import 'package:pass_emploi_app/features/contact_immersion/contact_immersion_state.dart';
import 'package:pass_emploi_app/features/immersion/details/immersion_details_state.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/models/immersion_contact.dart';
import 'package:pass_emploi_app/models/requests/contact_immersion_request.dart';
import 'package:pass_emploi_app/presentation/sending_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

class ImmersionContactFormViewModel extends Equatable {
  final ImmersionContactMode contactMode;
  final SendingState sendingState;
  final String userEmailInitialValue;
  final String userFirstNameInitialValue;
  final String userLastNameInitialValue;
  final Function(ImmersionContactUserInput) onFormSubmitted;
  final Function resetSendingState;

  ImmersionContactFormViewModel._({
    required this.contactMode,
    required this.sendingState,
    required this.userEmailInitialValue,
    required this.userFirstNameInitialValue,
    required this.userLastNameInitialValue,
    required this.onFormSubmitted,
    required this.resetSendingState,
  });

  factory ImmersionContactFormViewModel.create(Store<AppState> store) {
    final state = store.state;
    final user = (state.loginState as LoginSuccessState).user;
    return ImmersionContactFormViewModel._(
      contactMode: _immersionContactMode(store),
      sendingState: _sendingState(store.state.contactImmersionState),
      userEmailInitialValue: user.email ?? "",
      userFirstNameInitialValue: user.firstName,
      userLastNameInitialValue: user.lastName,
      onFormSubmitted: (userInput) => store.dispatch(
        ContactImmersionRequestAction(
          ContactImmersionRequest(
            (state.immersionDetailsState as ImmersionDetailsSuccessState).immersion,
            userInput,
          ),
        ),
      ),
      resetSendingState: () => store.dispatch(ContactImmersionResetAction()),
    );
  }

  @override
  List<Object?> get props => [
    contactMode,
    sendingState,
    userEmailInitialValue,
    userFirstNameInitialValue,
    userLastNameInitialValue,
  ];
}

SendingState _sendingState(ContactImmersionState state) {
  if (state is ContactImmersionLoadingState) return SendingState.loading;
  if (state is ContactImmersionFailureState) return SendingState.failure;
  if (state is ContactImmersionAlreadyDoneState) return SendingState.alreadyDone;
  if (state is ContactImmersionSuccessState) return SendingState.success;
  return SendingState.none;
}

class ImmersionContactUserInput extends Equatable {
  final String email;
  final String firstName;
  final String lastName;
  final String telephone;
  final String datePreferences;
  final String experience;
  final String linkedinOrCvUrl;

  ImmersionContactUserInput({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.telephone,
    required this.datePreferences,
    this.experience = '',
    this.linkedinOrCvUrl = '',
  });

  @override
  List<Object?> get props => [email, firstName, lastName, telephone, datePreferences, experience, linkedinOrCvUrl];
}

ImmersionContactMode _immersionContactMode(Store<AppState> store) {
  final state = store.state.immersionDetailsState;
  if (state is ImmersionDetailsSuccessState) {
    return state.immersion.contactMode;
  }
  return ImmersionContactMode.INCONNU;
}
