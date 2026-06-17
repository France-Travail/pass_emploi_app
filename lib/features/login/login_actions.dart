import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/user.dart';

enum LogoutReason {
  userLogout,
  apiResponse401,
  expiredRefreshToken,
  accountSuppression,
  cguRefused,
  tooMany401,
  tooManyRefreshGenericErrors,
}

extension LoginModeModeExtension on LoginMode {
  bool isDemo() => this == LoginMode.DEMO_PE || this == LoginMode.DEMO_MILO;
}

class TokenRefreshGenericErrorAction {
  final int consecutiveFailures;

  TokenRefreshGenericErrorAction(this.consecutiveFailures);

  @override
  String toString() =>
      'TokenRefreshFailedAction(consecutive: $consecutiveFailures)';
}

class LoginRequestAction {}

class LoginLoadingAction {}

class TryConnectChatAgainAction {}

class LoginSuccessAction {
  final User user;

  LoginSuccessAction(this.user);
}

class LoginFailureAction {
  final String message;

  LoginFailureAction(this.message);
}

class LoginWrongDeviceClockAction {}

class NotLoggedInAction {}

class RequestLoginAction {
  final LoginMode mode;

  RequestLoginAction(this.mode);
}

class RequestLogoutAction {
  final LogoutReason reason;

  RequestLogoutAction(this.reason);
}
