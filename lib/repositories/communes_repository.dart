import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

class CommunesRepository {
  static const _baseUrl = 'https://geo.api.gouv.fr';
  static final _digitsOnly = RegExp(r'^\d+$');
  static final _codePostal = RegExp(r'^\d{5}$');
  static final _firstNumber = RegExp(r'\d+');
  // Paris, Lyon, Marseille : l'API renvoie la commune seule, les arrondissements sont à aller chercher à part.
  static const _communesAvecArrondissements = QuestionnaireCommune.codesCommunesAvecArrondissements;

  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  CommunesRepository({Dio? httpClient, this._crashlytics})
    : _httpClient = httpClient ?? Dio(BaseOptions(baseUrl: _baseUrl));

  /// [oneEntryPerCodePostal] : une commune à plusieurs codes postaux (Toulouse : 31000, 31100…) est proposée une fois
  /// par code postal, pour que l'utilisateur choisisse celui de son quartier.
  Future<List<QuestionnaireCommune>> search(
    String query, {
    int limit = 8,
    bool oneEntryPerCodePostal = false,
  }) async {
    final normalized = query.trim().replaceAll(RegExp(r'\s+'), '');
    if (normalized.isEmpty) return [];

    if (_digitsOnly.hasMatch(normalized)) {
      if (!_codePostal.hasMatch(normalized)) return [];
      return searchByCodePostal(normalized, limit: limit);
    }

    return searchByName(query.trim(), limit: limit, oneEntryPerCodePostal: oneEntryPerCodePostal);
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
    bool oneEntryPerCodePostal = false,
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
          .expand((json) => oneEntryPerCodePostal ? _perCodePostal(json) : [QuestionnaireCommune.fromJson(json)])
          .toList();
      return await _withArrondissements(communes, query: trimmed);
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
      return await _withArrondissements(communes, codePostal: trimmed);
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, '$_baseUrl$path');
      return [];
    }
  }

  // Paris, Lyon et Marseille gardent une seule entrée : leurs arrondissements, chacun avec son code postal, suivent.
  static List<QuestionnaireCommune> _perCodePostal(Map<String, dynamic> json) {
    final codesPostaux = json['codesPostaux'];
    if (_communesAvecArrondissements.contains(json['code']) || codesPostaux is! List || codesPostaux.length < 2) {
      return [QuestionnaireCommune.fromJson(json)];
    }
    final codes = codesPostaux.map((code) => code.toString()).toSet().toList()..sort();
    return codes.map((code) => QuestionnaireCommune.fromJson(json, preferredCodePostal: code)).toList();
  }

  /// [preferArrondissement] : à Paris, Lyon et Marseille, renvoie l'arrondissement où se trouve la position plutôt que
  /// la commune entière.
  Future<QuestionnaireCommune?> findByCoordinates({
    required double latitude,
    required double longitude,
    bool preferArrondissement = false,
  }) async {
    final commune = await _findByCoordinates(latitude: latitude, longitude: longitude);
    if (!preferArrondissement || commune == null || !_communesAvecArrondissements.contains(commune.code)) {
      return commune;
    }
    final arrondissement = await _findByCoordinates(
      latitude: latitude,
      longitude: longitude,
      type: 'arrondissement-municipal',
    );
    return arrondissement ?? commune;
  }

  Future<QuestionnaireCommune?> _findByCoordinates({
    required double latitude,
    required double longitude,
    String? type,
  }) async {
    const path = '/communes';
    try {
      final response = await _httpClient.get<List<dynamic>>(
        path,
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'type': ?type,
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
