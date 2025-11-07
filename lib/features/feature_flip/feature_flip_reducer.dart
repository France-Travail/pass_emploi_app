import 'package:pass_emploi_app/features/feature_flip/feature_flip_actions.dart';
import 'package:pass_emploi_app/features/feature_flip/feature_flip_state.dart';

FeatureFlipState featureFlipReducer(FeatureFlipState current, dynamic action) {
  if (action is FeatureFlipCampagneRecrutementAction) {
    return FeatureFlipState(current.featureFlip.copyWith(withCampagneRecrutement: action.withCampagneRecrutement));
  }
  if (action is FeatureFlipMonSuiviDemarchesKoMessageAction) {
    return FeatureFlipState(
      current.featureFlip.copyWith(withMonSuiviDemarchesKoMessage: action.withMonSuiviDemarchesKoMessage),
    );
  }
  if (action is FeatureFlipLoginPageMessageAction) {
    return FeatureFlipState(current.featureFlip.copyWith(loginPageMessage: action.loginPageMessage));
  }
  if (action is FeatureFlipAccueilZenithMessageAction) {
    return FeatureFlipState(current.featureFlip.copyWith(accueilZenithMessage: action.accueilZenithMessage));
  }
  return current;
}
