import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/models/metier.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/communes_repository.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';

// Mode démo : aucun appel ne part, ni vers l'API ni vers un autre service. La démo a une ville (Lille) et un métier
// (boulanger) : le questionnaire et la recherche d'immersion les imposent, les autres recherches ne proposent qu'eux.

const modeDemoCommune = QuestionnaireCommune(
  code: "59350",
  nom: "Lille",
  codePostal: "59000",
  latitude: 50.6292,
  longitude: 3.0573,
);

final modeDemoLocation = Location(
  libelle: "Lille",
  code: "59350",
  type: LocationType.COMMUNE,
  codePostal: "59000",
  latitude: 50.6292,
  longitude: 3.0573,
);

final modeDemoMetier = Metier(codeRome: "D1102", libelle: "Boulanger / Boulangère");

Response<dynamic>? modeDemoReferentielResponse(RequestOptions options) {
  final path = options.uri.path;
  if (path.endsWith("/referentiels/communes-et-departements")) {
    return Response(requestOptions: options, statusCode: 200, data: [modeDemoLocation.toJson()]);
  }
  if (path.endsWith("/referentiels/metiers")) {
    return Response(
      requestOptions: options,
      statusCode: 200,
      data: [
        {"code": modeDemoMetier.codeRome, "libelle": modeDemoMetier.libelle},
      ],
    );
  }
  return null;
}

// Une lecture que la démo ne simule pas échoue ; une écriture réussit, sans rien envoyer.
void respondWithoutNetwork(RequestOptions options, RequestInterceptorHandler handler) {
  if (options.method == "GET") {
    handler.reject(DioException(requestOptions: options, message: "Mode démo : aucun appel réseau"));
  } else {
    handler.resolve(Response(requestOptions: options, statusCode: 201));
  }
}

// Les formulaires d'avis (Tally) ne s'ouvrent pas en mode démo.
void launchExternalUrlUnlessDemo(BuildContext context, String url) {
  if (StoreProvider.of<AppState>(context, listen: false).state.demoState) return;
  launchExternalUrl(url);
}

// Le questionnaire cherche les communes directement sur geo.api.gouv.fr : en mode démo, il n'a que la ville de la démo.
class ModeDemoCommunesRepository extends CommunesRepository {
  @override
  Future<List<QuestionnaireCommune>> search(String query, {int limit = 8}) async => [modeDemoCommune];

  @override
  Future<List<QuestionnaireCommune>> searchByName(String query, {int limit = 8}) async => [modeDemoCommune];

  @override
  Future<List<QuestionnaireCommune>> searchByCodePostal(String codePostal, {int limit = 8}) async => [modeDemoCommune];

  @override
  Future<QuestionnaireCommune?> findByCoordinates({required double latitude, required double longitude}) async {
    return modeDemoCommune;
  }
}
