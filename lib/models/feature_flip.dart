import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/accueil_zenith_message.dart';
import 'package:pass_emploi_app/models/login_page_remote_message.dart';

class FeatureFlip extends Equatable {
  final bool withCampagneRecrutement;
  final String? withMonSuiviDemarchesKoMessage;
  final LoginPageRemoteMessage? loginPageMessage;
  final AccueilZenithMessage? accueilZenithMessage;

  FeatureFlip({
    required this.withCampagneRecrutement,
    required this.withMonSuiviDemarchesKoMessage,
    required this.loginPageMessage,
    required this.accueilZenithMessage,
  });

  factory FeatureFlip.initial() {
    return FeatureFlip(
      withCampagneRecrutement: false,
      withMonSuiviDemarchesKoMessage: null,
      loginPageMessage: null,
      accueilZenithMessage: null,
    );
  }

  FeatureFlip copyWith({
    bool? withCampagneRecrutement,
    String? withMonSuiviDemarchesKoMessage,
    LoginPageRemoteMessage? loginPageMessage,
    AccueilZenithMessage? accueilZenithMessage,
  }) {
    return FeatureFlip(
      withCampagneRecrutement: withCampagneRecrutement ?? this.withCampagneRecrutement,
      withMonSuiviDemarchesKoMessage: withMonSuiviDemarchesKoMessage ?? this.withMonSuiviDemarchesKoMessage,
      loginPageMessage: loginPageMessage ?? this.loginPageMessage,
      accueilZenithMessage: accueilZenithMessage ?? this.accueilZenithMessage,
    );
  }

  @override
  List<Object?> get props => [
    withCampagneRecrutement,
    withMonSuiviDemarchesKoMessage,
    loginPageMessage,
    accueilZenithMessage,
  ];
}
