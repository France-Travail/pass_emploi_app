import 'package:pass_emploi_app/models/feature_flip.dart';

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
