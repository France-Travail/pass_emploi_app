import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/mode_demo/is_mode_demo_repository.dart';
import 'package:pass_emploi_app/network/interceptors/demo_interceptor.dart';
import 'package:pass_emploi_app/poc_plan_action/poc_demo_sans_reseau.dart';
import 'package:pass_emploi_app/poc_plan_action/poc_plan_action_demo.dart';

void main() {
  late _ReseauEspion reseau;

  Dio client({required bool demo}) {
    reseau = _ReseauEspion();
    return Dio(BaseOptions(baseUrl: "https://api.test"))
      ..httpClientAdapter = reseau
      ..interceptors.add(DemoInterceptor(ModeDemoRepository()..setModeDemo(demo)));
  }

  group("en mode démo, rien ne part sur le réseau", () {
    test("les villes viennent de la liste locale", () async {
      final reponse = await client(
        demo: true,
      ).get("/referentiels/communes-et-departements?recherche=lil&villesOnly=true");

      expect((reponse.data as List).map((commune) => commune["libelle"]), ["Lille"]);
      expect(reseau.appels, isEmpty);
    });

    test("les métiers viennent de la liste locale", () async {
      final reponse = await client(demo: true).get("/referentiels/metiers?recherche=boulanger");

      expect((reponse.data as List).first, {"code": "D1102", "libelle": "Boulanger / Boulangère"});
      expect(reseau.appels, isEmpty);
    });

    test("le plan d'action et le questionnaire viennent du plan en dur", () async {
      PocPlanActionDemo.instance.demarrer(missionLocale: false);
      final dio = client(demo: true);

      await dio.get("/jeunes/SEVP/plan-action");
      await dio.patch("/jeunes/SEVP/plan-action/taches/poc-plan-tache-28", data: {"terminee": true});
      await dio.get("/jeunes/SEVP/questionnaire");

      expect(reseau.appels, isEmpty);
    });

    test("une lecture que la démo ne simule pas échoue", () async {
      await expectLater(client(demo: true).get("/actions/1"), throwsA(isA<DioException>()));
      expect(reseau.appels, isEmpty);
    });

    test("une écriture que la démo ne simule pas réussit sans rien envoyer", () async {
      final reponse = await client(demo: true).put("/actions/1", data: {"status": "DONE"});

      expect(reponse.statusCode, 201);
      expect(reseau.appels, isEmpty);
    });

    test("un autre serveur que l'API n'est pas appelé non plus", () async {
      await expectLater(
        client(demo: true).get("https://cv.example.org/boulanger-2023.pdf"),
        throwsA(isA<DioException>()),
      );
      expect(reseau.appels, isEmpty);
    });
  });

  test("hors démo, les requêtes partent normalement", () async {
    await client(demo: false).get("/referentiels/metiers?recherche=boulanger");

    expect(reseau.appels, hasLength(1));
  });

  group("communes du questionnaire en démo, sans geo.api.gouv.fr", () {
    final communes = PocCommunesDemoRepository();

    test("un nom de 3 lettres au moins, ou un code postal complet", () async {
      expect((await communes.search("lil")).map((commune) => commune.nom), ["Lille"]);
      expect((await communes.search("59000")).map((commune) => commune.nom), ["Lille"]);
      expect(await communes.search("li"), isEmpty);
      expect(await communes.search("590"), isEmpty);
    });

    test("« Me géolocaliser » donne la commune de la liste la plus proche", () async {
      final commune = await communes.findByCoordinates(latitude: 50.69, longitude: 3.17);

      expect(commune?.nom, "Roubaix");
    });
  });
}

class _ReseauEspion implements HttpClientAdapter {
  final appels = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    appels.add(options.uri.toString());
    return ResponseBody.fromString(
      "[]",
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
