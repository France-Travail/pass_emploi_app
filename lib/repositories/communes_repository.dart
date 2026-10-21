import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

class CommunesRepository {
  static const _baseUrl = 'https://geo.api.gouv.fr';
  static final _digitsOnly = RegExp(r'^\d+$');
  static final _codePostal = RegExp(r'^\d{5}$');
  static final _firstNumber = RegExp(r'\d+');
  // Paris, Lyon, Marseille : l'API renvoie la commune seule, les arrondissements sont à aller chercher à part.
  static const _communesAvecArrondissements = {'75056', '69123', '13055'};

  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  CommunesRepository({Dio? httpClient, Crashlytics? crashlytics})
    : _httpClient = httpClient ?? Dio(BaseOptions(baseUrl: _baseUrl)),
      _crashlytics = crashlytics;

  Future<List<QuestionnaireCommune>> search(
    String query, {
    int limit = 8,
  }) async {
    final normalized = query.trim().replaceAll(RegExp(r'\s+'), '');
    if (normalized.isEmpty) return [];

    if (_digitsOnly.hasMatch(normalized)) {
      if (!_codePostal.hasMatch(normalized)) return [];
      return searchByCodePostal(normalized, limit: limit);
    }

    return searchByName(query.trim(), limit: limit);
  }

  Future<List<QuestionnaireCommune>> _withArrondissements(
    List<QuestionnaireCommune> communes, {
    String? query,
    String? codePostal,
  }) async {
    final result = <QuestionnaireCommune>[];
    for (final commune in communes) {
      result.add(commune);
      if (!_communesAvecArrondissements.contains(commune.code)) continue;
      var arrondissements = await _arrondissements(commune.nom);
      final number = query == null
          ? null
          : _firstNumber.firstMatch(query)?.group(0);
      if (number != null) {
        arrondissements = arrondissements
            .where((a) => _firstNumber.firstMatch(a.nom)?.group(0) == number)
            .toList();
      }
      if (codePostal != null) {
        arrondissements = arrondissements
            .where((a) => a.codePostal == codePostal)
            .toList();
      }
      result.addAll(arrondissements);
    }
    return result;
  }

  Future<List<QuestionnaireCommune>> _arrondissements(String nomCommune) async {
    const path = '/communes';
    try {
      final response = await _httpClient.get<List<dynamic>>(
        path,
        queryParameters: {
          'nom': nomCommune,
          'type': 'arrondissement-municipal',
          'limit': 20,
          'fields': 'nom,code,codesPostaux,centre',
        },
      );
      final data = response.data;
      if (data == null) return [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(QuestionnaireCommune.fromJson)
          .where((a) => a.nom.startsWith('$nomCommune '))
          .toList()
        ..sort((a, b) => a.code.compareTo(b.code));
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, '$_baseUrl$path');
      return [];
    }
  }

  Future<List<QuestionnaireCommune>> searchByName(
    String query, {
    int limit = 8,
  }) async {
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
      final communes = data
          .whereType<Map<String, dynamic>>()
          .map(QuestionnaireCommune.fromJson)
          .toList();
      return _withArrondissements(communes, query: trimmed);
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, '$_baseUrl$path');
      return [];
    }
  }

  Future<List<QuestionnaireCommune>> searchByCodePostal(
    String codePostal, {
    int limit = 8,
  }) async {
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
      final communes = data
          .whereType<Map<String, dynamic>>()
          .map(
            (json) => QuestionnaireCommune.fromJson(
              json,
              preferredCodePostal: trimmed,
            ),
          )
          .toList();
      return _withArrondissements(communes, codePostal: trimmed);
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, '$_baseUrl$path');
      return [];
    }
  }

  Future<QuestionnaireCommune?> findByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
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
