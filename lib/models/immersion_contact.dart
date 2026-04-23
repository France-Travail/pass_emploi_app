enum ImmersionContactMode { MAIL, PHONE, PRESENTIEL, INCONNU }

ImmersionContactMode parseImmersionContactMode(String? json) {
  if (json == 'EMAIL') return ImmersionContactMode.MAIL;
  if (json == 'TELEPHONE') return ImmersionContactMode.PHONE;
  if (json == 'PRESENTIEL') return ImmersionContactMode.PRESENTIEL;
  return ImmersionContactMode.INCONNU;
}

extension ImmersionContactModeExt on ImmersionContactMode {
  String toJson() => switch (this) {
    ImmersionContactMode.MAIL => 'EMAIL',
    ImmersionContactMode.PHONE => 'PHONE',
    ImmersionContactMode.PRESENTIEL => 'IN_PERSON',
    ImmersionContactMode.INCONNU => 'EMAIL',
  };
}
