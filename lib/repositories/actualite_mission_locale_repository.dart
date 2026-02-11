import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/actualite_mission_locale.dart';

class ActualiteMissionLocaleRepository {
  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  ActualiteMissionLocaleRepository(this._httpClient, [this._crashlytics]);

  Future<List<ActualiteMissionLocale>?> get(String userId) async {
    final url = "/jeunes/milo/$userId/actualites";
    try {
      final response = await _httpClient.get(url);
      final data = response.data as Map<String, dynamic>;
      final actualitesJson = (data['actualites']) as List<dynamic>? ?? [];
      return actualitesJson
          .asMap()
          .entries
          .map((entry) => ActualiteMissionLocale.fromJson(entry.value as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return null;
  }
}
