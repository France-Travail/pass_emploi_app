import 'package:pass_emploi_app/models/actualite_mission_locale.dart';

class ActualiteMissionLocaleRequestAction {}

class ActualiteMissionLocaleLoadingAction {}

class ActualiteMissionLocaleSuccessAction {
  final List<ActualiteMissionLocale> result;

  ActualiteMissionLocaleSuccessAction(this.result);
}

class ActualiteMissionLocaleFailureAction {}
