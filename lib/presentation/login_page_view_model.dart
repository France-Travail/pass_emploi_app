import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/configuration/configuration.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

class LoginPageViewModel extends Equatable {
  final bool withOrganismChoice;
  final bool withInviteButton;
  final bool withLoading;
  final bool withWrongDeviceClockMessage;
  final String accessibilityLevelLabel;
  final String? technicalErrorMessage;
  final void Function() onFranceTravailLogin;
  final void Function()? onMissionLocaleLogin;
  final void Function()? onInviteLogin;

  LoginPageViewModel({
    required this.withOrganismChoice,
    required this.withInviteButton,
    required this.withLoading,
    required this.withWrongDeviceClockMessage,
    required this.accessibilityLevelLabel,
    required this.technicalErrorMessage,
    required this.onFranceTravailLogin,
    required this.onMissionLocaleLogin,
    required this.onInviteLogin,
  });

  factory LoginPageViewModel.create(Store<AppState> store) {
    final loginState = store.state.loginState;
    final brand = store.state.configurationState.getBrand();
    final flavor = store.state.configurationState.getFlavor();
    final isCej = brand.isCej;
    return LoginPageViewModel(
      withOrganismChoice: isCej,
      withInviteButton: flavor == Flavor.STAGING,
      withLoading: loginState is LoginLoadingState,
      withWrongDeviceClockMessage: loginState is LoginWrongDeviceClockState,
      accessibilityLevelLabel: isCej ? Strings.accessibilityPartiallyConform : Strings.accessibilityNotConform,
      technicalErrorMessage: loginState is LoginGenericFailureState ? loginState.message : null,
      onFranceTravailLogin: () => store.dispatch(RequestLoginAction(LoginMode.POLE_EMPLOI)),
      onMissionLocaleLogin: isCej ? () => store.dispatch(RequestLoginAction(LoginMode.MILO)) : null,
      onInviteLogin: flavor == Flavor.STAGING ? () => store.dispatch(RequestLoginAction(LoginMode.INVITE)) : null,
    );
  }

  @override
  List<Object?> get props => [
        withOrganismChoice,
        withInviteButton,
        withLoading,
        withWrongDeviceClockMessage,
        accessibilityLevelLabel,
        technicalErrorMessage,
      ];
}
