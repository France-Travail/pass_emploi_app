import 'package:flutter_test/flutter_test.dart';
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
        final plan = {
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

        sut.when(
          (repository) => repository.reprendre(
            idInvite: 'id-invite',
            jetonConnecte: 'jeton-connecte',
            plan: plan,
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
                "plan": plan,
              },
            );
          });

          test('response should be true', () async {
            await sut.expectTrueAsResult();
          });
        });
      });
    });
  });
}
