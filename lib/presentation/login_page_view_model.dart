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
  final bool withHiddenInviteAccess;
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
    required this.withBackButton,
    required this.withHiddenInviteAccess,
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

  /// En reprise de compte invité, l'invité déjà connecté choisit son organisme pour rattacher
  /// son compte invité au compte qu'il connecte.
  factory LoginPageViewModel.create(Store<AppState> store, {bool repriseCompteInvite = false}) {
    final loginState = store.state.loginState;
    final brand = store.state.configurationState.getBrand();
    final isCej = brand.isCej;
    final inviteAccessPassword = store.state.featureFlipState.featureFlip.inviteAccessPassword;
    void login(LoginMode mode) => store.dispatch(
          repriseCompteInvite ? RepriseCompteInviteRequestAction(mode) : RequestLoginAction(mode),
        );
    return LoginPageViewModel(
      withBackButton: repriseCompteInvite,
      withHiddenInviteAccess: !repriseCompteInvite,
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
      onFranceTravailLogin: () => login(LoginMode.POLE_EMPLOI),
      onMissionLocaleLogin: isCej ? () => login(LoginMode.MILO) : null,
      onInviteLogin: () => store.dispatch(RequestLoginAction(LoginMode.INVITE)),
      isInviteAccessPasswordValid: (password) => inviteAccessPassword != null && password == inviteAccessPassword,
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
        withHiddenInviteAccess,
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
