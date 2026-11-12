import 'package:pass_emploi_app/features/cgu/cgu_actions.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/cgu/cgu_repository.dart';
import 'package:pass_emploi_app/repositories/remote_config_repository.dart';
import 'package:redux/redux.dart';

class CguMiddleware extends MiddlewareClass<AppState> {
  final CguRepository _cguRepository;
  final RemoteConfigRepository _remoteConfigRepository;

  CguMiddleware(this._cguRepository, this._remoteConfigRepository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    if (action is LoginSuccessAction) {
      _handleLoginAction(store, action);
    } else if (action is CguAcceptedAction) {
      final success = await _cguRepository.save(
        store.state.userId()!,
        action.date,
        isInvite: store.state.isInviteLoginMode(),
      );
      if (success) store.dispatch(CguAlreadyAcceptedAction());
    } else if (action is CguRefusedAction) {
      // La suppression du compte invité a besoin du jeton invité : elle doit précéder la déconnexion.
      // La déconnexion purge ensuite l'état local (plan, questionnaire).
      if (store.state.isInviteLoginMode()) await _cguRepository.deleteInvite(store.state.userId()!);
      store.dispatch(RequestLogoutAction(LogoutReason.cguRefused));
    }
  }

  void _handleLoginAction(Store<AppState> store, LoginSuccessAction action) async {
    final signature = await _cguRepository.get(action.user.id, isInvite: action.user.loginMode.isInvite());
    if (signature == null) return;

    final cgu = _remoteConfigRepository.getCgu();
    if (cgu == null) return;

    final dateSignatureCgu = signature.date;
    if (dateSignatureCgu == null) {
      store.dispatch(CguNeverAcceptedAction());
    } else if (dateSignatureCgu.isAfter(cgu.lastUpdate)) {
      store.dispatch(CguAlreadyAcceptedAction());
    } else {
      store.dispatch(CguUpdateRequiredAction(cgu));
    }
  }
}
