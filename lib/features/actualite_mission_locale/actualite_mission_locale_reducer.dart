import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_state.dart';

ActualiteMissionLocaleState actualiteMissionLocaleReducer(ActualiteMissionLocaleState current, dynamic action) {
  if (action is ActualiteMissionLocaleLoadingAction) return ActualiteMissionLocaleLoadingState();
  if (action is ActualiteMissionLocaleFailureAction) return ActualiteMissionLocaleFailureState();
  if (action is ActualiteMissionLocaleSuccessAction) return ActualiteMissionLocaleSuccessState(action.result);
  return current;
}
