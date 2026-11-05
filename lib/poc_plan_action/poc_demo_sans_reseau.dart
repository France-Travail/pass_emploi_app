import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_donnees.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/communes_repository.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';

// Mode démo : aucun appel ne part, ni vers l'API ni vers un autre service. Villes et métiers viennent des listes
// locales du POC offres ; les autres routes que le mode démo ne simule pas échouent en lecture et réussissent en
// écriture, sans rien envoyer.

Response<dynamic>? pocReferentielDemo(RequestOptions options) {
  final path = options.uri.path;
  final recherche = options.uri.queryParameters["recherche"] ?? "";
  if (path.endsWith("/referentiels/communes-et-departements")) {
    return Response(
      requestOptions: options,
      statusCode: 200,
      data: [for (final commune in pocCommunesCorrespondantes(recherche)) commune.toJson()],
    );
  }
  if (path.endsWith("/referentiels/metiers")) {
    return Response(
      requestOptions: options,
      statusCode: 200,
      data: [
        for (final metier in pocMetiersCorrespondants(recherche)) {"code": metier.codeRome, "libelle": metier.libelle},
      ],
    );
  }
  return null;
}

void pocRepondreSansReseau(RequestOptions options, RequestInterceptorHandler handler) {
  if (options.method == "GET") {
    handler.reject(DioException(requestOptions: options, message: "Mode démo : aucun appel réseau"));
  } else {
    handler.resolve(Response(requestOptions: options, statusCode: 201));
  }
}

// Les formulaires d'avis (Tally) ne s'ouvrent pas en mode démo.
void pocOuvrirHorsDemo(BuildContext context, String url) {
  if (StoreProvider.of<AppState>(context, listen: false).state.demoState) return;
  launchExternalUrl(url);
}

// Le questionnaire cherche les communes directement sur geo.api.gouv.fr : en mode démo, il les prend dans la liste
// locale, avec les mêmes règles de saisie (nom de 3 lettres au moins, ou code postal complet).
class PocCommunesDemoRepository extends CommunesRepository {
  static final _chiffres = RegExp(r'^\d+$');

  @override
  Future<List<QuestionnaireCommune>> search(String query, {int limit = 8}) async {
    final saisie = query.trim();
    final valide = _chiffres.hasMatch(saisie) ? saisie.length == 5 : saisie.length >= 3;
    if (!valide) return [];
    return pocCommunesCorrespondantes(saisie).take(limit).map(_versQuestionnaire).toList();
  }

  @override
  Future<List<QuestionnaireCommune>> searchByName(String query, {int limit = 8}) => search(query, limit: limit);

  @override
  Future<List<QuestionnaireCommune>> searchByCodePostal(String codePostal, {int limit = 8}) {
    return search(codePostal, limit: limit);
  }

  @override
  Future<QuestionnaireCommune?> findByCoordinates({required double latitude, required double longitude}) async {
    double distance(Location commune) {
      final ecartLatitude = commune.latitude! - latitude;
      final ecartLongitude = commune.longitude! - longitude;
      return ecartLatitude * ecartLatitude + ecartLongitude * ecartLongitude;
    }

    return _versQuestionnaire(pocCommunes.reduce((a, b) => distance(a) <= distance(b) ? a : b));
  }

  static QuestionnaireCommune _versQuestionnaire(Location commune) {
    return QuestionnaireCommune(
      code: commune.code,
      nom: commune.libelle,
      codePostal: commune.codePostal,
      latitude: commune.latitude,
      longitude: commune.longitude,
    );
  }
}
