import 'package:pass_emploi_app/auth/auth_access_token_retriever.dart';
import 'package:pass_emploi_app/auth/authenticator.dart';
import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_actions.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/reprise_compte_invite_repository.dart';
import 'package:redux/redux.dart';

class RepriseCompteInviteMiddleware extends MiddlewareClass<AppState> {
  final RepriseCompteInviteRepository _repository;
  final Authenticator _authenticator;
  final AuthAccessTokenRetriever _accessTokenRetriever;

  RepriseCompteInviteMiddleware(this._repository, this._authenticator, this._accessTokenRetriever);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    if (action is RepriseCompteInviteRequestAction && store.state.isInviteLoginMode()) {
      await _reprendre(store, action.mode);
    }
  }

  Future<void> _reprendre(Store<AppState> store, LoginMode mode) async {
    store.dispatch(RepriseCompteInviteLoadingAction());

    // L'access token invité prouve la reprise une fois le vrai compte connecté. Il est rafraîchi juste avant
    // la connexion, qui peut durer : l'API vérifie son expiration.
    final String jetonInvite;
    try {
      jetonInvite = await _accessTokenRetriever.refreshedAccessToken();
    } on Exception catch (e) {
      store.dispatch(RepriseCompteInviteFailureAction(e.toString()));
      return;
    }

    // Les tokens invité ne sont remplacés qu'en cas de succès : annulation et échec laissent la session invité intacte.
    final response = await _authenticator.login(mode.toAuthenticationMode());
    switch (response) {
      case SuccessAuthenticatorResponse():
        await _rattacherInvite(store, jetonInvite);
      case CancelledAuthenticatorResponse():
        store.dispatch(RepriseCompteInviteResetAction());
      case WrongDeviceClockAuthenticatorResponse():
        store.dispatch(RepriseCompteInviteWrongDeviceClockAction());
      case FailureAuthenticatorResponse(:final message):
        store.dispatch(RepriseCompteInviteFailureAction(message));
    }
  }

  Future<void> _rattacherInvite(Store<AppState> store, String jetonInvite) async {
    final idToken = await _authenticator.idToken();
    // Un échec du rattachement ne bloque pas le jeune, désormais connecté : l'invité non rattaché
    // finira purgé comme inactif.
    if (idToken != null) await _repository.reprendre(userId: idToken.userId, jetonInvite: jetonInvite);

    // Comme après une déconnexion, l'état de l'invité est effacé puis l'app redémarre sur le compte connecté.
    store.dispatch(RepriseCompteInviteSuccessAction());
    store.dispatch(BootstrapAction());
  }
}
