enum ImmersionContactMode { MAIL, PHONE, PRESENTIEL, INCONNU }

ImmersionContactMode parseImmersionContactMode(String? json) {
  if (json == 'EMAIL') return ImmersionContactMode.MAIL;
  if (json == 'TELEPHONE') return ImmersionContactMode.PHONE;
  if (json == 'PRESENTIEL') return ImmersionContactMode.PRESENTIEL;
  return ImmersionContactMode.INCONNU;
}
