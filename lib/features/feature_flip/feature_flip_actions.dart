import 'package:pass_emploi_app/models/accueil_zenith_message.dart';
import 'package:pass_emploi_app/models/feature_flip.dart';
import 'package:pass_emploi_app/models/login_page_remote_message.dart';

class FeatureFlipUseCvmAction {
  final bool useCvm;

  FeatureFlipUseCvmAction(this.useCvm);
}

class FeatureFlipCampagneRecrutementAction {
  final bool withCampagneRecrutement;

  FeatureFlipCampagneRecrutementAction(this.withCampagneRecrutement);
}

class FeatureFlipMonSuiviDemarchesKoMessageAction {
  final String? withMonSuiviDemarchesKoMessage;

  FeatureFlipMonSuiviDemarchesKoMessageAction(this.withMonSuiviDemarchesKoMessage);
}

class FeatureFlipAbTestingIaFtAction {
  final AbTestingIaFt abTestingIaFt;

  FeatureFlipAbTestingIaFtAction(this.abTestingIaFt);
}

class FeatureFlipLoginPageMessageAction {
  final LoginPageRemoteMessage loginPageMessage;

  FeatureFlipLoginPageMessageAction(this.loginPageMessage);
}

class FeatureFlipAccueilZenithMessageAction {
  final AccueilZenithMessage accueilZenithMessage;

  FeatureFlipAccueilZenithMessageAction(this.accueilZenithMessage);
}
