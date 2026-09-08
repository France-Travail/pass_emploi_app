import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/fonctionnalite.dart';

class FonctionnalitesRepository {
  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  FonctionnalitesRepository(this._httpClient, [this._crashlytics]);

  Future<Set<Fonctionnalite>?> get(String userId) async {
    final url = "/jeunes/$userId/fonctionnalites";
    try {
      final response = await _httpClient.get(url);
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      final fonctionnalites = data['fonctionnalites'];
      if (fonctionnalites is! List) return null;
      return fonctionnalites.whereType<String>().map(Fonctionnalite.fromString).nonNulls.toSet();
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return null;
  }
}
