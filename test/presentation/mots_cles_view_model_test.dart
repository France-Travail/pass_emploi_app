import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/presentation/mots_cles_view_model.dart';

import '../doubles/fixtures.dart';
import '../dsl/app_state_dsl.dart';

void main() {
  test('create view model without recherches recentes', () {
    // Given
    final store = givenState() //
        .loggedIn() //
        .withRecentsSearches([]) //
        .store();
    // When
    final result = MotsClesViewModel.create(store);
    // Then
    expect(result.motsCles, []);
    expect(result.containsMotsClesRecents, false);
  });

  test('create view model with 1 recherche recente', () {
    // Given
    final store = givenState().loggedIn().withRecentsSearches([
      mockOffreEmploiAlerte(keyword: "chevalier"),
    ]).store();
    // When
    final result = MotsClesViewModel.create(store);
    // Then
    expect(result.motsCles, [
      MotsClesTitleItem("Recherches récentes"),
      MotsClesSuggestionItem("chevalier", MotCleSource.dernieresRecherches),
    ]);
    expect(result.containsMotsClesRecents, true);
  });

  test('create view model with many recherche recente should only take 3', () {
    // Given
    final store = givenState().loggedIn().withRecentsSearches([
      mockOffreEmploiAlerte(keyword: "1"),
      mockOffreEmploiAlerte(keyword: "2"),
      mockOffreEmploiAlerte(keyword: "3"),
      mockOffreEmploiAlerte(keyword: "4"),
    ]).store();
    // When
    final result = MotsClesViewModel.create(store);
    // Then
    expect(result.motsCles, [
      MotsClesTitleItem("Recherches récentes"),
      MotsClesSuggestionItem("1", MotCleSource.dernieresRecherches),
      MotsClesSuggestionItem("2", MotCleSource.dernieresRecherches),
      MotsClesSuggestionItem("3", MotCleSource.dernieresRecherches),
    ]);
  });

  test('create view model with duplicated keywords in dernières recherches should remove them', () {
    // Given
    final store = givenState().loggedIn().withRecentsSearches([
      mockOffreEmploiAlerte(keyword: "1"),
      mockOffreEmploiAlerte(keyword: "2"),
      mockOffreEmploiAlerte(keyword: "1"),
    ]).store();
    // When
    final result = MotsClesViewModel.create(store);
    // Then
    expect(result.motsCles, [
      MotsClesTitleItem("Recherches récentes"),
      MotsClesSuggestionItem("1", MotCleSource.dernieresRecherches),
      MotsClesSuggestionItem("2", MotCleSource.dernieresRecherches),
    ]);
  });

  test('create view model with null keyword in dernières recherches should remove them', () {
    // Given
    final store = givenState().loggedIn().withRecentsSearches([
      mockOffreEmploiAlerte(keyword: "1"),
      mockOffreEmploiAlerte(keyword: null),
      mockOffreEmploiAlerte(keyword: "2"),
    ]).store();
    // When
    final result = MotsClesViewModel.create(store);
    // Then
    expect(result.motsCles, [
      MotsClesTitleItem("Recherches récentes"),
      MotsClesSuggestionItem("1", MotCleSource.dernieresRecherches),
      MotsClesSuggestionItem("2", MotCleSource.dernieresRecherches),
    ]);
  });
}
