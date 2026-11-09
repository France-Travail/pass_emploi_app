import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/features/mode_demo/plan_action/mode_demo_plan_action.dart';
import 'package:pass_emploi_app/presentation/accueil/invite_accueil_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_request_mapper.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../utils/test_setup.dart';

void main() {
  // Le plan et les réponses du jeune fictif sont lus dans les fichiers de assets/mode_demo/.
  TestWidgetsFlutterBinding.ensureInitialized();

  final demo = ModeDemoPlanAction.instance;

  Future<Response<dynamic>?> repondre(String methode, String chemin, [Object? data]) {
    return demo.respond(
      RequestOptions(
        method: methode,
        baseUrl: "https://api.test",
        path: chemin,
        data: data,
      ),
    );
  }

  Future<ActionPlan> lirePlan([String methode = "GET"]) async {
    final reponse = await repondre(methode, "/jeunes/SEVP/plan-action");
    return ActionPlan.fromApiJson(reponse!.data as Map<String, dynamic>);
  }

  String progression(ActionPlan plan) {
    return plan.objectives
        .map(
          (objectif) => "${objectif.title} ${objectif.doneCount}/${objectif.totalCount}",
        )
        .join(" | ");
  }

  ActionPlanAction tache(ActionPlan plan, String libelle) {
    return plan.objectives.expand((objectif) => objectif.actions).firstWhere((action) => action.label == libelle);
  }

  setUp(() => demo.start(missionLocale: false));

  test(
    "le plan des captures : 5 objectifs dans leur ordre, avec les mêmes cases cochées",
    () async {
      final plan = await lirePlan();

      expect(
        progression(plan),
        "Découvrir des métiers 2/8 | M'engager 1/3 | Passer mon permis 0/6 | Boucler mes fins de mois 1/5 | "
        "Prendre soin de ma santé 0/3",
      );
      expect(plan.objectives.map((objectif) => objectif.theme), [
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
    () async {
      final plan = await lirePlan();

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
    () async {
      final planFranceTravail = await lirePlan();
      expect(
        planFranceTravail.objectives.expand((objectif) => objectif.actions).every((a) => a.declarationRequise),
        isTrue,
      );
      expect(
        tache(planFranceTravail, "Je consulte des fiches métiers").categorie,
        "Mon (nouveau) métier",
      );

      demo.start(missionLocale: true);

      expect(
        tache(await lirePlan(), "Je consulte des fiches métiers").categorie,
        "Projet pro",
      );
    },
  );

  test(
    "coches, décoches et suppressions sont gardées, puis la démo suivante repart des captures",
    () async {
      await repondre("PATCH", "/jeunes/SEVP/plan-action/taches/demo-tache-178", {
        "terminee": true,
        "date": "2026-11-05",
      });
      await repondre("PATCH", "/jeunes/SEVP/plan-action/taches/demo-tache-26", {
        "terminee": false,
      });
      await repondre("DELETE", "/jeunes/SEVP/plan-action/taches/demo-tache-127");

      expect(
        progression(await lirePlan()),
        "Découvrir des métiers 1/8 | M'engager 1/2 | Passer mon permis 1/6 | Boucler mes fins de mois 1/5 | "
        "Prendre soin de ma santé 0/3",
      );

      demo.start(missionLocale: false);

      expect(
        progression(await lirePlan()),
        startsWith(
          "Découvrir des métiers 2/8 | M'engager 1/3 | Passer mon permis 0/6",
        ),
      );
    },
  );

  test(
    "« Modifier » renvoie le même plan, coches et suppressions comprises, comme l'API",
    () async {
      await repondre("DELETE", "/jeunes/SEVP/plan-action/taches/demo-tache-218");
      await repondre("DELETE", "/jeunes/SEVP/plan-action/taches/demo-tache-219");
      await repondre("DELETE", "/jeunes/SEVP/plan-action/taches/demo-tache-221");

      final plan = await lirePlan("POST");

      expect((await repondre("POST", "/jeunes/SEVP/plan-action"))!.statusCode, 201);
      expect(
        plan.objectives.map((objectif) => objectif.title),
        isNot(contains("Prendre soin de ma santé")),
      );
      expect(plan.objectives.first.doneCount, 2);
    },
  );

  test("les réponses du jeune fictif rendent le questionnaire complet", () async {
    final json = (await repondre("GET", "/jeunes/SEVP/questionnaire"))!.data as Map<String, dynamic>;

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

  test("les autres routes gardent le mode démo habituel", () async {
    expect(await repondre("GET", "/jeunes/SEVP/fonctionnalites"), isNull);
    expect(await repondre("GET", "/jeunes/SEVP/mon-suivi"), isNull);
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
      factory.initializeReduxStore(initialState: AppState.initialState()).dispatch(BootstrapAction());
    }

    test(
      "une démo fermée sans déconnexion : son plan et ses réponses sont effacés",
      () async {
        when(
          () => actionPlanRepository.getStoredPlanId(),
        ).thenAnswer((_) async => ModeDemoPlanAction.planId);

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

  group("fin du questionnaire en démo", () {
    late Store<AppState> store;

    Future<OnboardingQuestionnaireAnswers> terminer(OnboardingQuestionnaireAnswers reponses) async {
      final actionPlanRepository = MockActionPlanRepository();
      final plan = ActionPlan.fromApiJson(await demo.planJson());
      when(
        () => actionPlanRepository.generate(any(), any(), keepLocalProgress: any(named: 'keepLocalProgress')),
      ).thenAnswer((_) async => plan);
      final factory = TestStoreFactory()
        ..onboardingQuestionnaireRepository = MockOnboardingQuestionnaireRepository()
        ..actionPlanRepository = actionPlanRepository;
      store = factory.initializeReduxStore(
        initialState: AppState.initialState().copyWith(
          loginState: LoginSuccessState(mockUser(id: "SEVP", loginMode: LoginMode.DEMO_PE)),
          demoState: true,
        ),
      );
      final succes = store.onChange.firstWhere((state) => state.actionPlanState is ActionPlanSuccessState);

      store.dispatch(OnboardingQuestionnaireCompleteAction(reponses));

      expect((await succes).actionPlanState, ActionPlanSuccessState(plan));
      return verify(
            () => actionPlanRepository.generate(
              any(),
              captureAny(),
              keepLocalProgress: any(named: 'keepLocalProgress'),
            ),
          ).captured.single
          as OnboardingQuestionnaireAnswers;
    }

    test("toutes les étapes passées : la démo rend le plan en dur et referme le questionnaire", () async {
      final demandees = await terminer(const OnboardingQuestionnaireAnswers());
      await Future<void>.delayed(Duration.zero);

      expect(demandees.canGenerateActionPlan, isTrue);
      expect(
        store.state.onboardingQuestionnaireState,
        isA<OnboardingQuestionnaireSuccessState>().having((state) => state.finished, "terminé", isTrue),
      );
    });

    test("réponses incomplètes : l'accueil de la démo reste celui du plan complet, avec « Modifier »", () async {
      final store = givenState()
          .loggedInUser(loginMode: LoginMode.DEMO_PE)
          .withOnboardingQuestionnaire(finished: true)
          .withActionPlanSuccess(ActionPlan.fromApiJson(await demo.planJson()))
          .copyWith(demoState: true)
          .store();

      final viewModel = InviteAccueilViewModel.create(store);

      expect(viewModel.mode, InviteAccueilMode.complet);
      expect(viewModel.planSubtitle, Strings.inviteAccueilPlanSubtitleComplet);
      expect(viewModel.showModifierButton, isTrue);
      expect(viewModel.showQuestionnaireCard, isFalse);
    });

    test("une autre ville que Lille : la demande garde les réponses du jeune", () async {
      const lyon = QuestionnaireCommune(code: "69123", nom: "Lyon", codePostal: "69001");
      const reponses = OnboardingQuestionnaireAnswers(
        situation: QuestionnaireSituation.emploi,
        objectifs: {QuestionnaireObjectif.emploi},
        villeRecherche: lyon,
      );

      expect(await terminer(reponses), reponses);
    });
  });
}
