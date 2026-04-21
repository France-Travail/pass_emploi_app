import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/immersion.dart';
import 'package:pass_emploi_app/models/immersion_contact.dart';
import 'package:pass_emploi_app/models/immersion_details.dart';
import 'package:pass_emploi_app/repositories/immersion/immersion_details_repository.dart';
import 'package:pass_emploi_app/repositories/offre_emploi/offre_emploi_details_repository.dart';

import '../../dsl/sut_dio_repository.dart';

void main() {
  final sut = DioRepositorySut<ImmersionDetailsRepository>();
  sut.givenRepository((client) => ImmersionDetailsRepository(client));

  group('fetch', () {
    final withoutContactId = Immersion.buildSyntheticId(
      siret: '12345678901234',
      appellationCode: '11573',
      locationId: 'loc-without-contact',
    );
    final withContactId = Immersion.buildSyntheticId(
      siret: '12345678901234',
      appellationCode: '11573',
      locationId: 'loc-with-contact',
    );

    group('when response is valid without contact', () {
      sut.when((repository) => repository.fetch(withoutContactId));
      sut.givenJsonResponse(fromJson: "immersion_details_without_contact.json");

      test('request should be valid', () async {
        await sut.expectRequestBody(
          method: HttpMethod.get,
          url: '/offres-immersion/v3/12345678901234/11573/loc-without-contact',
        );
      });

      test('response should be valid', () async {
        await sut.expectResult<OffreDetailsResponse<ImmersionDetails>>((result) {
          expect(result.isGenericFailure, isFalse);
          expect(result.isOffreNotFound, isFalse);
          expect(
            result.details,
            ImmersionDetails(
              id: withoutContactId,
              siret: "12345678901234",
              appellationCode: "11573",
              locationId: "loc-without-contact",
              metier: "xxxx",
              companyName: "CTRE SOINS SUITE ET READAPTAT EN ADDICTO",
              secteurActivite: "xxxx",
              ville: "xxxx",
              address: "Service des ressources humaines, 40 RUE DU DEPUTE HALLEZ, 67500 HAGUENAU",
              informationComplementaire: "Information complémentaire",
              website: "",
              fitForDisabledWorkers: false,
              contactMode: ImmersionContactMode.INCONNU,
            ),
          );
        });
      });
    });

    group('when response is valid with contact', () {
      sut.when((repository) => repository.fetch(withContactId));
      sut.givenJsonResponse(fromJson: "immersion_details_with_contact.json");

      test('request should be valid', () async {
        await sut.expectRequestBody(
          method: HttpMethod.get,
          url: '/offres-immersion/v3/12345678901234/11573/loc-with-contact',
        );
      });

      test('response should be valid', () async {
        await sut.expectResult<OffreDetailsResponse<ImmersionDetails>>((result) {
          expect(result.isGenericFailure, isFalse);
          expect(result.isOffreNotFound, isFalse);
          expect(
            result.details,
            ImmersionDetails(
              id: withContactId,
              siret: "12345678901234",
              appellationCode: "11573",
              locationId: "loc-with-contact",
              metier: "xxxx",
              companyName: "GSF SATURNE",
              secteurActivite: "xxxx",
              ville: "xxxx",
              address: "4 RUE DES FRERES LUMIERE 67170 BRUMATH",
              informationComplementaire: "Information complémentaire",
              website: "https://gsf-saturne.example.com",
              fitForDisabledWorkers: true,
              contactMode: ImmersionContactMode.MAIL,
            ),
          );
        });
      });
    });

    group('when response is 404', () {
      sut.when((repository) => repository.fetch(withoutContactId));
      sut.givenResponseCode(HttpStatus.notFound);

      test('response should be flagged as not found', () async {
        await sut.expectResult<OffreDetailsResponse<ImmersionDetails>>((result) {
          expect(result.isGenericFailure, isFalse);
          expect(result.isOffreNotFound, isTrue);
        });
      });
    });

    group('when response throws exception', () {
      sut.when((repository) => repository.fetch(withoutContactId));
      sut.givenThrowingExceptionResponse();

      test('response should be generic failure', () async {
        await sut.expectResult<OffreDetailsResponse<ImmersionDetails>>((result) {
          expect(result.isGenericFailure, isTrue);
          expect(result.isOffreNotFound, isFalse);
        });
      });
    });
  });
}
