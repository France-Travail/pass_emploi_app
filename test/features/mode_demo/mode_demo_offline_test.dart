import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/mode_demo/is_mode_demo_repository.dart';
import 'package:pass_emploi_app/features/mode_demo/mode_demo_offline.dart';
import 'package:pass_emploi_app/features/mode_demo/plan_action/mode_demo_plan_action.dart';
import 'package:pass_emploi_app/models/metier.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/network/interceptors/demo_interceptor.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';
import 'package:pass_emploi_app/redux/app_reducer.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/widgets/text_form_fields/metier_autocomplete.dart';
import 'package:redux/redux.dart';

void main() {
  // Le plan et les réponses du jeune fictif sont lus dans les fichiers de assets/mode_demo/.
  TestWidgetsFlutterBinding.ensureInitialized();

  late _ReseauEspion reseau;

  Dio client({required bool demo}) {
    reseau = _ReseauEspion();
    return Dio(BaseOptions(baseUrl: "https://api.test"))
      ..httpClientAdapter = reseau
      ..interceptors.add(DemoInterceptor(ModeDemoRepository()..setModeDemo(demo)));
  }

  group("en mode démo, rien ne part sur le réseau", () {
    test("toute recherche de ville ne propose que la ville de la démo", () async {
      final reponse = await client(demo: true).get("/referentiels/communes-et-departements?recherche=Marseille");

      expect((reponse.data as List).map((commune) => commune["libelle"]), ["Lille"]);
      expect(reseau.appels, isEmpty);
    });

    test("toute recherche de métier ne propose que le métier de la démo", () async {
      final reponse = await client(demo: true).get("/referentiels/metiers?recherche=plombier");

      expect(reponse.data, [
        {"code": "D1102", "libelle": "Boulanger / Boulangère"},
      ]);
      expect(reseau.appels, isEmpty);
    });

    test("le plan d'action et le questionnaire viennent de la démo", () async {
      ModeDemoPlanAction.instance.start(missionLocale: false);
      final dio = client(demo: true);

      await dio.get("/jeunes/SEVP/plan-action");
      await dio.patch("/jeunes/SEVP/plan-action/taches/demo-tache-28", data: {"terminee": true});
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

  test("le questionnaire de la démo n'a que la ville de la démo, sans geo.api.gouv.fr", () async {
    final communes = ModeDemoCommunesRepository();

    expect(await communes.search("Marseille"), [modeDemoCommune]);
    expect(await communes.findByCoordinates(latitude: 43.3, longitude: 5.4), modeDemoCommune);
  });

  test("ville imposée : le questionnaire prend Lille pour l'habitation et la ville de recherche", () async {
    final form = OnboardingQuestionnaireFormChangeNotifier(
      loadAnswers: () async => const OnboardingQuestionnaireAnswers(),
      saveAnswers: (_) async {},
      fixedCommune: modeDemoCommune,
    );

    await form.init();

    expect(form.draftHabitation, modeDemoCommune);
    expect(form.draftHabitationQuery, "Lille (59000)");
    expect(form.draftVilleRecherche, modeDemoCommune);
  });

  testWidgets("métier imposé : la recherche d'immersion reçoit le métier de la démo, et le champ ne s'ouvre pas", (
    tester,
  ) async {
    final store = Store<AppState>(reducer, initialState: AppState.initialState().copyWith(demoState: true));
    final choisis = <Metier?>[];

    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          home: Scaffold(
            body: MetierAutocomplete(title: "Métier", onMetierSelected: choisis.add),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text("Boulanger / Boulangère"), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(choisis, [modeDemoMetier]);
    expect(find.byType(MetierAutocomplete), findsOneWidget);
    expect(find.text("Boulanger / Boulangère"), findsOneWidget);
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
