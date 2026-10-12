import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';

/// Rattache au jeune connecté le compte invité qu'il utilisait. La preuve est l'access token de l'invité ;
/// l'API répond 204 aussi quand l'invité est déjà rattaché à ce jeune, l'appel est donc rejouable.
class RepriseCompteInviteRepository {
  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  RepriseCompteInviteRepository(this._httpClient, [this._crashlytics]);

  Future<bool> reprendre({
    required String userId,
    required String jetonInvite,
    Map<String, dynamic>? plan,
  }) async {
    final url = "/jeunes/$userId/reprise-invite";
    try {
      final data = {
        "jetonInvite": jetonInvite,
        if (plan != null) "plan": plan,
      };
      await _httpClient.post(url, data: data);
      return true;
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return false;
  }
}
