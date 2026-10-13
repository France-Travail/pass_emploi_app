import 'package:pass_emploi_app/auth/authenticator.dart';
import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_actions.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_repository.dart';
import 'package:pass_emploi_app/repositories/reprise_compte_invite_repository.dart';
import 'package:redux/redux.dart';

class RepriseCompteInviteMiddleware extends MiddlewareClass<AppState> {
  final RepriseCompteInviteRepository _repository;
  final Authenticator _authenticator;
  final ActionPlanRepository _actionPlanRepository;

  RepriseCompteInviteMiddleware(
    this._repository,
    this._authenticator,
    this._actionPlanRepository,
  );

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    if (action is RepriseCompteInviteRequestAction && store.state.isInviteLoginMode()) {
      await _reprendre(store, action.mode);
    }
  }

  Future<void> _reprendre(Store<AppState> store, LoginMode mode) async {
    store.dispatch(RepriseCompteInviteLoadingAction());

    // Le login remplace les tokens invité : le refresh token invité, qui n'expire pas, est lu avant
    // pour produire la preuve de reprise après le login, quelle que soit sa durée.
    final refreshTokenInvite = await _authenticator.refreshToken();

    // Le plan local est lu avant le login : le stockage n'est pas effacé par le login, mais cette
    // lecture avant garantit qu'on capte le plan même en cas d'échec inattendu du login.
    final planLocal = await _actionPlanRepository.getStoredPlan();
    final planApiReprise = planLocal?.toApiReprise();

    // Les tokens invité ne sont remplacés qu'en cas de succès : annulation et échec laissent la session invité intacte.
    final response = await _authenticator.login(mode.toAuthenticationMode());
    switch (response) {
      case SuccessAuthenticatorResponse():
        await _rattacherInvite(store, refreshTokenInvite, planApiReprise);
      case CancelledAuthenticatorResponse():
        store.dispatch(RepriseCompteInviteResetAction());
      case WrongDeviceClockAuthenticatorResponse():
        store.dispatch(RepriseCompteInviteWrongDeviceClockAction());
      case FailureAuthenticatorResponse(:final message):
        store.dispatch(RepriseCompteInviteFailureAction(message));
    }
  }

  Future<void> _rattacherInvite(
    Store<AppState> store,
    String? refreshTokenInvite,
    Map<String, dynamic>? planApiReprise,
  ) async {
    final idToken = await _authenticator.idToken();
    final jetonInvite = await _jetonInvite(refreshTokenInvite);
    // Un échec du rattachement ne bloque pas le jeune, désormais connecté : l'invité non rattaché
    // finira purgé comme inactif.
    if (idToken != null && jetonInvite != null) {
      await _repository.reprendre(
        userId: idToken.userId,
        jetonInvite: jetonInvite,
        plan: planApiReprise,
      );
    }

    // Comme après une déconnexion, l'état de l'invité est effacé puis l'app redémarre sur le compte connecté.
    store.dispatch(RepriseCompteInviteSuccessAction());
    store.dispatch(BootstrapAction());
  }

  Future<String?> _jetonInvite(String? refreshTokenInvite) async {
    if (refreshTokenInvite == null) return null;
    return _authenticator.accessTokenFromRefreshToken(refreshTokenInvite);
  }
}
