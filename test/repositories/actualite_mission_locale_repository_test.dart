import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/actualite_mission_locale.dart';
import 'package:pass_emploi_app/repositories/actualite_mission_locale_repository.dart';

import '../dsl/sut_dio_repository.dart';

void main() {
  group('ActualiteMissionLocaleRepository', () {
    final sut = DioRepositorySut<ActualiteMissionLocaleRepository>();
    sut.givenRepository((client) => ActualiteMissionLocaleRepository(client));

    group('get', () {
      sut.when((repository) => repository.get('idJeune'));

      group('when response is valid', () {
        sut.givenResponse(
          () => Response(
            requestOptions: RequestOptions(path: "sut-path"),
            statusCode: 200,
            data: {
              "actualites": [
                {
                  "titre": "Actualite 1",
                  "contenu": "Contenu 1",
                  "titreLien": "Lien 1",
                  "lien": "https://example.org/1",
                  "nomPrenomConseiller": "Conseiller 1",
                  "dateCreation": "2026-02-01T10:00:00Z",
                },
                {
                  "titre": "Actualite 2",
                  "contenu": "Contenu 2",
                  "nomPrenomConseiller": "Conseiller 2",
                  "dateCreation": "2026-02-02T10:00:00Z",
                  "dateSuppression": "2026-02-03T10:00:00Z",
                },
              ],
            },
          ),
        );

        test('request should be valid', () async {
          await sut.expectRequestBody(
            method: HttpMethod.get,
            url: "/jeunes/milo/idJeune/actualites",
          );
        });

        test('response should be valid', () async {
          await sut.expectResult<List<ActualiteMissionLocale>>((result) {
            expect(result, hasLength(2));
            expect(result[0].titre, 'Actualite 1');
            expect(result[0].contenu, 'Contenu 1');
            expect(result[0].titreLien, 'Lien 1');
            expect(result[0].lien, 'https://example.org/1');
            expect(result[0].nomPrenomConseiller, 'Conseiller 1');
            expect(result[0].isSupprime, false);

            expect(result[1].titreLien, null);
            expect(result[1].lien, null);
            expect(result[1].isSupprime, true);
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
