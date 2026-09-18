import 'package:pass_emploi_app/models/communications.dart';

class CommunicationsRequestAction {}

class CommunicationsLoadingAction {}

class CommunicationsSuccessAction {
  final Communications result;

  CommunicationsSuccessAction(this.result);
}

class CommunicationsFailureAction {}
