import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_actions.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_state.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

class LoginPageViewModel extends Equatable {
  final bool withBackButton;
  final bool withInviteButton;
  final bool withOrganismChoice;
  final bool withThemedAppLogo;
  final String title;
  final String? subtitle;
  final String description;
  final bool withLoading;
  final bool withWrongDeviceClockMessage;
  final String accessibilityLevelLabel;
  final String? technicalErrorMessage;

  /// Page d'authentification ouverte par les boutons d'organisme : leur donne le rôle lien (A11y 5.1).
  final String? authenticationUrl;
  final void Function() onFranceTravailLogin;
  final void Function()? onMissionLocaleLogin;
  final void Function()? onInviteLogin;

  LoginPageViewModel({
    required this.withBackButton,
    required this.withInviteButton,
    required this.withOrganismChoice,
    required this.withThemedAppLogo,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.withLoading,
    required this.withWrongDeviceClockMessage,
    required this.accessibilityLevelLabel,
    required this.technicalErrorMessage,
    this.authenticationUrl,
    required this.onFranceTravailLogin,
    required this.onMissionLocaleLogin,
    required this.onInviteLogin,
  });

  /// En reprise de compte invité, l'invité déjà connecté choisit son organisme pour rattacher
  /// son compte invité au compte qu'il connecte.
  factory LoginPageViewModel.create(Store<AppState> store, {bool repriseCompteInvite = false}) {
    final loginState = store.state.loginState;
    final brand = store.state.configurationState.getBrand();
    final isCej = brand.isCej;
    final withInviteButton = isCej && !repriseCompteInvite;
    void login(LoginMode mode) => store.dispatch(
          repriseCompteInvite ? RepriseCompteInviteRequestAction(mode) : RequestLoginAction(mode),
        );
    return LoginPageViewModel(
      withBackButton: repriseCompteInvite,
      withInviteButton: withInviteButton,
      withOrganismChoice: isCej,
      withThemedAppLogo: !isCej,
      title: isCej ? Strings.loginChooseAccountTitle : Strings.loginPassEmploiTitle,
      subtitle: isCej ? null : Strings.loginPassEmploiSubtitle,
      description: isCej ? Strings.loginChooseAccountDescription : Strings.loginPassEmploiDescription,
      withLoading: repriseCompteInvite
          ? store.state.repriseCompteInviteState is RepriseCompteInviteLoadingState
          : loginState is LoginLoadingState,
      withWrongDeviceClockMessage: repriseCompteInvite
          ? store.state.repriseCompteInviteState is RepriseCompteInviteWrongDeviceClockState
          : loginState is LoginWrongDeviceClockState,
      accessibilityLevelLabel: isCej ? Strings.accessibilityPartiallyConform : Strings.accessibilityNotConform,
      technicalErrorMessage: _technicalErrorMessage(store.state, repriseCompteInvite: repriseCompteInvite),
      authenticationUrl: store.state.configurationState.configuration?.authIssuer,
      onFranceTravailLogin: () => login(LoginMode.POLE_EMPLOI),
      onMissionLocaleLogin: isCej ? () => login(LoginMode.MILO) : null,
      onInviteLogin: withInviteButton ? () => store.dispatch(RequestLoginAction(LoginMode.INVITE)) : null,
    );
  }

  static String? _technicalErrorMessage(AppState state, {required bool repriseCompteInvite}) {
    if (repriseCompteInvite) {
      final repriseState = state.repriseCompteInviteState;
      return repriseState is RepriseCompteInviteFailureState ? repriseState.message : null;
    }
    final loginState = state.loginState;
    return loginState is LoginGenericFailureState ? loginState.message : null;
  }

  @override
  List<Object?> get props => [
        withBackButton,
        withInviteButton,
        withOrganismChoice,
        withThemedAppLogo,
        title,
        subtitle,
        description,
        withLoading,
        withWrongDeviceClockMessage,
        accessibilityLevelLabel,
        technicalErrorMessage,
        authenticationUrl,
      ];
}
