import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/demarche_ia_dto.dart';
import 'package:pass_emploi_app/network/dio_ext.dart';

class IaFtSuggestionsRepository {
  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  IaFtSuggestionsRepository(this._httpClient, [this._crashlytics]);

  Future<List<DemarcheIaDto>?> get(String idJeune, String query) async {
    final url = "/jeunes/$idJeune/demarches-ia";
    try {
      // TODO: remove this
      if (1 == 1) return [DemarcheIaDto(codeQuoi: "P01", codePourquoi: "P8", description: "description")];
      final response = await _httpClient.post(url, data: {"contenu": query});
      return response.asListOf(DemarcheIaDto.fromJson);
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return null;
  }
}
