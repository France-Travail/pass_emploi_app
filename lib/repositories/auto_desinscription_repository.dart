import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';

class AutoDesinscriptionRepository {
  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  AutoDesinscriptionRepository(this._httpClient, [this._crashlytics]);

  Future<bool?> desinscrire(String userId, String eventId, String motif) async {
    final url = "/jeunes/milo/$userId/sessions/$eventId/desinscrire";
    try {
      await _httpClient.post(
        url,
        data: {
          "motif": motif,
        },
      );
      return true;
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return null;
  }
}
