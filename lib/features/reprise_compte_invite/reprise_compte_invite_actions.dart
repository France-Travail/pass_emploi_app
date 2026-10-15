import 'package:pass_emploi_app/models/login_mode.dart';

class RepriseCompteInviteRequestAction {
  final LoginMode mode;

  RepriseCompteInviteRequestAction(this.mode);
}

class RepriseCompteInviteLoadingAction {}

class RepriseCompteInviteSuccessAction {}

class RepriseCompteInviteFailureAction {
  final String message;

  RepriseCompteInviteFailureAction(this.message);
}

class RepriseCompteInviteWrongDeviceClockAction {}

class RepriseCompteInviteResetAction {}
