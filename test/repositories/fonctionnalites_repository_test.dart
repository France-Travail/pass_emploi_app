import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/fonctionnalite.dart';
import 'package:pass_emploi_app/repositories/fonctionnalites_repository.dart';

import '../dsl/sut_dio_repository.dart';

void main() {
  group('FonctionnalitesRepository', () {
    final sut = DioRepositorySut<FonctionnalitesRepository>();
    sut.givenRepository((client) => FonctionnalitesRepository(client));

    group('get fonctionnalites', () {
      sut.when((repository) => repository.get("userId"));

      group('when response is valid', () {
        sut.givenJsonResponse(fromJson: "fonctionnalites.json");

        test('request should be valid', () async {
          await sut.expectRequestBody(method: HttpMethod.get, url: "/jeunes/userId/fonctionnalites");
        });

        test('response should be valid', () async {
          await sut.expectResult<Set<Fonctionnalite>?>((result) {
            expect(result, {Fonctionnalite.planAction});
          });
        });
      });

      group('when response contains an unknown fonctionnalite', () {
        _givenBody(sut, {
          'fonctionnalites': ['PLAN_ACTION', 'FONCTIONNALITE_DU_FUTUR'],
        });

        test('unknown value should be silently ignored', () async {
          await sut.expectResult<Set<Fonctionnalite>?>((result) {
            expect(result, {Fonctionnalite.planAction});
          });
        });
      });

      group('when response contains only unknown fonctionnalites', () {
        _givenBody(sut, {
          'fonctionnalites': ['FONCTIONNALITE_DU_FUTUR'],
        });

        test('result should be empty but not null', () async {
          await sut.expectResult<Set<Fonctionnalite>?>((result) {
            expect(result, isEmpty);
          });
        });
      });

      group('when response contains an empty list', () {
        _givenBody(sut, {'fonctionnalites': <dynamic>[]});

        test('result should be empty but not null', () async {
          await sut.expectResult<Set<Fonctionnalite>?>((result) {
            expect(result, isEmpty);
          });
        });
      });

      group('when fonctionnalites field is missing', () {
        _givenBody(sut, {'autreChose': true});

        test('response should be null', () async {
          await sut.expectNullResult();
        });
      });

      group('when body is not a json object', () {
        sut.givenRawResponse(data: "not a json object");

        test('response should be null', () async {
          await sut.expectNullResult();
        });
      });

      group('when response code is invalid', () {
        sut.givenResponseCode(500);

        test('response should be null', () async {
          await sut.expectNullResult();
        });
      });

      group('when response code is 404', () {
        sut.givenResponseCode(404);

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

void _givenBody(DioRepositorySut<FonctionnalitesRepository> sut, Map<String, dynamic> body) {
  sut.givenResponse(
    () => Response(
      requestOptions: RequestOptions(path: "sut-path"),
      data: body,
      statusCode: 200,
    ),
  );
}
