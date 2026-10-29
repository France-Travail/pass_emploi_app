import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/repositories/reprise_compte_invite_repository.dart';

import '../dsl/sut_dio_repository.dart';

void main() {
  group('RepriseCompteInviteRepository', () {
    final sut = DioRepositorySut<RepriseCompteInviteRepository>();
    sut.givenRepository((client) => RepriseCompteInviteRepository(client));

    group('reprendre', () {
      group('without plan', () {
        sut.when(
          (repository) => repository.reprendre(idInvite: 'id-invite', jetonConnecte: 'jeton-connecte'),
        );

        group('when response is valid', () {
          sut.givenResponseCode(204);

          test('request should be valid', () async {
            await sut.expectRequestBody(
              method: HttpMethod.post,
              url: "/jeunes/id-invite/reprise-invite",
              rawBody: {"jetonConnecte": "jeton-connecte"},
            );
          });

          test('response should be true', () async {
            await sut.expectTrueAsResult();
          });
        });

        group('when response is invalid', () {
          sut.givenResponseCode(400);

          test('response should be false', () async {
            await sut.expectFalseAsResult();
          });
        });

        group('when an exception is thrown', () {
          sut.givenThrowingExceptionResponse();

          test('response should be false', () async {
            await sut.expectFalseAsResult();
          });
        });
      });

      group('with plan', () {
        sut.when(
          (repository) => repository.reprendre(
            idInvite: 'id-invite',
            jetonConnecte: 'jeton-connecte',
            plan: _plan,
          ),
        );

        group('when response is valid', () {
          sut.givenResponseCode(204);

          test('request should include plan', () async {
            await sut.expectRequestBody(
              method: HttpMethod.post,
              url: "/jeunes/id-invite/reprise-invite",
              rawBody: {
                "jetonConnecte": "jeton-connecte",
                "plan": _plan,
              },
            );
          });

          test('response should be true', () async {
            await sut.expectTrueAsResult();
          });
        });
      });

      group('with plan and questionnaire', () {
        sut.when(
          (repository) => repository.reprendre(
            idInvite: 'id-invite',
            jetonConnecte: 'jeton-connecte',
            plan: _plan,
            questionnaire: OnboardingQuestionnaireAnswers(
              prenom: 'Malik',
              dateNaissance: DateTime(2005, 3, 14),
              habitation: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
              situation: QuestionnaireSituation.emploi,
              objectifs: {QuestionnaireObjectif.emploi},
              domaine: 'Informatique',
              villeRecherche: const QuestionnaireCommune(code: '69123', nom: 'Lyon'),
              rayonKm: 10,
              freins: {QuestionnaireFrein.pasDePermis},
            ),
          ),
        );

        sut.givenResponseCode(204);

        test('request should include plan and questionnaire', () async {
          await sut.expectRequestBody(
            method: HttpMethod.post,
            url: "/jeunes/id-invite/reprise-invite",
            rawBody: {
              "jetonConnecte": "jeton-connecte",
              "plan": _plan,
              "questionnaire": {
                "dateNaissance": "2005-03-14",
                "situation": "EMPLOI",
                "goals": ["EMPLOI"],
                "domaine": "Informatique",
                "domaineInconnu": false,
                "habitation": {"codeInsee": "75056", "nom": "Paris"},
                "villeRecherche": {"codeInsee": "69123", "nom": "Lyon"},
                "rayonKm": 10,
                "obstacles": ["PAS_DE_PERMIS"],
              },
            },
          );
        });
      });

      group('with questionnaire but without plan', () {
        sut.when(
          (repository) => repository.reprendre(
            idInvite: 'id-invite',
            jetonConnecte: 'jeton-connecte',
            questionnaire: const OnboardingQuestionnaireAnswers(
              situation: QuestionnaireSituation.emploi,
              objectifs: {QuestionnaireObjectif.emploi},
            ),
          ),
        );

        sut.givenResponseCode(204);

        test('request should not include questionnaire, only taken into account with a plan', () async {
          await sut.expectRequestBody(
            method: HttpMethod.post,
            url: "/jeunes/id-invite/reprise-invite",
            rawBody: {"jetonConnecte": "jeton-connecte"},
          );
        });
      });

      group('with plan and a questionnaire unable to generate a plan', () {
        sut.when(
          (repository) => repository.reprendre(
            idInvite: 'id-invite',
            jetonConnecte: 'jeton-connecte',
            plan: _plan,
            questionnaire: const OnboardingQuestionnaireAnswers(situation: QuestionnaireSituation.emploi),
          ),
        );

        sut.givenResponseCode(204);

        test('request should not include questionnaire, rejected by the API', () async {
          await sut.expectRequestBody(
            method: HttpMethod.post,
            url: "/jeunes/id-invite/reprise-invite",
            rawBody: {
              "jetonConnecte": "jeton-connecte",
              "plan": _plan,
            },
          );
        });
      });
    });
  });
}

final _plan = {
  'id': 'plan-1',
  'objectives': [
    {
      'id': 'objective-1',
      'titre': 'Trouver un emploi',
      'theme': 'emploi',
      'actions': [
        {'id': 'action-1', 'idSolution': 'solution-123', 'terminee': true},
      ],
    },
  ],
};
