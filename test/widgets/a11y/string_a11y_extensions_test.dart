import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';

void main() {
  group('toTimeAndDurationForScreenReaders', () {
    test('should replace : character', () {
      expect("17:30".toTimeAndDurationForScreenReaders(), "17 heures 30");
    });

    test('should replace h character', () {
      expect("1h30".toTimeAndDurationForScreenReaders(), "1 heures 30");
    });

    test('should replace min string', () {
      expect("30min".toTimeAndDurationForScreenReaders(), "30 minutes ");
    });

    test('should remove minutes when 00', () {
      expect("17:00".toTimeAndDurationForScreenReaders(), "17 heures ");
    });

    test('should add duration prefix', () {
      expect("(1h)".toTimeAndDurationForScreenReaders(), "(durée : 1 heures )");
    });
  });

  group('toFullDayForScreenReaders', () {
    test('should replace lun.', () {
      expect("lun.".toFullDayForScreenReaders(), "lundi");
    });

    test('should replace mar.', () {
      expect("mar.".toFullDayForScreenReaders(), "mardi");
    });

    test('should replace mer.', () {
      expect("mer.".toFullDayForScreenReaders(), "mercredi");
    });

    test('should replace jeu.', () {
      expect("jeu.".toFullDayForScreenReaders(), "jeudi");
    });

    test('should replace ven.', () {
      expect("ven.".toFullDayForScreenReaders(), "vendredi");
    });

    test('should replace sam.', () {
      expect("sam.".toFullDayForScreenReaders(), "samedi");
    });

    test('should replace dim.', () {
      expect("dim.".toFullDayForScreenReaders(), "dimanche");
    });
  });

  group('toDateForScreenReaders', () {
    test('should replace /01', () {
      expect("Le 01/01/2024".toDateForScreenReaders(), "Le 01 janvier 2024");
    });

    test('should replace /02', () {
      expect("Le 01/02/2024".toDateForScreenReaders(), "Le 01 février 2024");
    });

    test('should replace /03', () {
      expect("Le 01/03/2024".toDateForScreenReaders(), "Le 01 mars 2024");
    });

    test('should replace /04', () {
      expect("Le 01/04/2024".toDateForScreenReaders(), "Le 01 avril 2024");
    });

    test('should replace /05', () {
      expect("Le 01/05/2024".toDateForScreenReaders(), "Le 01 mai 2024");
    });

    test('should replace /06', () {
      expect("Le 01/06/2024".toDateForScreenReaders(), "Le 01 juin 2024");
    });

    test('should replace /07', () {
      expect("Le 01/07/2024".toDateForScreenReaders(), "Le 01 juillet 2024");
    });

    test('should replace /08', () {
      expect("Le 01/08/2024".toDateForScreenReaders(), "Le 01 août 2024");
    });

    test('should replace /09', () {
      expect("Le 01/09/2024".toDateForScreenReaders(), "Le 01 septembre 2024");
    });

    test('should replace /10', () {
      expect("Le 01/10/2024".toDateForScreenReaders(), "Le 01 octobre 2024");
    });

    test('should replace /11', () {
      expect("Le 01/11/2024".toDateForScreenReaders(), "Le 01 novembre 2024");
    });

    test('should replace /12', () {
      expect("Le 01/12/2024".toDateForScreenReaders(), "Le 01 décembre 2024");
    });
  });

  group('removeEmojisForScreenReaders', () {
    test('should remove a trailing emoji', () {
      expect("Bonjour\nToni 👋".removeEmojisForScreenReaders(), "Bonjour\nToni");
      expect("Bravo, Léa ! 🎉".removeEmojisForScreenReaders(), "Bravo, Léa !");
    });

    test('should remove a leading emoji', () {
      expect(
        "💡 Pas envie de répondre maintenant?".removeEmojisForScreenReaders(),
        "Pas envie de répondre maintenant?",
      );
    });

    test('should remove emojis with variation selector, zero width joiner or skin tone', () {
      expect("Vol ✈️ prévu".removeEmojisForScreenReaders(), "Vol prévu");
      expect("Entretien 🧑‍💼".removeEmojisForScreenReaders(), "Entretien");
      expect("Merci 👍🏽".removeEmojisForScreenReaders(), "Merci");
    });

    test('should remove an emoji preceded by a non-breaking space', () {
      expect("Objectif dépassé ! Bravo\u{00A0}👏".removeEmojisForScreenReaders(), "Objectif dépassé ! Bravo");
    });

    test('should keep accents, punctuation, digits and legal symbols', () {
      const text = "Ville ou code postal : Lille (59000) – 33 % © ®";
      expect(text.removeEmojisForScreenReaders(), text);
    });
  });

  group('toOffreTitleForScreenReaders', () {
    test('should spell out H/F', () {
      expect("Vendeur H/F".toOffreTitleForScreenReaders(), "Vendeur hommes et femmes");
      expect("Vendeur (H/F)".toOffreTitleForScreenReaders(), "Vendeur hommes et femmes");
      expect("Vendeur h / f - CDI".toOffreTitleForScreenReaders(), "Vendeur hommes et femmes - CDI");
    });

    test('should spell out F/H', () {
      expect("Aide-soignante F/H".toOffreTitleForScreenReaders(), "Aide-soignante femmes et hommes");
    });

    test('should leave other slashes untouched', () {
      expect("Boulanger / Pâtissier".toOffreTitleForScreenReaders(), "Boulanger / Pâtissier");
      expect("CHF/HT".toOffreTitleForScreenReaders(), "CHF/HT");
    });
  });
}
