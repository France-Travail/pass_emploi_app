import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/accueil/message_informatif.dart';
import 'package:pass_emploi_app/models/communications.dart';

void main() {
  group('Communications.fromJson', () {
    test('should parse messageInformatif when present', () {
      final communications = Communications.fromJson({
        "messageInformatif": {
          "id": "migration-parcours-emploi-2026",
          "titre": "Votre application évolue",
          "contenu": "Le 15 octobre 2026, l’application pass emploi ne sera plus disponible.",
          "cta": {
            "label": "Télécharger l’application",
            "urlAndroid": "https://play.google.com/android",
            "urlIos": "https://apps.apple.com/ios",
          },
        },
      });

      expect(
        communications.messageInformatif,
        MessageInformatif(
          id: "migration-parcours-emploi-2026",
          titre: "Votre application évolue",
          contenu: "Le 15 octobre 2026, l’application pass emploi ne sera plus disponible.",
          cta: MessageInformatifCta(
            label: "Télécharger l’application",
            urlAndroid: "https://play.google.com/android",
            urlIos: "https://apps.apple.com/ios",
          ),
        ),
      );
    });

    test('should parse a response without messageInformatif', () {
      expect(Communications.fromJson({}).messageInformatif, isNull);
      expect(Communications.fromJson({"messageInformatif": null}).messageInformatif, isNull);
    });
  });
}
