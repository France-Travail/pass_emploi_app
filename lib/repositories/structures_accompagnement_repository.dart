import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';

/// Mode invité : Mission Locale ou agences France Travail de la commune choisie.
/// Seuls le code INSEE et le code postal de la commune sont envoyés, jamais la position.
class StructuresAccompagnementRepository {
  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  StructuresAccompagnementRepository(this._httpClient, [this._crashlytics]);

  static const _url = "/referentiels/structures-accompagnement";

  Future<List<StructureAccompagnement>?> get({
    required StructureAccompagnementType type,
    required String codeInsee,
    required String codePostal,
  }) async {
    try {
      final response = await _httpClient.get(
        _url,
        queryParameters: {'type': type.apiValue, 'codeInsee': codeInsee, 'codePostal': codePostal},
      );
      final data = response.data;
      if (data is! List) return null;
      return data.whereType<Map<String, dynamic>>().map(StructureAccompagnement.fromJson).toList();
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, _url);
    }
    return null;
  }
}
