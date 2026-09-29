import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/accueil_zenith_message.dart';
import 'package:pass_emploi_app/models/login_page_remote_message.dart';

class FeatureFlip extends Equatable {
  final bool withCampagneRecrutement;
  final String? withMonSuiviDemarchesKoMessage;
  final LoginPageRemoteMessage? loginPageMessage;
  final AccueilZenithMessage? accueilZenithMessage;
  final bool isActualiteMissionLocaleEnabled;
  final String? inviteAccessPassword;
  FeatureFlip({
    required this.withCampagneRecrutement,
    required this.withMonSuiviDemarchesKoMessage,
    required this.loginPageMessage,
    required this.accueilZenithMessage,
    required this.isActualiteMissionLocaleEnabled,
    required this.inviteAccessPassword,
  });

  factory FeatureFlip.initial() {
    return FeatureFlip(
      withCampagneRecrutement: false,
      withMonSuiviDemarchesKoMessage: null,
      loginPageMessage: null,
      accueilZenithMessage: null,
      isActualiteMissionLocaleEnabled: false,
      inviteAccessPassword: null,
    );
  }

  FeatureFlip copyWith({
    bool? withCampagneRecrutement,
    String? withMonSuiviDemarchesKoMessage,
    LoginPageRemoteMessage? loginPageMessage,
    AccueilZenithMessage? accueilZenithMessage,
    bool? isActualiteMissionLocaleEnabled,
    String? inviteAccessPassword,
  }) {
    return FeatureFlip(
      withCampagneRecrutement: withCampagneRecrutement ?? this.withCampagneRecrutement,
      withMonSuiviDemarchesKoMessage: withMonSuiviDemarchesKoMessage ?? this.withMonSuiviDemarchesKoMessage,
      loginPageMessage: loginPageMessage ?? this.loginPageMessage,
      accueilZenithMessage: accueilZenithMessage ?? this.accueilZenithMessage,
      isActualiteMissionLocaleEnabled: isActualiteMissionLocaleEnabled ?? this.isActualiteMissionLocaleEnabled,
      inviteAccessPassword: inviteAccessPassword ?? this.inviteAccessPassword,
    );
  }

  @override
  List<Object?> get props => [
    withCampagneRecrutement,
    withMonSuiviDemarchesKoMessage,
    loginPageMessage,
    accueilZenithMessage,
    isActualiteMissionLocaleEnabled,
    inviteAccessPassword,
  ];
}
