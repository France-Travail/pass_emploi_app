import 'package:pass_emploi_app/features/fonctionnalites/fonctionnalites_actions.dart';
import 'package:pass_emploi_app/features/fonctionnalites/fonctionnalites_state.dart';

FonctionnalitesState fonctionnalitesReducer(FonctionnalitesState current, dynamic action) {
  if (action is FonctionnalitesLoadingAction) return FonctionnalitesLoadingState();
  if (action is FonctionnalitesSuccessAction) return FonctionnalitesSuccessState(action.actives);
  if (action is FonctionnalitesFailureAction) return FonctionnalitesFailureState();
  return current;
}
