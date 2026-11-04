import 'package:pass_emploi_app/ui/strings.dart';

extension A11yStringExtensions on String {
  String toTimeAndDurationForScreenReaders() {
    return replaceAll("h", Strings.a11yHours)
        .replaceAll(":", Strings.a11yHours)
        .replaceAll("min", Strings.a11yMinutes)
        .replaceAll("00", "")
        .replaceAll("(", "(${Strings.a11yDuration}");
  }

  String toFullDayForScreenReaders() {
    return replaceAll("lun.", Strings.a11yMonday)
        .replaceAll("mar.", Strings.a11yTuesday)
        .replaceAll("mer.", Strings.a11yWednesday)
        .replaceAll("jeu.", Strings.a11yThursday)
        .replaceAll("ven.", Strings.a11yFriday)
        .replaceAll("sam.", Strings.a11ySaturday)
        .replaceAll("dim.", Strings.a11ySunday);
  }

  String toDateForScreenReaders() {
    return replaceAll("/01", Strings.a11yJanuary)
        .replaceAll("/02", Strings.a11yFebruary)
        .replaceAll("/03", Strings.a11yMarch)
        .replaceAll("/04", Strings.a11yApril)
        .replaceAll("/05", Strings.a11yMay)
        .replaceAll("/06", Strings.a11yJune)
        .replaceAll("/07", Strings.a11yJuly)
        .replaceAll("/08", Strings.a11yAugust)
        .replaceAll("/09", Strings.a11ySeptember)
        .replaceAll("/10", Strings.a11yOctober)
        .replaceAll("/11", Strings.a11yNovember)
        .replaceAll("/12", Strings.a11yDecember)
        .replaceAll("/", "");
  }

  String removeIconsForScreenReaders() {
    return replaceAll('↗', '');
  }

  /// A11y 8.1 : l'abréviation « H/F » (ou « F/H ») des intitulés d'offre est lue « H F » ; elle est explicitée.
  String toOffreTitleForScreenReaders() {
    return replaceAllMapped(_genderAbbreviationRegExp, (match) {
      final first = match.group(1)!.toUpperCase();
      return first == 'H' ? Strings.a11yHommesEtFemmes : Strings.a11yFemmesEtHommes;
    });
  }

  /// A11y 1.1 : les emojis accolés à un texte sont décoratifs (« 👋 », « 🎉 », « 💡 »…) ;
  /// sans ce filtre, TalkBack et VoiceOver les lisent (« signe de la main », « cornet à confetti »…).
  String removeEmojisForScreenReaders() {
    return replaceAll(_emojiRegExp, '').replaceAll(_doubleSpacesRegExp, ' ').trim();
  }
}

// © ® ™ font partie de Extended_Pictographic mais ne sont pas décoratifs : on les conserve.
final _emojiRegExp = RegExp(
  r'(?![©®™])\p{Extended_Pictographic}|\p{Emoji_Modifier}|[\u{FE0F}\u{200D}\u{20E3}]',
  unicode: true,
);
final _doubleSpacesRegExp = RegExp(r'[  ]{2,}');

// « H/F », « (H/F) », « F / H », « h/f »… isolés (pas au milieu d'un mot).
final _genderAbbreviationRegExp = RegExp(r'\(?\b([HF])\s*/\s*([FH])\b\)?', caseSensitive: false);
