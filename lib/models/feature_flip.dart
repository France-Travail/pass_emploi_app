import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/models/accueil_zenith_message.dart';
import 'package:pass_emploi_app/models/login_page_remote_message.dart';

class FeatureFlip extends Equatable {
  final String? withMonSuiviDemarchesKoMessage;
  final LoginPageRemoteMessage? loginPageMessage;
  final AccueilZenithMessage? accueilZenithMessage;
  final bool isActualiteMissionLocaleEnabled;

  FeatureFlip({
    required this.withMonSuiviDemarchesKoMessage,
    required this.loginPageMessage,
    required this.accueilZenithMessage,
    required this.isActualiteMissionLocaleEnabled,
  });

  factory FeatureFlip.initial() {
    return FeatureFlip(
      withMonSuiviDemarchesKoMessage: null,
      loginPageMessage: null,
      accueilZenithMessage: null,
      isActualiteMissionLocaleEnabled: false,
    );
  }

  FeatureFlip copyWith({
    String? withMonSuiviDemarchesKoMessage,
    LoginPageRemoteMessage? loginPageMessage,
    AccueilZenithMessage? accueilZenithMessage,
    bool? isActualiteMissionLocaleEnabled,
  }) {
    return FeatureFlip(
      withMonSuiviDemarchesKoMessage: withMonSuiviDemarchesKoMessage ?? this.withMonSuiviDemarchesKoMessage,
      loginPageMessage: loginPageMessage ?? this.loginPageMessage,
      accueilZenithMessage: accueilZenithMessage ?? this.accueilZenithMessage,
      isActualiteMissionLocaleEnabled: isActualiteMissionLocaleEnabled ?? this.isActualiteMissionLocaleEnabled,
    );
  }

  @override
  List<Object?> get props => [
    withMonSuiviDemarchesKoMessage,
    loginPageMessage,
    accueilZenithMessage,
    isActualiteMissionLocaleEnabled,
  ];
}
