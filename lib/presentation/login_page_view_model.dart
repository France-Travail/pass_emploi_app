import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

class LoginPageViewModel extends Equatable {
  final bool withOrganismChoice;
  final bool withThemedAppLogo;
  final String title;
  final String? subtitle;
  final String description;
  final bool withLoading;
  final bool withWrongDeviceClockMessage;
  final String accessibilityLevelLabel;
  final String? technicalErrorMessage;
  final void Function() onFranceTravailLogin;
  final void Function()? onMissionLocaleLogin;
  final void Function() onInviteLogin;

  /// Accès caché au mode invité (5 taps sur le bloc marque), pour les tests utilisateurs en production.
  /// Le mot de passe vient de Firebase Remote Config (clé `invite_access_password`) ;
  /// sans valeur distante, l'accès est désactivé.
  final bool Function(String password) isInviteAccessPasswordValid;

  LoginPageViewModel({
    required this.withOrganismChoice,
    required this.withThemedAppLogo,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.withLoading,
    required this.withWrongDeviceClockMessage,
    required this.accessibilityLevelLabel,
    required this.technicalErrorMessage,
    required this.onFranceTravailLogin,
    required this.onMissionLocaleLogin,
    required this.onInviteLogin,
    required this.isInviteAccessPasswordValid,
  });

  factory LoginPageViewModel.create(Store<AppState> store) {
    final loginState = store.state.loginState;
    final brand = store.state.configurationState.getBrand();
    final isCej = brand.isCej;
    final inviteAccessPassword = store.state.featureFlipState.featureFlip.inviteAccessPassword;
    return LoginPageViewModel(
      withOrganismChoice: isCej,
      withThemedAppLogo: !isCej,
      title: isCej ? Strings.loginChooseAccountTitle : Strings.loginPassEmploiTitle,
      subtitle: isCej ? null : Strings.loginPassEmploiSubtitle,
      description: isCej ? Strings.loginChooseAccountDescription : Strings.loginPassEmploiDescription,
      withLoading: loginState is LoginLoadingState,
      withWrongDeviceClockMessage: loginState is LoginWrongDeviceClockState,
      accessibilityLevelLabel: isCej ? Strings.accessibilityPartiallyConform : Strings.accessibilityNotConform,
      technicalErrorMessage: loginState is LoginGenericFailureState ? loginState.message : null,
      onFranceTravailLogin: () => store.dispatch(RequestLoginAction(LoginMode.POLE_EMPLOI)),
      onMissionLocaleLogin: isCej ? () => store.dispatch(RequestLoginAction(LoginMode.MILO)) : null,
      onInviteLogin: () => store.dispatch(RequestLoginAction(LoginMode.INVITE)),
      isInviteAccessPasswordValid: (password) => inviteAccessPassword != null && password == inviteAccessPassword,
    );
  }

  @override
  List<Object?> get props => [
        withOrganismChoice,
        withThemedAppLogo,
        title,
        subtitle,
        description,
        withLoading,
        withWrongDeviceClockMessage,
        accessibilityLevelLabel,
        technicalErrorMessage,
      ];
}
