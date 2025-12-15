import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:pass_emploi_app/models/accueil_zenith_message.dart';
import 'package:pass_emploi_app/models/cgu.dart';
import 'package:pass_emploi_app/models/feedback_for_feature.dart';
import 'package:pass_emploi_app/models/login_page_remote_message.dart';
import 'package:pass_emploi_app/models/remote_campagne_accueil.dart';

class RemoteConfigRepository {
  final FirebaseRemoteConfig? _firebaseRemoteConfig;

  RemoteConfigRepository(this._firebaseRemoteConfig);

  int? maxLivingTimeInSecondsForMilo() {
    if (_firebaseRemoteConfig == null) return null;

    final value = _firebaseRemoteConfig.getInt("app_milo_max_living_time_in_seconds");
    return value > 0 ? value : null;
  }

  int? maxUnauthorizedErrorsBeforeLogout() {
    if (_firebaseRemoteConfig == null) return null;

    final value = _firebaseRemoteConfig.getInt("app_max_401_before_logout");
    return value > 0 ? value : null;
  }

  int monSuiviPoleEmploiStartDateInMonths() {
    if (_firebaseRemoteConfig == null) return 0;
    return _firebaseRemoteConfig.getInt("mon_suivi_ft_start_date_in_months");
  }

  String? lastCampagneRecrutementId() {
    if (_firebaseRemoteConfig == null) return null;

    // millisecond since epoch
    final value = _firebaseRemoteConfig.getInt("campagne_recrutement_date_fin");
    return value > DateTime.now().millisecondsSinceEpoch ? value.toString() : null;
  }

  List<RemoteCampagneAccueil> campagnesAccueil() {
    // try catch because campagnes_accueil is manually set in Firebase Remote Config
    try {
      if (_firebaseRemoteConfig == null) return [];

      final campagneAsString = _firebaseRemoteConfig.getString("campagnes_accueil");
      // Despite Remote config documentation, Firebase returns "null" string value when key is not found
      if (campagneAsString.isEmpty || campagneAsString == "null") return [];
      final json = jsonDecode(campagneAsString) as List;
      return json.map((e) => RemoteCampagneAccueil.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  String? monSuiviDemarchesKoMessage() {
    if (_firebaseRemoteConfig == null) return null;
    final key = _firebaseRemoteConfig.getString("mon_suivi_demarches_ko_message");
    if (key.isEmpty || key == "null") return null;
    return key;
  }

  LoginPageRemoteMessage? loginPageMessage() {
    if (_firebaseRemoteConfig == null) return null;
    final key = _firebaseRemoteConfig.getString("login_page_message");
    if (key.isEmpty || key == "null") return null;
    return LoginPageRemoteMessage.fromJson(json.decode(key) as Map<String, dynamic>);
  }

  AccueilZenithMessage? accueilZenithMessage() {
    if (_firebaseRemoteConfig == null) return null;
    final key = _firebaseRemoteConfig.getString("zenith_accueil_message_milo");
    if (key.isEmpty || key == "null") return null;
    return AccueilZenithMessage.fromJson(json.decode(key) as Map<String, dynamic>);
  }

  bool? isDiagorienteEnabled() {
    if (_firebaseRemoteConfig == null) return null;
    final key = _firebaseRemoteConfig.getBool("is_diagoriente_enabled");
    return key;
  }

  Cgu? getCgu() {
    if (_firebaseRemoteConfig == null) return null;
    final String cguAsString = _firebaseRemoteConfig.getString('cgu');
    // Despite Remote config documentation, Firebase returns "null" string value when key is not found
    if (cguAsString.isEmpty || cguAsString == "null") return null;
    return Cgu.fromJson(json.decode(cguAsString));
  }

  FeedbackForFeature? inAppFeedbackForFeature(String feature) {
    if (_firebaseRemoteConfig == null) return null;
    final String inAppFeedbackAsString = _firebaseRemoteConfig.getString('in_app_feedback_for_feature');
    // Despite Remote config documentation, Firebase returns "null" string value when key is not found
    if (inAppFeedbackAsString.isEmpty || inAppFeedbackAsString == "null") return null;
    final inAppFeedbackAsJson = json.decode(inAppFeedbackAsString);
    final feedbackForFeatureAsJson = inAppFeedbackAsJson[feature];
    return feedbackForFeatureAsJson != null ? FeedbackForFeature.fromJson(feedbackForFeatureAsJson) : null;
  }
}
