import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/recherche/emploi/emploi_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/emploi/emploi_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/models/recherche/recherche_request.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/recherche/emploi/criteres_recherche_emploi_contenu_view_model.dart';

import '../../../doubles/fixtures.dart';
import '../../../doubles/spies.dart';
import '../../../dsl/app_state_dsl.dart';

void main() {
  group('displayState', () {
    test('when recherche status is nouvelle recherche should display CONTENT', () {
      // Given
      final store = givenState().initialRechercheEmploiState().store();

      // When
      final viewModel = CriteresRechercheEmploiContenuViewModel.create(store);

      // Then
      expect(viewModel.displayState, DisplayState.CONTENT);
    });

    test('when recherche status is initial loading should display LOADING', () {
      // Given
      final store = givenState().initialLoadingRechercheEmploiState().store();

      // When
      final viewModel = CriteresRechercheEmploiContenuViewModel.create(store);

      // Then
      expect(viewModel.displayState, DisplayState.LOADING);
    });

    test('when recherche status is failure should display FAILURE', () {
      // Given
      final store = givenState().failureRechercheEmploiState().store();

      // When
      final viewModel = CriteresRechercheEmploiContenuViewModel.create(store);

      // Then
      expect(viewModel.displayState, DisplayState.FAILURE);
    });
  });

  group('onSearchingRequest', () {
    test('on initial request should dispatch proper action without filtres', () {
      // Given
      final store = StoreSpy();
      final viewModel = CriteresRechercheEmploiContenuViewModel.create(store);

      // When
      viewModel.onSearchingRequest('keywords', mockLocation(), false);

      // Then
      final dispatchedAction = store.dispatchedAction;
      expect(
        dispatchedAction,
        isA<RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>>(),
      );
      expect(
        (dispatchedAction as RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>).request,
        RechercheRequest(
          EmploiCriteresRecherche(keyword: 'keywords', location: mockLocation(), onlyAlternance: false),
          EmploiFiltresRecherche.noFiltre(),
          1,
        ),
      );
    });

    group('on updated request', () {
      test('should dispatch proper action with previous filtres', () {
        // Given
        final previousFiltres = EmploiFiltresRecherche.withFiltres(debutantOnly: true);
        final store = givenState().rechercheEmploiStateWithRequest(filtres: previousFiltres).spyStore();
        final viewModel = CriteresRechercheEmploiContenuViewModel.create(store);

        // When
        viewModel.onSearchingRequest('keywords', mockLocation(), false);

        // Then
        final dispatchedAction = store.dispatchedAction;
        expect(
          dispatchedAction,
          isA<RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>>(),
        );
        expect(
          (dispatchedAction as RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>).request,
          RechercheRequest(
            EmploiCriteresRecherche(keyword: 'keywords', location: mockLocation(), onlyAlternance: false),
            previousFiltres,
            1,
          ),
        );
      });

      test('if new location is null should dispatch proper action with previous filtres excluding distance', () {
        // Given
        final previousFiltres = EmploiFiltresRecherche.withFiltres(distance: 50, debutantOnly: true);
        final store = givenState().rechercheEmploiStateWithRequest(filtres: previousFiltres).spyStore();
        final viewModel = CriteresRechercheEmploiContenuViewModel.create(store);

        // When
        viewModel.onSearchingRequest('keywords', null, false);

        // Then
        final dispatchedAction = store.dispatchedAction;
        expect(
          dispatchedAction,
          isA<RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>>(),
        );
        expect(
          (dispatchedAction as RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>).request,
          RechercheRequest(
            EmploiCriteresRecherche(keyword: 'keywords', location: null, onlyAlternance: false),
            EmploiFiltresRecherche.withFiltres(debutantOnly: true),
            1,
          ),
        );
      });

      test('if new location is a department should dispatch proper action with previous filtres excluding distance',
          () {
        // Given
        final previousFiltres = EmploiFiltresRecherche.withFiltres(distance: 50, debutantOnly: true);
        final store = givenState().rechercheEmploiStateWithRequest(filtres: previousFiltres).spyStore();
        final viewModel = CriteresRechercheEmploiContenuViewModel.create(store);

        // When
        viewModel.onSearchingRequest('keywords', mockLocation(), false);

        // Then
        final dispatchedAction = store.dispatchedAction;
        expect(
          dispatchedAction,
          isA<RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>>(),
        );
        expect(
          (dispatchedAction as RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>).request,
          RechercheRequest(
            EmploiCriteresRecherche(keyword: 'keywords', location: mockLocation(), onlyAlternance: false),
            EmploiFiltresRecherche.withFiltres(debutantOnly: true),
            1,
          ),
        );
      });
    });
  });
}
