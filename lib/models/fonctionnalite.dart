enum Fonctionnalite {
  planAction("PLAN_ACTION");

  final String value;

  const Fonctionnalite(this.value);

  static Fonctionnalite? fromString(String value) {
    return Fonctionnalite.values.where((e) => e.value == value).firstOrNull;
  }
}
