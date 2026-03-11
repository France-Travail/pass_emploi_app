import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/repositories/auto_desinscription_repository.dart';

import '../dsl/sut_dio_repository.dart';

void main() {
  group('AutoDesinscriptionRepository', () {
    final sut = DioRepositorySut<AutoDesinscriptionRepository>();
    sut.givenRepository((client) => AutoDesinscriptionRepository(client));

    group('desinscrire', () {
      sut.when((repository) => repository.desinscrire("userId", "eventId", "motif"));

      group('when response is valid', () {
        sut.givenResponseCode(200);

        test('request should be valid', () async {
          await sut.expectRequestBody(
            method: HttpMethod.post,
            url: "/jeunes/milo/userId/sessions/eventId/desinscrire",
            rawBody: {"motif": "motif"},
          );
        });

        test('response should be true', () async {
          await sut.expectResult<bool?>((result) {
            expect(result, true);
          });
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
