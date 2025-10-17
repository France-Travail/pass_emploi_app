import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/accueil_zenith_message.dart';
import 'package:pass_emploi_app/models/login_page_remote_message.dart';

class FeatureFlip extends Equatable {
  final bool useCvm;
  final bool withCampagneRecrutement;
  final String? withMonSuiviDemarchesKoMessage;
  final AbTestingIaFt abTestingIaFt;
  final LoginPageRemoteMessage? loginPageMessage;
  final AccueilZenithMessage? accueilZenithMessage;

  FeatureFlip({
    required this.useCvm,
    required this.withCampagneRecrutement,
    required this.withMonSuiviDemarchesKoMessage,
    required this.abTestingIaFt,
    required this.loginPageMessage,
    required this.accueilZenithMessage,
  });

  factory FeatureFlip.initial() {
    return FeatureFlip(
      useCvm: false,
      withCampagneRecrutement: false,
      withMonSuiviDemarchesKoMessage: null,
      abTestingIaFt: AbTestingIaFt.defaultVersion,
      loginPageMessage: null,
      accueilZenithMessage: null,
    );
  }

  FeatureFlip copyWith({
    bool? useCvm,
    bool? withCampagneRecrutement,
    String? withMonSuiviDemarchesKoMessage,
    AbTestingIaFt? abTestingIaFt,
    LoginPageRemoteMessage? loginPageMessage,
    AccueilZenithMessage? accueilZenithMessage,
  }) {
    return FeatureFlip(
      useCvm: useCvm ?? this.useCvm,
      withCampagneRecrutement: withCampagneRecrutement ?? this.withCampagneRecrutement,
      withMonSuiviDemarchesKoMessage: withMonSuiviDemarchesKoMessage ?? this.withMonSuiviDemarchesKoMessage,
      abTestingIaFt: abTestingIaFt ?? this.abTestingIaFt,
      loginPageMessage: loginPageMessage ?? this.loginPageMessage,
      accueilZenithMessage: accueilZenithMessage ?? this.accueilZenithMessage,
    );
  }

  @override
  List<Object?> get props => [
        useCvm,
        withCampagneRecrutement,
        withMonSuiviDemarchesKoMessage,
        abTestingIaFt,
        loginPageMessage,
        accueilZenithMessage,
      ];
}

enum AbTestingIaFt {
  versionA,
  versionB,
  defaultVersion;

  factory AbTestingIaFt.fromJson(String json) => switch (json) {
        "A" => AbTestingIaFt.versionA,
        "B" => AbTestingIaFt.versionB,
        _ => AbTestingIaFt.defaultVersion,
      };
}
