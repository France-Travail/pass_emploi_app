import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_filtres_recherche.dart';
import 'package:pass_emploi_app/models/immersion.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/models/metier.dart';
import 'package:pass_emploi_app/models/recherche/recherche_repository.dart';
import 'package:pass_emploi_app/models/recherche/recherche_request.dart';
import 'package:pass_emploi_app/repositories/immersion/immersion_repository.dart';

import '../../dsl/sut_dio_repository.dart';

void main() {
  group('ImmersionRepository', () {
    final sut = DioRepositorySut<ImmersionRepository>();
    sut.givenRepository((client) => ImmersionRepository(client));

    group('rechercher', () {
      sut.when((repository) => repository.rechercher(userId: "ID", request: _requestWithoutFiltres2()));

      group('when response is valid', () {
        sut.givenJsonResponse(fromJson: "immersions.json");

        test('request should be valid', () {
          sut.expectRequestBody(
            method: HttpMethod.get,
            url: "/offres-immersion/v3",
            queryParameters: {'rome': 'J1301', 'lat': 48.7, 'lon': 7.7, 'page': 1, 'limit': 50},
          );
        });

        test('result should be valid', () {
          sut.expectResult<RechercheResponse<Immersion>?>((response) {
            expect(response, isNotNull);
            expect(response!.results.length, 13);
            expect(
              response.results.first,
              Immersion(
                id: Immersion.buildSyntheticId(
                  siret: "12345678900001",
                  appellationCode: "11573",
                  locationId: "loc-001",
                ),
                siret: "12345678900001",
                appellationCode: "11573",
                locationId: "loc-001",
                metier: "xxxx",
                nomEtablissement: "ACCUEIL DE JOUR POUR PERSONNES AGEES",
                secteurActivite: "xxxx",
                ville: "xxxx",
                accessibleTravailleurHandicape: AccessibleTravailleurHandicape.yesFtCertified,
              ),
            );
          });
        });
      });

      group('when response is invalid', () {
        sut.givenResponseCode(500);

        test('result should be null', () {
          sut.expectNullResult();
        });
      });

      group('when response throws exception', () {
        sut.givenThrowingExceptionResponse();

        test('result should be null', () {
          sut.expectNullResult();
        });
      });
    });

    group('rechercher when filtres are applied', () {
      sut.givenJsonResponse(fromJson: "immersions.json");

      group('when distance is 70', () {
        sut.when(
          (repository) => repository.rechercher(
            userId: "ID",
            request: _requestWithFiltres2(ImmersionFiltresRecherche.distance(70)),
          ),
        );
        test('query parameters should be properly built', () {
          sut.expectRequestBody(
            method: HttpMethod.get,
            url: "/offres-immersion/v3",
            queryParameters: {'rome': 'J1301', 'lon': 7.7, 'lat': 48.7, 'distance': 70, 'page': 1, 'limit': 50},
          );
        });
      });

      group('when no distance is set', () {
        sut.when(
          (repository) => repository.rechercher(
            userId: "ID",
            request: _requestWithFiltres2(ImmersionFiltresRecherche.noFiltre()),
          ),
        );
        test('query parameters should be properly built', () {
          sut.expectRequestBody(
            method: HttpMethod.get,
            url: "/offres-immersion/v3",
            queryParameters: {'rome': 'J1301', 'lon': 7.7, 'lat': 48.7, 'page': 1, 'limit': 50},
          );
        });
      });

      group('when appellationCode is provided alongside metier', () {
        sut.when(
          (repository) => repository.rechercher(
            userId: "ID",
            request: RechercheRequest(
              ImmersionCriteresRecherche(
                metier: Metier(codeRome: "J1301", libelle: "xxxx"),
                appellationCode: "11573",
                location: Location(
                  libelle: "Paris",
                  code: "75",
                  type: LocationType.COMMUNE,
                  latitude: 48.7,
                  longitude: 7.7,
                ),
              ),
              ImmersionFiltresRecherche.noFiltre(),
              1,
            ),
          ),
        );
        test('query parameters should include appellationCode and codeRome', () {
          sut.expectRequestBody(
            method: HttpMethod.get,
            url: "/offres-immersion/v3",
            queryParameters: {
              'appellationCode': '11573',
              'rome': 'J1301',
              'lon': 7.7,
              'lat': 48.7,
              'page': 1,
              'limit': 50,
            },
          );
        });
      });
    });
  });
}

RechercheRequest<ImmersionCriteresRecherche, ImmersionFiltresRecherche> _requestWithFiltres2(
  ImmersionFiltresRecherche filtres,
) {
  return RechercheRequest(
    ImmersionCriteresRecherche(
      metier: Metier(codeRome: "J1301", libelle: "xxxx"),
      location: Location(
        libelle: "Paris",
        code: "75",
        type: LocationType.COMMUNE,
        latitude: 48.7,
        longitude: 7.7,
      ),
    ),
    filtres,
    1,
  );
}

RechercheRequest<ImmersionCriteresRecherche, ImmersionFiltresRecherche> _requestWithoutFiltres2() {
  return _requestWithFiltres2(ImmersionFiltresRecherche.noFiltre());
}
