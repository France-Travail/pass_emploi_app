import 'package:pass_emploi_app/features/date_consultation_actualite_mission_locale/date_consultation_actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/features/date_consultation_actualite_mission_locale/date_consultation_actualite_mission_locale_state.dart';

DateConsultationActualiteMissionLocaleState dateConsultationActualiteMissionLocaleReducer(
  DateConsultationActualiteMissionLocaleState current,
  dynamic action,
) {
  if (action is DateConsultationActualiteMissionLocaleSuccessAction) {
    return DateConsultationActualiteMissionLocaleState(date: action.result);
  }
  return current;
}
