import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/accueil_zenith_message.dart';
import 'package:pass_emploi_app/models/login_page_remote_message.dart';

class FeatureFlip extends Equatable {
  final bool withCampagneRecrutement;
  final String? withMonSuiviDemarchesKoMessage;
  final LoginPageRemoteMessage? loginPageMessage;
  final AccueilZenithMessage? accueilZenithMessage;
  final bool isDiagorienteEnabled;
  FeatureFlip({
    required this.withCampagneRecrutement,
    required this.withMonSuiviDemarchesKoMessage,
    required this.loginPageMessage,
    required this.accueilZenithMessage,
    required this.isDiagorienteEnabled,
  });

  factory FeatureFlip.initial() {
    return FeatureFlip(
      withCampagneRecrutement: false,
      withMonSuiviDemarchesKoMessage: null,
      loginPageMessage: null,
      accueilZenithMessage: null,
      isDiagorienteEnabled: true,
    );
  }

  FeatureFlip copyWith({
    bool? withCampagneRecrutement,
    String? withMonSuiviDemarchesKoMessage,
    LoginPageRemoteMessage? loginPageMessage,
    AccueilZenithMessage? accueilZenithMessage,
    bool? isDiagorienteEnabled,
  }) {
    return FeatureFlip(
      withCampagneRecrutement: withCampagneRecrutement ?? this.withCampagneRecrutement,
      withMonSuiviDemarchesKoMessage: withMonSuiviDemarchesKoMessage ?? this.withMonSuiviDemarchesKoMessage,
      loginPageMessage: loginPageMessage ?? this.loginPageMessage,
      accueilZenithMessage: accueilZenithMessage ?? this.accueilZenithMessage,
      isDiagorienteEnabled: isDiagorienteEnabled ?? this.isDiagorienteEnabled,
    );
  }

  @override
  List<Object?> get props => [
    withCampagneRecrutement,
    withMonSuiviDemarchesKoMessage,
    loginPageMessage,
    accueilZenithMessage,
    isDiagorienteEnabled,
  ];
}
