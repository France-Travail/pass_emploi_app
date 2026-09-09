import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/accueil/message_informatif.dart';

void main() {
  group('MessageInformatif.fromJson', () {
    test('should return null when json is null', () {
      expect(MessageInformatif.fromJson(null), isNull);
    });

    test('should parse a message with a cta (migration vers une autre app)', () {
      final message = MessageInformatif.fromJson({
        "id": "migration-parcours-emploi",
        "titre": "Votre application évolue",
        "contenu": "Le 15 octobre 2026, l’application pass emploi ne sera plus disponible.",
        "cta": {
          "label": "Télécharger l’application",
          "urlAndroid": "https://play.google.com/android",
          "urlIos": "https://apps.apple.com/ios",
        },
      });

      expect(
        message,
        MessageInformatif(
          id: "migration-parcours-emploi",
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

    test('should parse a message without cta (rebranding)', () {
      final message = MessageInformatif.fromJson({
        "id": "rebranding-app-jeune",
        "titre": "L’application change bientôt de nom",
        "contenu": "Votre application change de nom le 15 octobre 2026 et devient Parcours Emploi.",
        "cta": null,
      });

      expect(message, isNotNull);
      expect(message!.cta, isNull);
    });
  });

  group('MessageInformatifCta.url', () {
    final cta = MessageInformatifCta(label: "label", urlAndroid: "android", urlIos: "ios");

    test('should return the android url on android', () {
      expect(cta.url(isAndroid: true), "android");
    });

    test('should return the ios url on ios', () {
      expect(cta.url(isAndroid: false), "ios");
    });
  });
}
