import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/mode_demo/is_mode_demo_repository.dart';
import 'package:pass_emploi_app/models/chat/message.dart';
import 'package:pass_emploi_app/models/evenement_emploi_partage.dart';
import 'package:pass_emploi_app/repositories/chat_repository.dart';

import '../doubles/dummies.dart';

void main() {
  late _CrashlyticsSpy crashlytics;
  late ChatRepository repository;

  setUp(() {
    crashlytics = _CrashlyticsSpy();
    repository = ChatRepository(DummyChatCrypto(), crashlytics, ModeDemoRepository());
  });

  // Aucune app Firebase n'existe dans les tests : la lecture de la conversation échoue comme Firestore hors ligne.
  group('when conversation cannot be read', () {
    test('sendEvenementEmploiPartage should return false and record the error', () async {
      // When
      final result = await repository.sendEvenementEmploiPartage(
        'jeune-id',
        EvenementEmploiPartage(id: 'id', titre: 'titre', url: 'url', message: 'message'),
      );

      // Then
      expect(result, isFalse);
      expect(crashlytics.recordedExceptions, hasLength(1));
    });

    test('sendMessage should return false and record the error', () async {
      // When
      final result = await repository.sendMessage('jeune-id', Message.fromText('Bonjour'));

      // Then
      expect(result, isFalse);
      expect(crashlytics.recordedExceptions, hasLength(1));
    });
  });
}

class _CrashlyticsSpy extends DummyCrashlytics {
  final List<dynamic> recordedExceptions = [];

  @override
  void recordNonNetworkException(dynamic exception, [StackTrace? stack, Uri? failingEndpoint]) {
    recordedExceptions.add(exception);
  }
}
