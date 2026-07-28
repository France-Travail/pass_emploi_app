import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_repository.dart';

import '../../doubles/spies.dart';
import '../../dsl/sut_dio_repository.dart';

void main() {
  group('ActionPlanRepository', () {
    final sut = DioRepositorySut<ActionPlanRepository>();
    late FlutterSecureStorageSpy preferences;

    sut.givenRepository((client) {
      preferences = FlutterSecureStorageSpy(delay: Duration.zero);
      return ActionPlanRepository(client, preferences);
    });

    group('generate', () {
      const answers = OnboardingQuestionnaireAnswers(
        situation: QuestionnaireSituation.lycee,
        objectifs: {QuestionnaireObjectif.alternance},
        domaine: 'mécanique',
      );

      sut.when((repository) => repository.generate('userId', answers));

      group('when response is valid', () {
        sut.givenJsonResponse(fromJson: 'action_plan.json');

        test('request should be valid', () async {
          await sut.expectRequestBody(
            method: HttpMethod.post,
            url: '/jeunes/userId/plan-action',
            rawBody: {
              'situation': 'LYCEE',
              'goals': ['ALTERNANCE'],
              'domaine': 'mécanique',
              'obstacles': <String>[],
            },
          );
        });

        test('response should be valid and persisted', () async {
          await sut.expectResult<ActionPlan?>((result) {
            expect(result, isNotNull);
            expect(result!.id, '0b7956f3-0064-4070-906e-53f47845506d');
            expect(result.greeting, "Voici ton plan d'action, coche les actions au fur et à mesure.");
            expect(result.generator, 'fallback');
            expect(result.objectives, hasLength(1));
            expect(result.objectives.first.title, 'Trouver une alternance');
            expect(result.objectives.first.theme, 'apprenticeship');
            expect(result.objectives.first.actions, [
              const ActionPlanAction(
                id: 'p-134',
                label: "Je me renseigne sur l'alternance",
                kind: ActionPlanActionKind.link,
                url: 'https://labonnealternance.apprentissage.beta.gouv.fr/guide-alternant',
                serviceName: 'La Bonne Alternance',
                serviceDescription: "Faciliter la recherche d'alternance pour les jeunes",
              ),
              const ActionPlanAction(
                id: 'c-alternance-1',
                label: "Je consulte les offres d'alternance",
                kind: ActionPlanActionKind.app,
                deepLink: 'OFFRES_ALTERNANCE',
              ),
              const ActionPlanAction(
                id: 'p-139',
                label: "J'envoie une candidature spontanée à une entreprise",
                kind: ActionPlanActionKind.advice,
              ),
            ]);
          });

          final storedRaw = await preferences.read(key: 'actionPlan');
          expect(storedRaw, isNotNull);
          final stored = ActionPlan.fromJson(jsonDecode(storedRaw!) as Map<String, dynamic>);
          expect(stored.id, '0b7956f3-0064-4070-906e-53f47845506d');
          expect(stored.objectives.first.actions, hasLength(3));
        });
      });

      group('when response is invalid', () {
        sut.givenResponseCode(500);

        test('response should be null', () async {
          await sut.expectNullResult();
        });
      });
    });
  });
}
