import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';

void main() {
  group('formaterDecalageHoraire', () {
    test('formate un décalage positif entier', () {
      expect(formaterDecalageHoraire(const Duration(hours: 2)), '+02:00');
    });

    test('formate un décalage positif non entier', () {
      expect(formaterDecalageHoraire(const Duration(hours: 5, minutes: 30)), '+05:30');
    });

    test('formate un décalage négatif entier', () {
      expect(formaterDecalageHoraire(const Duration(hours: -9)), '-09:00');
    });

    test('formate un décalage négatif non entier avec des minutes positives', () {
      expect(formaterDecalageHoraire(const Duration(hours: -9, minutes: -30)), '-09:30');
    });

    test('formate un décalage négatif de moins d’une heure', () {
      expect(formaterDecalageHoraire(const Duration(minutes: -30)), '-00:30');
    });
  });

  test('toIso8601WithOffsetDateTime se termine par le décalage local', () {
    final date = DateTime(2026, 9, 30, 10, 15, 0);

    expect(date.toIso8601WithOffsetDateTime(), '2026-09-30T10:15:00${formaterDecalageHoraire(date.timeZoneOffset)}');
  });
}
