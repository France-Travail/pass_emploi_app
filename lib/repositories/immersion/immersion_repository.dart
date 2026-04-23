import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_filtres_recherche.dart';
import 'package:pass_emploi_app/models/immersion.dart';
import 'package:pass_emploi_app/models/recherche/recherche_repository.dart';
import 'package:pass_emploi_app/models/recherche/recherche_request.dart';
import 'package:pass_emploi_app/network/dio_ext.dart';

class ImmersionRepository
    extends RechercheRepository<ImmersionCriteresRecherche, ImmersionFiltresRecherche, Immersion> {
  static const PAGE_SIZE = 50;

  final Dio _httpClient;
  final Crashlytics? _crashlytics;

  ImmersionRepository(this._httpClient, [this._crashlytics]);

  @override
  Future<RechercheResponse<Immersion>?> rechercher({
    required String userId,
    required RechercheRequest<ImmersionCriteresRecherche, ImmersionFiltresRecherche> request,
  }) async {
    const url = "/offres-immersion/v3";
    try {
      final response = await _httpClient.get(url, queryParameters: _queryParameters(request));
      final list = response.asListOfWithKey('offres', (json) => Immersion.fromJson(json));
      return RechercheResponse(results: list, canLoadMore: list.length == PAGE_SIZE);
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return null;
  }

  Map<String, dynamic> _queryParameters(
    RechercheRequest<ImmersionCriteresRecherche, ImmersionFiltresRecherche> request,
  ) {
    final appellationCode = request.criteres.appellationCode;
    final codeRome = request.criteres.metier?.codeRome;
    return {
      if (appellationCode != null) 'appellationCode': appellationCode,
      if (codeRome != null) 'rome': codeRome,
      'lat': request.criteres.location.latitude,
      'lon': request.criteres.location.longitude,
      if (request.filtres.distance != null) 'distance': request.filtres.distance,
      'page': request.page,
      'limit': PAGE_SIZE,
    };
  }
}
