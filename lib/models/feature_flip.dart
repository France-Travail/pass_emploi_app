import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/login_page_remote_message.dart';

class FeatureFlip extends Equatable {
  final bool useCvm;
  final bool withCampagneRecrutement;
  final String? withMonSuiviDemarchesKoMessage;
  final AbTestingIaFt abTestingIaFt;
  final LoginPageRemoteMessage? loginPageMessage;

  FeatureFlip({
    required this.useCvm,
    required this.withCampagneRecrutement,
    required this.withMonSuiviDemarchesKoMessage,
    required this.abTestingIaFt,
    required this.loginPageMessage,
  });

  factory FeatureFlip.initial() {
    return FeatureFlip(
      useCvm: false,
      withCampagneRecrutement: false,
      withMonSuiviDemarchesKoMessage: null,
      abTestingIaFt: AbTestingIaFt.versionA,
      loginPageMessage: null,
    );
  }

  FeatureFlip copyWith({
    bool? useCvm,
    bool? withCampagneRecrutement,
    String? withMonSuiviDemarchesKoMessage,
    AbTestingIaFt? abTestingIaFt,
    LoginPageRemoteMessage? loginPageMessage,
  }) {
    return FeatureFlip(
      useCvm: useCvm ?? this.useCvm,
      withCampagneRecrutement: withCampagneRecrutement ?? this.withCampagneRecrutement,
      withMonSuiviDemarchesKoMessage: withMonSuiviDemarchesKoMessage ?? this.withMonSuiviDemarchesKoMessage,
      abTestingIaFt: abTestingIaFt ?? this.abTestingIaFt,
      loginPageMessage: loginPageMessage ?? this.loginPageMessage,
    );
  }

  @override
  List<Object?> get props => [
        useCvm,
        withCampagneRecrutement,
        withMonSuiviDemarchesKoMessage,
        abTestingIaFt,
        loginPageMessage,
      ];
}

enum AbTestingIaFt {
  versionA,
  versionB;

  factory AbTestingIaFt.fromJson(String json) => switch (json) {
        "A" => AbTestingIaFt.versionA,
        "B" => AbTestingIaFt.versionB,
        _ => AbTestingIaFt.versionA,
      };
}
