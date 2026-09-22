import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/accueil/message_informatif.dart';
import 'package:pass_emploi_app/models/communications.dart';
import 'package:pass_emploi_app/repositories/communications_repository.dart';

import '../dsl/sut_dio_repository.dart';

void main() {
  const String userId = "userId";
  group('CommunicationsRepository', () {
    final sut = DioRepositorySut<CommunicationsRepository>();
    sut.givenRepository((client) => CommunicationsRepository(client));

    group('get', () {
      sut.when((repository) => repository.get(userId));

      group('when response is valid', () {
        sut.givenJsonResponse(fromJson: "communications.json");

        test('request should be valid', () async {
          await sut.expectRequestBody(
            method: HttpMethod.get,
            url: "/jeunes/userId/communications",
          );
        });

        test('response should be valid', () async {
          await sut.expectResult<Communications?>((result) {
            expect(
              result,
              Communications(
                messageInformatif: MessageInformatif(
                  id: 1,
                  titre: "Votre application évolue",
                  contenu:
                      "Le 15 octobre 2026, l’application pass emploi ne sera plus disponible. Vos services seront accessibles sur l’application Parcours Emploi.",
                  cta: MessageInformatifCta(
                    label: "Télécharger l’application",
                    urlAndroid: "https://play.google.com/store/apps/details?id=com.poleemploi.pemobile&referrer=...",
                    urlIos: "https://apps.apple.com/app/apple-store/id563863597?pt=...",
                  ),
                ),
              ),
            );
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
