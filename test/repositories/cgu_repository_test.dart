import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/repositories/cgu/cgu_repository.dart';

import '../dsl/sut_dio_repository.dart';
import '../utils/test_datetime.dart';

Response<dynamic> _json(dynamic data) =>
    Response(requestOptions: RequestOptions(path: "sut-path"), data: data, statusCode: 200);

void main() {
  final sut = DioRepositorySut<CguRepository>();
  sut.givenRepository((client) => CguRepository(client));

  for (final isInvite in [false, true]) {
    final label = isInvite ? "invite" : "non invite";
    final getUrl = isInvite ? "/jeunes/id-jeune/invite/cgu" : "/jeunes/id-jeune/cgu";

    group("get ($label)", () {
      sut.when((repository) => repository.get("id-jeune", isInvite: isInvite));

      group('when CGU were signed', () {
        sut.givenResponse(() => _json({"dateSignatureCGU": "2024-01-01T18:00:00.000Z"}));

        test('request should be valid', () async {
          await sut.expectRequestBody(method: HttpMethod.get, url: getUrl);
        });

        test('response should hold the signature date', () async {
          await sut.expectResult<CguSignature?>((result) {
            expect(result?.date, parseDateTimeUtcWithCurrentTimeZone('2024-01-01T18:00:00.000Z'));
          });
        });
      });

      group('when CGU were never signed', () {
        sut.givenResponse(() => _json(<String, dynamic>{}));

        test('response should hold no date', () async {
          await sut.expectResult<CguSignature?>((result) {
            expect(result, isNotNull);
            expect(result?.date, isNull);
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

    group("save ($label)", () {
      sut.when((repository) => repository.save("id-jeune", DateTime.utc(2024, 1, 1), isInvite: isInvite));

      group('when response is valid', () {
        sut.givenResponseCode(201);

        test('request should be valid', () async {
          await sut.expectRequestBody(
            method: isInvite ? HttpMethod.put : HttpMethod.patch,
            url: isInvite ? "/jeunes/id-jeune/invite/cgu" : "/jeunes/id-jeune",
            jsonBody: {"dateSignatureCGU": '2024-01-01T00:00:00+00:00'},
          );
        });

        test('response should be true', () async {
          await sut.expectTrueAsResult();
        });
      });

      group('when response is invalid', () {
        sut.givenResponseCode(500);

        test('response should be false', () async {
          await sut.expectFalseAsResult();
        });
      });
    });
  }

  group("deleteInvite", () {
    sut.when((repository) => repository.deleteInvite("id-jeune"));

    group('when response is valid', () {
      sut.givenResponseCode(204);

      test('request should be valid', () async {
        await sut.expectRequestBody(method: HttpMethod.delete, url: "/jeunes/id-jeune/invite");
      });

      test('response should be true', () async {
        await sut.expectTrueAsResult();
      });
    });

    group('when response is invalid', () {
      sut.givenResponseCode(500);

      test('response should be false', () async {
        await sut.expectFalseAsResult();
      });
    });
  });
}
