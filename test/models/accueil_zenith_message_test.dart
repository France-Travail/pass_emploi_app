import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/accueil_zenith_message.dart';

void main() {
  test('Should return message when now is within [dateDebut, dateFin]', () {
    final now = DateTime.now();
    final dateDebut = now.subtract(Duration(days: 1));
    final dateFin = now.add(Duration(days: 1));

    final message = AccueilZenithMessage.fromJson({
      'title': 'title',
      'description': 'description',
      'dateDebut': dateDebut.millisecondsSinceEpoch,
      'dateFin': dateFin.millisecondsSinceEpoch,
    });

    expect(message, isNotNull);
    expect(message!.title, 'title');
    expect(message.description, 'description');
  });

  test('Should return null when dateDebut is after now (future window)', () {
    final now = DateTime.now();
    final dateDebut = now.add(Duration(days: 1));
    final dateFin = now.add(Duration(days: 2));

    final message = AccueilZenithMessage.fromJson({
      'title': 'title',
      'description': 'description',
      'dateDebut': dateDebut.millisecondsSinceEpoch,
      'dateFin': dateFin.millisecondsSinceEpoch,
    });

    expect(message, isNull);
  });

  test('Should return null when dateFin is before now (past window)', () {
    final now = DateTime.now();
    final dateDebut = now.subtract(Duration(days: 2));
    final dateFin = now.subtract(Duration(days: 1));

    final message = AccueilZenithMessage.fromJson({
      'title': 'title',
      'description': 'description',
      'dateDebut': dateDebut.millisecondsSinceEpoch,
      'dateFin': dateFin.millisecondsSinceEpoch,
    });

    expect(message, isNull);
  });
}
