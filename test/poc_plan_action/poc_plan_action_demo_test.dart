import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/poc_plan_action/poc_plan_action_demo.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_request_mapper.dart';

import '../doubles/mocks.dart';
import '../utils/test_setup.dart';

void main() {
  final demo = PocPlanActionDemo.instance;

  Response<dynamic>? repondre(String methode, String chemin, [Object? data]) {
    return demo.repondre(
      RequestOptions(
        method: methode,
        baseUrl: "https://api.test",
        path: chemin,
        data: data,
      ),
    );
  }

  ActionPlan lirePlan([String methode = "GET"]) {
    return ActionPlan.fromApiJson(
      repondre(methode, "/jeunes/SEVP/plan-action")!.data
          as Map<String, dynamic>,
    );
  }

  String progression(ActionPlan plan) {
    return plan.objectives
        .map(
          (objectif) =>
              "${objectif.title} ${objectif.doneCount}/${objectif.totalCount}",
        )
        .join(" | ");
  }

  ActionPlanAction tache(ActionPlan plan, String libelle) {
    return plan.objectives
        .expand((objectif) => objectif.actions)
        .firstWhere((action) => action.label == libelle);
  }

  setUp(() => demo.demarrer(missionLocale: false));

  test(
    "le plan des captures : 5 objectifs dans leur ordre, avec les mêmes cases cochées",
    () {
      expect(
        progression(lirePlan()),
        "Découvrir des métiers 2/8 | M'engager 1/3 | Passer mon permis 0/6 | Boucler mes fins de mois 1/5 | "
        "Prendre soin de ma santé 0/3",
      );
      expect(lirePlan().objectives.map((objectif) => objectif.theme), [
        "DECOUVRIR_METIERS",
        "ENGAGER",
        "PAS_DE_PERMIS",
        "FIN_DE_MOIS",
        "SANTE",
      ]);
    },
  );

  test(
    "les tâches s'ouvrent comme dans l'app : site, écran de l'app ou simple conseil",
    () {
      final plan = lirePlan();

      final fichesMetiers = tache(plan, "Je consulte des fiches métiers");
      expect(fichesMetiers.kind, ActionPlanActionKind.link);
      expect(fichesMetiers.serviceName, "MétierScope - Recherche métier");
      expect(
        tache(plan, "Je consulte les offres de service civique").screen,
        ActionPlanScreen.offresServiceCivique,
      );
      expect(
        plan.objectives.first.actions.map((action) => action.screen).nonNulls,
        [
          ActionPlanScreen.offresImmersions,
          ActionPlanScreen.offresAlternance,
          ActionPlanScreen.evenements,
        ],
      );
      expect(
        tache(plan, "Je fais une demande de devis dans une auto-école").kind,
        ActionPlanActionKind.advice,
      );
    },
  );

  test(
    "cocher ouvre la déclaration, avec la thématique France Travail ou la catégorie Mission Locale",
    () {
      expect(
        lirePlan().objectives
            .expand((objectif) => objectif.actions)
            .every((a) => a.declarationRequise),
        isTrue,
      );
      expect(
        tache(lirePlan(), "Je consulte des fiches métiers").categorie,
        "Mon (nouveau) métier",
      );

      demo.demarrer(missionLocale: true);

      expect(
        tache(lirePlan(), "Je consulte des fiches métiers").categorie,
        "Projet pro",
      );
    },
  );

  test(
    "coches, décoches et suppressions sont gardées, puis la démo suivante repart des captures",
    () {
      repondre("PATCH", "/jeunes/SEVP/plan-action/taches/poc-plan-tache-178", {
        "terminee": true,
        "date": "2026-11-05",
      });
      repondre("PATCH", "/jeunes/SEVP/plan-action/taches/poc-plan-tache-26", {
        "terminee": false,
      });
      repondre("DELETE", "/jeunes/SEVP/plan-action/taches/poc-plan-tache-127");

      expect(
        progression(lirePlan()),
        "Découvrir des métiers 1/8 | M'engager 1/2 | Passer mon permis 1/6 | Boucler mes fins de mois 1/5 | "
        "Prendre soin de ma santé 0/3",
      );

      demo.demarrer(missionLocale: false);

      expect(
        progression(lirePlan()),
        startsWith(
          "Découvrir des métiers 2/8 | M'engager 1/3 | Passer mon permis 0/6",
        ),
      );
    },
  );

  test(
    "« Modifier » renvoie le même plan, coches et suppressions comprises, comme l'API",
    () {
      repondre("DELETE", "/jeunes/SEVP/plan-action/taches/poc-plan-tache-218");
      repondre("DELETE", "/jeunes/SEVP/plan-action/taches/poc-plan-tache-219");
      repondre("DELETE", "/jeunes/SEVP/plan-action/taches/poc-plan-tache-221");

      final plan = lirePlan("POST");

      expect(repondre("POST", "/jeunes/SEVP/plan-action")!.statusCode, 201);
      expect(
        plan.objectives.map((objectif) => objectif.title),
        isNot(contains("Prendre soin de ma santé")),
      );
      expect(plan.objectives.first.doneCount, 2);
    },
  );

  test("les réponses du jeune fictif rendent le questionnaire complet", () {
    final json =
        repondre("GET", "/jeunes/SEVP/questionnaire")!.data
            as Map<String, dynamic>;

    final answers = const ActionPlanRequestMapper().fromQuestionnaireResponse(
      json,
      const OnboardingQuestionnaireAnswers(),
    );

    expect(
      answers.completeness(withPrenom: false),
      OnboardingQuestionnaireCompleteness.complet,
    );
    expect(answers.objectifs, {
      QuestionnaireObjectif.decouvrirMetiers,
      QuestionnaireObjectif.engager,
    });
    expect(answers.freins, {
      QuestionnaireFrein.pasDePermis,
      QuestionnaireFrein.finDeMois,
      QuestionnaireFrein.sante,
    });
    expect(answers.habitation?.nom, "Lille");
  });

  test("les autres routes gardent le mode démo habituel", () {
    expect(repondre("GET", "/jeunes/SEVP/fonctionnalites"), isNull);
    expect(repondre("GET", "/jeunes/SEVP/mon-suivi"), isNull);
  });

  group("au lancement de l'app", () {
    late MockOnboardingQuestionnaireRepository questionnaireRepository;
    late MockActionPlanRepository actionPlanRepository;

    setUp(() {
      questionnaireRepository = MockOnboardingQuestionnaireRepository();
      actionPlanRepository = MockActionPlanRepository();
    });

    void lancer() {
      final factory = TestStoreFactory()
        ..onboardingQuestionnaireRepository = questionnaireRepository
        ..actionPlanRepository = actionPlanRepository;
      factory
          .initializeReduxStore(initialState: AppState.initialState())
          .dispatch(BootstrapAction());
    }

    test(
      "une démo fermée sans déconnexion : son plan et ses réponses sont effacés",
      () async {
        when(
          () => actionPlanRepository.getStoredPlanId(),
        ).thenAnswer((_) async => PocPlanActionDemo.idPlan);

        lancer();
        await untilCalled(() => actionPlanRepository.clear());

        verify(() => questionnaireRepository.clear()).called(1);
      },
    );

    test("le plan d'un vrai jeune est gardé", () async {
      when(
        () => actionPlanRepository.getStoredPlanId(),
      ).thenAnswer((_) async => "plan-d-un-vrai-jeune");

      lancer();
      await untilCalled(() => actionPlanRepository.getStoredPlanId());
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => actionPlanRepository.clear());
      verifyNever(() => questionnaireRepository.clear());
    });
  });
}
