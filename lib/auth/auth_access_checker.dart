import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/utils/log.dart';
import 'package:redux/redux.dart';

class AuthAccessChecker {
  late Store<AppState> _store;

  void logoutUserIfTokenIsExpired(String? message, int statusCode) {
    // L'invité n'existe pas dans la table jeune : les endpoints jeune lui
    // répondent légitimement `auth_user_not_found`. C'est un droit manquant,
    // pas une session morte -> le déconnecter ferait perdre son compte, qu'il
    // ne peut pas récupérer (aucune identité pour se reconnecter).
    if (_store.state.isInviteLoginMode()) return;

    if (message?.containsExpiredToken() == true) {
      Log.i("Logout user on token expired: $message.");
      _store.dispatch(RequestLogoutAction(LogoutReason.apiResponse401));
    }
  }

  void setStore(Store<AppState> store) => _store = store;
}

extension _StringExtension on String {
  bool containsExpiredToken() {
    return contains("token_pole_emploi_expired") || contains("token_milo_expired") || contains("auth_user_not_found");
  }
}
