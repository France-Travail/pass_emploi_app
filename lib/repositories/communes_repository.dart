import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

class CommunesRepository {
  static const _baseUrl = 'https://geo.api.gouv.fr';
  static final _digitsOnly = RegExp(r'^\d+$');
  static final _codePostal = RegExp(r'^\d{5}$');

  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  CommunesRepository({Dio? httpClient, Crashlytics? crashlytics})
    : _httpClient = httpClient ?? Dio(BaseOptions(baseUrl: _baseUrl)),
      _crashlytics = crashlytics;

  Future<List<QuestionnaireCommune>> search(String query, {int limit = 8}) async {
    final normalized = query.trim().replaceAll(RegExp(r'\s+'), '');
    if (normalized.isEmpty) return [];

    if (_digitsOnly.hasMatch(normalized)) {
      if (!_codePostal.hasMatch(normalized)) return [];
      return searchByCodePostal(normalized, limit: limit);
    }

    return searchByName(query.trim(), limit: limit);
  }

  Future<List<QuestionnaireCommune>> searchByName(String query, {int limit = 8}) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return [];
    const path = '/communes';
    try {
      final response = await _httpClient.get<List<dynamic>>(
        path,
        queryParameters: {
          'nom': trimmed,
          'boost': 'population',
          'limit': limit,
          'fields': 'nom,code,codesPostaux,centre',
        },
      );
      final data = response.data;
      if (data == null) return [];
      return data.whereType<Map<String, dynamic>>().map(QuestionnaireCommune.fromJson).toList();
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, '$_baseUrl$path');
      return [];
    }
  }

  Future<List<QuestionnaireCommune>> searchByCodePostal(String codePostal, {int limit = 8}) async {
    final trimmed = codePostal.trim().replaceAll(RegExp(r'\s+'), '');
    if (!_codePostal.hasMatch(trimmed)) return [];
    const path = '/communes';
    try {
      final response = await _httpClient.get<List<dynamic>>(
        path,
        queryParameters: {
          'codePostal': trimmed,
          'limit': limit,
          'fields': 'nom,code,codesPostaux,centre',
        },
      );
      final data = response.data;
      if (data == null) return [];
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => QuestionnaireCommune.fromJson(json, preferredCodePostal: trimmed))
          .toList();
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, '$_baseUrl$path');
      return [];
    }
  }

  Future<QuestionnaireCommune?> findByCoordinates({required double latitude, required double longitude}) async {
    const path = '/communes';
    try {
      final response = await _httpClient.get<List<dynamic>>(
        path,
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'fields': 'nom,code,codesPostaux,centre',
        },
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      final first = data.first;
      if (first is! Map<String, dynamic>) return null;
      return QuestionnaireCommune.fromJson(first);
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, '$_baseUrl$path');
      return null;
    }
  }
}
