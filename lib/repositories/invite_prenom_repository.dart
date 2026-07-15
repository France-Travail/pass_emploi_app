import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';

/// Mode invité : le prénom d'affichage est la source de vérité côté API. Le JWT
/// le reprendra tout seul au refresh suivant (Connect relit l'API).
class InvitePrenomRepository {
  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  InvitePrenomRepository(this._httpClient, [this._crashlytics]);

  static String _url({required String userId}) => "/jeunes/$userId/invite/prenom";

  Future<String?> getPrenom(String userId) async {
    final url = _url(userId: userId);
    try {
      final response = await _httpClient.get(url);
      return response.data["prenom"] as String?;
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return null;
  }

  Future<bool> updatePrenom(String userId, String prenom) async {
    final url = _url(userId: userId);
    try {
      await _httpClient.put(url, data: {"prenom": prenom});
      return true;
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return false;
  }
}
