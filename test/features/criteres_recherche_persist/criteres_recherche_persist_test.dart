import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_actions.dart';
import 'package:pass_emploi_app/features/criteres_recherche_persist/criteres_recherche_persist_state.dart';
import 'package:pass_emploi_app/features/recherche/emploi/emploi_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/emploi/emploi_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/immersion/immersion_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/features/recherche/service_civique/service_civique_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/service_civique/service_civique_filtres_recherche.dart';
import 'package:pass_emploi_app/models/criteres_recherche_utilisateur.dart';
import 'package:pass_emploi_app/models/metier.dart';
import 'package:pass_emploi_app/models/recherche/recherche_request.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

void main() {
  group('CriteresRecherchePersist', () {
    final sut = StoreSut();
    final repository = MockCriteresRecherchePersistRepository();

    group('when bootstraping', () {
      sut.whenDispatchingAction(() => BootstrapAction());

      test('should load persisted criteres', () {
        when(() => repository.get()).thenAnswer(
          (_) async => CriteresRechercheUtilisateur(location: mockCommuneLocation()),
        );

        sut.givenStore = givenState() //
            .store((f) => {f.criteresRecherchePersistRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([
          _shouldSucceedWith(CriteresRechercheUtilisateur(location: mockCommuneLocation())),
        ]);
      });

      test('should succeed with empty criteres when nothing persisted', () {
        when(() => repository.get()).thenAnswer((_) async => null);

        sut.givenStore = givenState() //
            .store((f) => {f.criteresRecherchePersistRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldSucceedWith(CriteresRechercheUtilisateur())]);
      });
    });

    group('when writing location', () {
      sut.whenDispatchingAction(() => CriteresRecherchePersistWriteLocationAction(mockCommuneLocation()));

      test('should save and update location', () {
        sut.givenStore = givenState() //
            .store((f) => {f.criteresRecherchePersistRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([
          _shouldSucceedWith(CriteresRechercheUtilisateur(location: mockCommuneLocation())),
        ]);
      });
    });

    group('when writing null location', () {
      sut.whenDispatchingAction(() => CriteresRecherchePersistWriteLocationAction(null));

      test('should clear persisted location but keep metier', () {
        sut.givenStore = givenState()
            .copyWith(
              criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
                CriteresRechercheUtilisateur(
                  metier: MetierTexteLibreCritere('Boulanger'),
                  location: mockCommuneLocation(),
                ),
              ),
            )
            .store((f) => {f.criteresRecherchePersistRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([
          _shouldSucceedWith(CriteresRechercheUtilisateur(metier: MetierTexteLibreCritere('Boulanger'))),
        ]);
      });
    });

    group('when requesting a recherche emploi', () {
      sut.whenDispatchingAction(
        () => RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>(
          RechercheRequest(
            EmploiCriteresRecherche(
              keyword: 'Boulanger',
              location: mockCommuneLocation(),
              rechercheType: RechercheType.offreEmploiAndAlternance,
            ),
            EmploiFiltresRecherche.withFiltres(distance: 30),
            1,
          ),
        ),
      );

      test('should persist keyword as texte libre with location and rayon', () {
        sut.givenStore = givenState() //
            .loggedInUser()
            .store((f) => {f.criteresRecherchePersistRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([
          _shouldSucceedWith(
            CriteresRechercheUtilisateur(
              metier: MetierTexteLibreCritere('Boulanger'),
              location: mockCommuneLocation(),
              rayon: 30,
            ),
          ),
        ]);
      });

      test('should keep persisted metier rome when keyword matches its libelle', () {
        final metierRome = MetierRomeCritere(Metier(codeRome: 'D1102', libelle: 'Boulanger'));
        sut.givenStore = givenState()
            .copyWith(
              criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
                CriteresRechercheUtilisateur(metier: metierRome),
              ),
            )
            .loggedInUser()
            .store((f) => {f.criteresRecherchePersistRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([
          _shouldSucceedWith(
            CriteresRechercheUtilisateur(metier: metierRome, location: mockCommuneLocation(), rayon: 30),
          ),
        ]);
      });
    });

    group('when requesting a recherche emploi without keyword', () {
      sut.whenDispatchingAction(
        () => RechercheRequestAction<EmploiCriteresRecherche, EmploiFiltresRecherche>(
          RechercheRequest(
            EmploiCriteresRecherche(
              keyword: '',
              location: mockCommuneLocation(),
              rechercheType: RechercheType.offreEmploiAndAlternance,
            ),
            EmploiFiltresRecherche.noFiltre(),
            1,
          ),
        ),
      );

      test('should keep previously persisted metier', () {
        sut.givenStore = givenState()
            .copyWith(
              criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
                CriteresRechercheUtilisateur(metier: MetierTexteLibreCritere('Boulanger')),
              ),
            )
            .loggedInUser()
            .store((f) => {f.criteresRecherchePersistRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([
          _shouldSucceedWith(
            CriteresRechercheUtilisateur(metier: MetierTexteLibreCritere('Boulanger'), location: mockCommuneLocation()),
          ),
        ]);
      });
    });

    group('when requesting a recherche immersion', () {
      final metier = Metier(codeRome: 'D1102', libelle: 'Boulanger');

      sut.whenDispatchingAction(
        () => RechercheRequestAction<ImmersionCriteresRecherche, ImmersionFiltresRecherche>(
          RechercheRequest(
            ImmersionCriteresRecherche(metier: metier, location: mockCommuneLocation(lat: 1, lon: 2)),
            ImmersionFiltresRecherche.distance(15),
            1,
          ),
        ),
      );

      test('should persist metier rome with location and rayon', () {
        sut.givenStore = givenState() //
            .loggedInUser()
            .store((f) => {f.criteresRecherchePersistRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([
          _shouldSucceedWith(
            CriteresRechercheUtilisateur(
              metier: MetierRomeCritere(metier),
              location: mockCommuneLocation(lat: 1, lon: 2),
              rayon: 15,
            ),
          ),
        ]);
      });
    });

    group('when requesting a recherche service civique', () {
      sut.whenDispatchingAction(
        () => RechercheRequestAction<ServiceCiviqueCriteresRecherche, ServiceCiviqueFiltresRecherche>(
          RechercheRequest(
            ServiceCiviqueCriteresRecherche(location: mockCommuneLocation()),
            ServiceCiviqueFiltresRecherche.noFiltre(),
            1,
          ),
        ),
      );

      test('should persist location and keep metier', () {
        sut.givenStore = givenState()
            .copyWith(
              criteresRecherchePersistState: CriteresRecherchePersistSuccessState(
                CriteresRechercheUtilisateur(metier: MetierTexteLibreCritere('Boulanger')),
              ),
            )
            .loggedInUser()
            .store((f) => {f.criteresRecherchePersistRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([
          _shouldSucceedWith(
            CriteresRechercheUtilisateur(metier: MetierTexteLibreCritere('Boulanger'), location: mockCommuneLocation()),
          ),
        ]);
      });
    });
  });
}

Matcher _shouldSucceedWith(CriteresRechercheUtilisateur expected) {
  return StateMatch((state) {
    final persistState = state.criteresRecherchePersistState;
    return persistState is CriteresRecherchePersistSuccessState && persistState.criteres == expected;
  });
}
