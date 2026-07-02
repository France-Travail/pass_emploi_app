import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_state.dart';
import 'package:pass_emploi_app/features/recherche/emploi/emploi_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/emploi/emploi_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/features/recherche/service_civique/service_civique_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/service_civique/service_civique_filtres_recherche.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/metier.dart';
import 'package:pass_emploi_app/models/offre_type.dart';
import 'package:pass_emploi_app/models/recherche/recherche_request.dart';
import 'package:pass_emploi_app/presentation/recherche/recherche_home_page_view_model.dart';

import '../../doubles/fixtures.dart';
import '../../dsl/app_state_dsl.dart';

void main() {
  test('create when accompagnement is CEJ should return all solutions types', () {
    // Given
    final store = givenState().loggedInUser(accompagnement: Accompagnement.cej).store();

    // When
    final viewModel = RechercheHomePageViewModel.create(store);

    // Then
    expect(
      viewModel.offreTypes,
      [OffreType.emploi, OffreType.alternance, OffreType.immersion, OffreType.serviceCivique],
    );
  });

  test('create when accompagnement is AIJ should return all solutions types', () {
    // Given
    final store = givenState().loggedInUser(accompagnement: Accompagnement.aij).store();

    // When
    final viewModel = RechercheHomePageViewModel.create(store);

    // Then
    expect(
      viewModel.offreTypes,
      [OffreType.emploi, OffreType.alternance, OffreType.immersion, OffreType.serviceCivique],
    );
  });

  test('create when accompagnement is Avenir Pro should return all solutions types', () {
    // Given
    final store = givenState().loggedInUser(accompagnement: Accompagnement.avenirPro).store();

    // When
    final viewModel = RechercheHomePageViewModel.create(store);

    // Then
    expect(
      viewModel.offreTypes,
      [OffreType.emploi, OffreType.alternance, OffreType.immersion, OffreType.serviceCivique],
    );
  });

  test('create when accompagnement is RSA should only return OffreEmploi and Alternance', () {
    // Given
    final store = givenState().loggedInUser(accompagnement: Accompagnement.rsaFranceTravail).store();

    // When
    final viewModel = RechercheHomePageViewModel.create(store);

    // Then
    expect(
      viewModel.offreTypes,
      [OffreType.emploi, OffreType.immersion],
    );
  });

  group('criteres utilisateur', () {
    test('should expose metier and lieu labels from persisted criteres', () {
      // Given
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(
                metier: MetierTexteLibreCritere('Boulanger'),
                location: mockCommuneLocation(label: 'Paris'),
              ),
            ),
          )
          .store();

      // When
      final viewModel = RechercheHomePageViewModel.create(store);

      // Then
      expect(viewModel.metierLabel, 'Boulanger');
      expect(viewModel.lieuLabel, 'Paris');
    });

    test('should expose null labels when no persisted criteres', () {
      // Given
      final store = givenState().store();

      // When
      final viewModel = RechercheHomePageViewModel.create(store);

      // Then
      expect(viewModel.metierLabel, isNull);
      expect(viewModel.lieuLabel, isNull);
    });
  });

  group('onOffreTypeTap', () {
    final metierRome = Metier(codeRome: 'D1102', libelle: 'Boulanger');

    test('on emploi with criteres should dispatch recherche with keyword, location and rayon', () {
      // Given
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(
                metier: MetierTexteLibreCritere('Boulanger'),
                location: mockCommuneLocation(lat: 1, lon: 2),
                rayon: 30,
              ),
            ),
          )
          .spyStore();
      final viewModel = RechercheHomePageViewModel.create(store);

      // When
      viewModel.onOffreTypeTap(OffreType.emploi);

      // Then
      final dispatchedAction = store.dispatchedAction;
      expect(dispatchedAction, isA<RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>>());
      expect(
        (dispatchedAction as RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>).request,
        RechercheRequest(
          EmploiCriteresRecherche(
            keyword: 'Boulanger',
            location: mockCommuneLocation(lat: 1, lon: 2),
            rechercheType: RechercheType.offreEmploiAndAlternance,
          ),
          EmploiFiltresRecherche.withFiltres(distance: 30),
          1,
        ),
      );
    });

    test('on alternance with criteres should dispatch recherche with onlyAlternance type', () {
      // Given
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(metier: MetierTexteLibreCritere('Boulanger')),
            ),
          )
          .spyStore();
      final viewModel = RechercheHomePageViewModel.create(store);

      // When
      viewModel.onOffreTypeTap(OffreType.alternance);

      // Then
      final dispatchedAction = store.dispatchedAction;
      expect(dispatchedAction, isA<RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>>());
      final request = (dispatchedAction as RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>) //
          .request;
      expect(request.criteres.rechercheType, RechercheType.onlyAlternance);
      expect(request.filtres, EmploiFiltresRecherche.noFiltre());
    });

    test('on emploi without any criteres should not dispatch recherche', () {
      // Given
      final store = givenState().spyStore();
      final viewModel = RechercheHomePageViewModel.create(store);

      // When
      viewModel.onOffreTypeTap(OffreType.emploi);

      // Then
      expect(store.dispatchedAction, isNull);
    });

    test('on emploi with location but without metier should not dispatch recherche', () {
      // Given
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(location: mockCommuneLocation(lat: 1, lon: 2), rayon: 30),
            ),
          )
          .spyStore();
      final viewModel = RechercheHomePageViewModel.create(store);

      // When
      viewModel.onOffreTypeTap(OffreType.emploi);

      // Then
      expect(store.dispatchedAction, isNull);
    });

    test('on emploi with empty texte libre should not dispatch recherche', () {
      // Given
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(metier: MetierTexteLibreCritere(' '), location: mockCommuneLocation()),
            ),
          )
          .spyStore();
      final viewModel = RechercheHomePageViewModel.create(store);

      // When
      viewModel.onOffreTypeTap(OffreType.emploi);

      // Then
      expect(store.dispatchedAction, isNull);
    });

    test('on immersion with metier rome and commune should dispatch recherche', () {
      // Given
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(
                metier: MetierRomeCritere(metierRome),
                location: mockCommuneLocation(lat: 1, lon: 2),
                rayon: 42,
              ),
            ),
          )
          .spyStore();
      final viewModel = RechercheHomePageViewModel.create(store);

      // When
      viewModel.onOffreTypeTap(OffreType.immersion);

      // Then
      final dispatchedAction = store.dispatchedAction;
      expect(dispatchedAction, isA<RechercheRequestAction<ImmersionCriteresRecherche, ImmersionFiltresRecherche>>());
      expect(
        (dispatchedAction as RechercheRequestAction<ImmersionCriteresRecherche, ImmersionFiltresRecherche>).request,
        RechercheRequest(
          ImmersionCriteresRecherche(metier: metierRome, location: mockCommuneLocation(lat: 1, lon: 2)),
          ImmersionFiltresRecherche.distance(42),
          1,
        ),
      );
    });

    test('on immersion with metier texte libre should not dispatch recherche', () {
      // Given
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(
                metier: MetierTexteLibreCritere('Boulanger'),
                location: mockCommuneLocation(lat: 1, lon: 2),
              ),
            ),
          )
          .spyStore();
      final viewModel = RechercheHomePageViewModel.create(store);

      // When
      viewModel.onOffreTypeTap(OffreType.immersion);

      // Then
      expect(store.dispatchedAction, isNull);
    });

    test('on immersion without located commune should not dispatch recherche', () {
      // Given
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(metier: MetierRomeCritere(metierRome), location: mockLocationParis()),
            ),
          )
          .spyStore();
      final viewModel = RechercheHomePageViewModel.create(store);

      // When
      viewModel.onOffreTypeTap(OffreType.immersion);

      // Then
      expect(store.dispatchedAction, isNull);
    });

    test('on service civique with commune should dispatch recherche', () {
      // Given
      final store = givenState()
          .copyWith(
            criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
              CriteresRechercheUtilisateur(location: mockCommuneLocation()),
            ),
          )
          .spyStore();
      final viewModel = RechercheHomePageViewModel.create(store);

      // When
      viewModel.onOffreTypeTap(OffreType.serviceCivique);

      // Then
      final dispatchedAction = store.dispatchedAction;
      expect(
        dispatchedAction,
        isA<RechercheRequestAction<ServiceCiviqueCriteresRecherche, ServiceCiviqueFiltresRecherche>>(),
      );
      expect(
        (dispatchedAction as RechercheRequestAction<ServiceCiviqueCriteresRecherche, ServiceCiviqueFiltresRecherche>)
            .request,
        RechercheRequest(
          ServiceCiviqueCriteresRecherche(location: mockCommuneLocation()),
          ServiceCiviqueFiltresRecherche.noFiltre(),
          1,
        ),
      );
    });

    test('on service civique without location should not dispatch recherche', () {
      // Given
      final store = givenState().spyStore();
      final viewModel = RechercheHomePageViewModel.create(store);

      // When
      viewModel.onOffreTypeTap(OffreType.serviceCivique);

      // Then
      expect(store.dispatchedAction, isNull);
    });
  });
}
