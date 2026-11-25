import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';
import 'package:pass_emploi_app/repositories/structures_accompagnement_repository.dart';

import '../dsl/sut_dio_repository.dart';

void main() {
  group('StructuresAccompagnementRepository', () {
    final sut = DioRepositorySut<StructuresAccompagnementRepository>();
    sut.givenRepository((client) => StructuresAccompagnementRepository(client));

    group('get', () {
      sut.when(
        (repository) => repository.get(
          type: StructureAccompagnementType.franceTravail,
          codeInsee: '31555',
          codePostal: '31400',
        ),
      );

      group('when response is valid', () {
        sut.givenJsonResponse(fromJson: 'structures_accompagnement_france_travail.json');

        test('request should send only type, code INSEE and code postal', () async {
          await sut.expectRequestBody(
            method: HttpMethod.get,
            url: '/referentiels/structures-accompagnement',
            queryParameters: {'type': 'FRANCE_TRAVAIL', 'codeInsee': '31555', 'codePostal': '31400'},
          );
        });

        test('response should be parsed, missing fields included', () async {
          await sut.expectResult<List<StructureAccompagnement>?>((result) {
            expect(result, [
              StructureAccompagnement(
                nom: 'Agence France Travail TOULOUSE ST-MICHEL',
                adresse: StructureAccompagnementAdresse(
                  ligne: "2 AVENUE DE L'URSS",
                  codePostal: '31400',
                  ville: 'TOULOUSE',
                ),
                telephone: '39-49',
                horaires: [
                  'Lun–mer · 8h30 – 12h30, 12h30 – 16h30 sur RDV',
                  'Jeu · 8h30 – 12h30',
                  'Ven · 8h30 – 12h30, 12h30 – 15h30 sur RDV',
                ],
                horairesAlt: 'Lundi à mercredi ouvert de 8h30 à 12h30 en accès libre et de 12h30 à 16h30 sur rendez-vous, jeudi ouvert de 8h30 à 12h30, et vendredi ouvert de 8h30 à 12h30 en accès libre et de 12h30 à 15h30 sur rendez-vous.',
              ),
              StructureAccompagnement(
                nom: 'Agence France Travail sans coordonnées',
                adresse: StructureAccompagnementAdresse(),
              ),
            ]);
          });
        });
      });

      group('when response is invalid', () {
        sut.givenResponseCode(502);

        test('response should be null', () async {
          await sut.expectNullResult();
        });
      });

      group('when an exception is thrown', () {
        sut.givenThrowingExceptionResponse();

        test('response should be null', () async {
          await sut.expectNullResult();
        });
      });
    });
  });
}
