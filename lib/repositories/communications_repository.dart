import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/communications.dart';

class CommunicationsRepository {
  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  CommunicationsRepository(this._httpClient, [this._crashlytics]);

  Future<Communications?> get(String userId) async {
    final url = "/jeunes/$userId/communications";
    try {
      final response = await _httpClient.get(url);
      return Communications.fromJson(response.data);
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return null;
  }
}
