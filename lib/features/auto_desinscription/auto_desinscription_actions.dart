class AutoDesinscriptionRequestAction {
  final String eventId;
  final String motif;

  AutoDesinscriptionRequestAction({required this.eventId, required this.motif});
}

class AutoDesinscriptionLoadingAction {}

class AutoDesinscriptionSuccessAction {
  final bool result;

  AutoDesinscriptionSuccessAction(this.result);
}

class AutoDesinscriptionFailureAction {}

class AutoDesinscriptionResetAction {}
