import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';

class RepriseCompteInviteRepository {
  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  RepriseCompteInviteRepository(this._httpClient, [this._crashlytics]);

  Future<bool> reprendre({
    required String idInvite,
    required String jetonConnecte,
    Map<String, dynamic>? plan,
  }) async {
    final url = "/jeunes/$idInvite/reprise-invite";
    try {
      await _httpClient.post(
        url,
        data: {
          "jetonConnecte": jetonConnecte,
          if (plan != null) "plan": plan,
        },
      );
      return true;
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return false;
  }
}
