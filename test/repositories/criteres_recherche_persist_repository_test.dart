import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/metier.dart';
import 'package:pass_emploi_app/repositories/criteres_recherche_persist_repository.dart';

import '../doubles/fixtures.dart';
import '../doubles/spies.dart';

void main() {
  late FlutterSecureStorageSpy secureStorage;
  late CriteresRecherchePersistRepository repository;

  setUp(() {
    secureStorage = FlutterSecureStorageSpy(delay: Duration.zero);
    repository = CriteresRecherchePersistRepository(secureStorage);
  });

  group('CriteresRecherchePersistRepository', () {
    test('full integration test with metier rome', () async {
      // Given
      final criteres = CriteresRechercheUtilisateur(
        metier: MetierRomeCritere(Metier(codeRome: 'A1101', libelle: 'Conduite d’engins agricoles')),
        location: mockCommuneLocation(lat: 1.2, lon: 3.4),
        rayon: 42,
      );
      await repository.save(criteres);

      // When
      final result = await repository.get();

      // Then
      expect(result, equals(criteres));
    });

    test('full integration test with metier texte libre', () async {
      // Given
      final criteres = CriteresRechercheUtilisateur(metier: MetierTexteLibreCritere('Boulanger'));
      await repository.save(criteres);

      // When
      final result = await repository.get();

      // Then
      expect(result, equals(criteres));
    });

    test('should return null when nothing is stored', () async {
      // When
      final result = await repository.get();

      // Then
      expect(result, isNull);
    });

    test('should migrate legacy persisted localisation when nothing is stored', () async {
      // Given
      await secureStorage.write(key: 'localisationPersist', value: json.encode(mockCommuneLocation().toJson()));

      // When
      final result = await repository.get();

      // Then
      expect(result, equals(CriteresRechercheUtilisateur(location: mockCommuneLocation())));
      expect(await secureStorage.read(key: 'localisationPersist'), isNull);
    });
  });
}
