import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_repository.dart';

import '../../doubles/dio_mock.dart';
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
            expect(
              result.greeting,
              "Voici ton plan d'action, coche les actions au fur et à mesure.",
            );
            expect(result.generator, 'fallback');
            expect(result.objectives, hasLength(1));
            expect(result.objectives.first.title, 'Trouver une alternance');
            expect(result.objectives.first.theme, 'apprenticeship');
            expect(result.objectives.first.actions, [
              const ActionPlanAction(
                id: 'p-134',
                label: "Je me renseigne sur l'alternance",
                kind: ActionPlanActionKind.link,
                url:
                    'https://labonnealternance.apprentissage.beta.gouv.fr/guide-alternant',
                serviceName: 'La Bonne Alternance',
                serviceDescription:
                    "Faciliter la recherche d'alternance pour les jeunes",
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
          final stored = ActionPlan.fromJson(
            jsonDecode(storedRaw!) as Map<String, dynamic>,
          );
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

  group('ActionPlanRepository progress across generations', () {
    const answers = OnboardingQuestionnaireAnswers(
      situation: QuestionnaireSituation.lycee,
      objectifs: {QuestionnaireObjectif.alternance},
    );

    late DioMock client;
    late FlutterSecureStorageSpy preferences;
    late ActionPlanRepository repository;

    setUp(() {
      client = DioMock();
      preferences = FlutterSecureStorageSpy(delay: Duration.zero);
      repository = ActionPlanRepository(client, preferences);
    });

    test(
      'keeps checked actions when the same objective is generated again',
      () async {
        await _stubGenerate(client, _plan(objectives: [_objectiveX()]));
        await repository.generate('userId', answers);
        await repository.toggleDone('a');
        await repository.toggleDone('b');

        await _stubGenerate(
          client,
          _plan(
            objectives: [
              _objectiveX(actions: [_actionA, _actionB, _actionE]),
            ],
          ),
        );
        final next = await repository.generate('userId', answers);

        expect(next!.findAction('a')?.done, isTrue);
        expect(next.findAction('b')?.done, isTrue);
        expect(next.findAction('e')?.done, isFalse);
      },
    );

    test(
      'hides deleted actions when the same objective is generated again',
      () async {
        await _stubGenerate(client, _plan(objectives: [_objectiveY()]));
        await repository.generate('userId', answers);
        await repository.deleteAction('c');
        await repository.deleteAction('d');

        await _stubGenerate(client, _plan(objectives: [_objectiveY()]));
        final next = await repository.generate('userId', answers);

        expect(next!.findAction('c'), isNull);
        expect(next.findAction('d'), isNull);
        expect(next.findAction('e')?.done, isFalse);
        expect(next.objectives, hasLength(1));
      },
    );

    test(
      'resets deleted and checked actions after an objective is dropped then selected again',
      () async {
        await _stubGenerate(
          client,
          _plan(objectives: [_objectiveX(), _objectiveY()]),
        );
        await repository.generate('userId', answers);
        await repository.toggleDone('a');
        await repository.deleteAction('c');
        await repository.deleteAction('d');

        await _stubGenerate(client, _plan(objectives: [_objectiveX()]));
        final withoutY = await repository.generate('userId', answers);
        expect(withoutY!.findAction('a')?.done, isTrue);
        expect(withoutY.findAction('c'), isNull);
        expect(withoutY.objectives.map((objective) => objective.id), [
          'objective-x',
        ]);

        await _stubGenerate(
          client,
          _plan(objectives: [_objectiveX(), _objectiveY()]),
        );
        final withYAgain = await repository.generate('userId', answers);

        expect(withYAgain!.findAction('a')?.done, isTrue);
        expect(withYAgain.findAction('c')?.done, isFalse);
        expect(withYAgain.findAction('d')?.done, isFalse);
        expect(withYAgain.findAction('e')?.done, isFalse);
      },
    );
  });
}

const _actionA = ActionPlanAction(
  id: 'a',
  label: 'A',
  kind: ActionPlanActionKind.advice,
);
const _actionB = ActionPlanAction(
  id: 'b',
  label: 'B',
  kind: ActionPlanActionKind.advice,
);
const _actionC = ActionPlanAction(
  id: 'c',
  label: 'C',
  kind: ActionPlanActionKind.advice,
);
const _actionD = ActionPlanAction(
  id: 'd',
  label: 'D',
  kind: ActionPlanActionKind.advice,
);
const _actionE = ActionPlanAction(
  id: 'e',
  label: 'E',
  kind: ActionPlanActionKind.advice,
);

ActionPlanObjective _objectiveX({List<ActionPlanAction>? actions}) {
  return ActionPlanObjective(
    id: 'objective-x',
    title: 'X',
    theme: 'x',
    actions: actions ?? const [_actionA, _actionB],
  );
}

ActionPlanObjective _objectiveY() {
  return const ActionPlanObjective(
    id: 'objective-y',
    title: 'Y',
    theme: 'y',
    actions: [_actionC, _actionD, _actionE],
  );
}

ActionPlan _plan({required List<ActionPlanObjective> objectives}) {
  return ActionPlan(id: 'plan', greeting: 'Salut', objectives: objectives);
}

Future<void> _stubGenerate(DioMock client, ActionPlan plan) async {
  when(() => client.post(any(), data: any(named: 'data'))).thenAnswer(
    (_) async => Response<dynamic>(
      requestOptions: RequestOptions(path: '/jeunes/userId/plan-action'),
      statusCode: 200,
      data: _toApiJson(plan),
    ),
  );
}

Map<String, dynamic> _toApiJson(ActionPlan plan) {
  return {
    'id': plan.id,
    'accroche': plan.greeting,
    'objectives': [
      for (final objective in plan.objectives)
        {
          'id': objective.id,
          'titre': objective.title,
          'theme': objective.theme,
          'actions': [
            for (final action in objective.actions)
              {
                'id': action.id,
                'libelle': action.label,
                'type': switch (action.kind) {
                  ActionPlanActionKind.link => 'LIEN',
                  ActionPlanActionKind.app => 'NAVIGATION',
                  ActionPlanActionKind.advice => 'CONSEIL',
                },
              },
          ],
        },
    ],
  };
}
