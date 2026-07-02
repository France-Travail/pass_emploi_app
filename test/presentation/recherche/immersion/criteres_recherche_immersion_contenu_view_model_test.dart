import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_state.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/metier.dart';
import 'package:pass_emploi_app/models/recherche/recherche_request.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/recherche/immersion/criteres_recherche_immersion_contenu_view_model.dart';

import '../../../doubles/fixtures.dart';
import '../../../doubles/spies.dart';
import '../../../dsl/app_state_dsl.dart';

void main() {
  group('on create', () {
    test('should display last searched location when initialised', () {
      // Given
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(location: mockCommuneLocation()),
            ),
          )
          .store();

      // When
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // Then
      expect(viewModel.initialLocation, mockCommuneLocation());
    });

    test('should not display last searched department when initialised', () {
      // Given
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(location: mockLocationParis()),
            ),
          )
          .store();

      // When
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // Then
      expect(viewModel.initialLocation, null);
    });

    test('should display last searched location when null', () {
      // Given
      final store = givenState()
          .copyWith(criteresRecherchePersistState: CriteresRecherchePersistSuccessState(CriteresRechercheUtilisateur()))
          .store();

      // When
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // Then
      expect(viewModel.initialLocation, null);
    });

    test('should not display last searched location when not initialised', () {
      // Given
      final store =
          givenState().copyWith(criteresRecherchePersistState: CriteresRecherchePersistNotInitializedState()).store();

      // When
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // Then
      expect(viewModel.initialLocation, null);
    });

    test('should prefill metier with persisted metier rome', () {
      // Given
      final metier = Metier(codeRome: 'A1101', libelle: 'Conduite d’engins agricoles');
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(metier: MetierRomeCritere(metier)),
            ),
          )
          .store();

      // When
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // Then
      expect(viewModel.initialMetier, metier);
    });

    test('should not prefill metier with persisted texte libre', () {
      // Given
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(metier: MetierTexteLibreCritere('Boulanger')),
            ),
          )
          .store();

      // When
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // Then
      expect(viewModel.initialMetier, null);
    });

    test('should prefill distance with persisted rayon', () {
      // Given
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(rayon: 42),
            ),
          )
          .store();

      // When
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // Then
      expect(viewModel.initialDistance, 42);
    });
  });
  group('displayState', () {
    test('when recherche status is nouvelle recherche should display CONTENT', () {
      // Given
      final store = givenState().initialRechercheImmersionState().store();

      // When
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // Then
      expect(viewModel.displayState, DisplayState.CONTENT);
    });

    test('when recherche status is initial loading should display LOADING', () {
      // Given
      final store = givenState().initialLoadingRechercheImmersionState().store();

      // When
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // Then
      expect(viewModel.displayState, DisplayState.LOADING);
    });

    test('when recherche status is failure should display FAILURE', () {
      // Given
      final store = givenState().failureRechercheImmersionState().store();

      // When
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // Then
      expect(viewModel.displayState, DisplayState.FAILURE);
    });
  });

  group('initialDistance', () {
    test('should default to ImmersionFiltresRecherche.defaultDistanceValue when no request', () {
      // Given
      final store = givenState().store();

      // When
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // Then
      expect(viewModel.initialDistance, ImmersionFiltresRecherche.defaultDistanceValue);
    });

    test('should use distance from previous filtres when request exists', () {
      // Given
      final previousFiltres = ImmersionFiltresRecherche.distance(50);
      final store = givenState().successRechercheImmersionStateWithRequest(filtres: previousFiltres).store();

      // When
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // Then
      expect(viewModel.initialDistance, 50);
    });
  });

  group('onSearchingRequest', () {
    test('on initial request should dispatch proper action with provided distance', () {
      // Given
      final store = StoreSpy();
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // When
      viewModel.onSearchingRequest(mockMetier(), mockLocation(), 30);

      // Then
      final dispatchedAction = store.dispatchedAction;
      expect(
        dispatchedAction,
        isA<RechercheRequestAction<ImmersionCriteresRecherche, ImmersionFiltresRecherche>>(),
      );
      expect(
        (dispatchedAction as RechercheRequestAction<ImmersionCriteresRecherche, ImmersionFiltresRecherche>).request,
        RechercheRequest(
          ImmersionCriteresRecherche(metier: mockMetier(), location: mockLocation()),
          ImmersionFiltresRecherche.distance(30),
          1,
        ),
      );
    });

    test('on updated request should dispatch proper action with updated distance', () {
      // Given
      final previousFiltres = ImmersionFiltresRecherche.distance(50);
      final store = givenState().successRechercheImmersionStateWithRequest(filtres: previousFiltres).spyStore();
      final viewModel = CriteresRechercheImmersionContenuViewModel.create(store);

      // When
      viewModel.onSearchingRequest(mockMetier(), mockLocation(), 70);

      // Then
      final dispatchedAction = store.dispatchedAction;
      expect(
        dispatchedAction,
        isA<RechercheRequestAction<ImmersionCriteresRecherche, ImmersionFiltresRecherche>>(),
      );
      expect(
        (dispatchedAction as RechercheRequestAction<ImmersionCriteresRecherche, ImmersionFiltresRecherche>).request,
        RechercheRequest(
          ImmersionCriteresRecherche(metier: mockMetier(), location: mockLocation()),
          ImmersionFiltresRecherche.distance(70),
          1,
        ),
      );
    });
  });
}
