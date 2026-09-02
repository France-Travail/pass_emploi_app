import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

enum EvenementEmploiType {
  reunionInformation(Strings.evenementEmploiTypeReunionInformation),
  forum(Strings.evenementEmploiTypeForum),
  conference(Strings.evenementEmploiTypeConference),
  atelier(Strings.evenementEmploiTypeAtelier),
  salonEnLigne(Strings.evenementEmploiTypeSalonEnLigne),
  jobDating(Strings.evenementEmploiTypeJobDating),
  visiteEntreprise(Strings.evenementEmploiTypeVisiteEntreprise),
  portesOuvertes(Strings.evenementEmploiTypePortesOuvertes);

  const EvenementEmploiType(this.label);

  final String label;
}

EvenementEmploiType? evenementEmploiTypeFromLabel(String label) {
  for (final type in EvenementEmploiType.values) {
    if (type.label == label) return type;
  }
  return null;
}

const evenementEmploiDefaultEmoji = '📅';

Color get evenementEmploiDefaultEmojiBackground => DsfrColors.blueCumulus950;

extension EvenementEmploiTypeVisual on EvenementEmploiType {
  String get emoji => switch (this) {
    EvenementEmploiType.reunionInformation => 'ℹ️',
    EvenementEmploiType.forum => '🤝',
    EvenementEmploiType.conference => '🎤',
    EvenementEmploiType.atelier => '🛠️',
    EvenementEmploiType.salonEnLigne => '💻',
    EvenementEmploiType.jobDating => '💼',
    EvenementEmploiType.visiteEntreprise => '🏢',
    EvenementEmploiType.portesOuvertes => '🚪',
  };

  Color get emojiBackground => switch (this) {
    EvenementEmploiType.reunionInformation => DsfrColors.blueCumulus950,
    EvenementEmploiType.forum => DsfrColors.greenMenthe950,
    EvenementEmploiType.conference => DsfrColors.purpleGlycine925,
    EvenementEmploiType.atelier => DsfrColors.brownCaramel950,
    EvenementEmploiType.salonEnLigne => DsfrColors.blueFrance950,
    EvenementEmploiType.jobDating => DsfrColors.pinkTuile925,
    EvenementEmploiType.visiteEntreprise => DsfrColors.greenTilleulVerveine950,
    EvenementEmploiType.portesOuvertes => DsfrColors.success950,
  };
}
