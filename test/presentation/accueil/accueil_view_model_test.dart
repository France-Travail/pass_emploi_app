import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/accueil/accueil_actions.dart';
import 'package:pass_emploi_app/features/accueil/accueil_state.dart';
import 'package:pass_emploi_app/features/date_consultation_notification/date_consultation_notification_state.dart';
import 'package:pass_emploi_app/features/favori/update/favori_update_state.dart';
import 'package:pass_emploi_app/features/offres_suivies/offres_suivies_state.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/models/accueil/accueil.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/models/deep_link.dart';
import 'package:pass_emploi_app/models/favori.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/remote_campagne_accueil.dart';
import 'package:pass_emploi_app/presentation/accueil/accueil_item.dart';
import 'package:pass_emploi_app/presentation/accueil/accueil_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/spies.dart';
import '../../dsl/app_state_dsl.dart';

void main() {
  group("display state", (() {
    test('should be loading when accueil is loading', () {
      // Given
      final store = givenState().loggedInMiloUser().withAccueilLoading().store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(viewModel.displayState, DisplayState.LOADING);
    });

    test('should be content when accueil is success', () {
      // Given
      final store = givenState().loggedInMiloUser().withAccueilMiloSuccess().store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(viewModel.displayState, DisplayState.CONTENT);
    });

    test('should be failure when accueil is failure', () {
      // Given
      final store = givenState().loggedInMiloUser().withAccueilFailure().store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(viewModel.displayState, DisplayState.FAILURE);
    });
  }));

  group('milo', () {
    test('should have all items', () {
      // Given
      final store =
          givenState() //
              .loggedInMiloUser()
              .showRating()
              .withAccueilMiloSuccess()
              .withFeatureFlip(withCampagneRecrutement: true)
              .withCampagne(campagne())
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items,
        [
          RatingAppItem(),
          CampagneRecrutementItem(onDismiss: () {}),
          CampagneEvaluationItem(titre: "Questionnaire", description: "Super test"),
          AccueilCetteSemaineItem(
            rendezvousCount: "3",
            actionsOuDemarchesCount: "1",
            actionsOuDemarchesLabel: "Action",
            withComptageDesHeures: true,
          ),
          AccueilColorSeparatorItem(),
          AccueilProchainRendezvousItem(mockRendezvousMiloCV().id),
          AccueilSuiviDesOffresItem(),
          AccueilEvenementsItem([
            (mockAnimationCollective().id, AccueilEvenementsType.animationCollective),
            (mockSessionMiloAtelierDecouverte().id, AccueilEvenementsType.sessionMilo),
          ]),
          AccueilAlertesItem(getMockedAlerte()),
        ],
      );
    });

    test('should have prochaine session instead of prochain rendezvous when date is before', () {
      // Given
      final rdv = mockRendezvous(date: DateTime(2030));
      final sessionMilo = mockSessionMilo(dateDeDebut: DateTime(2025));
      final store =
          givenState() //
              .loggedInMiloUser()
              .withAccueilMiloSuccess(
                mockAccueilMilo().copyWith(
                  prochainRendezVous: rdv,
                  prochaineSessionMilo: sessionMilo,
                  peutVoirLeComptageDesHeures: false,
                  cetteSemaine: AccueilCetteSemaine(
                    nombreRendezVous: 3,
                    nombreActionsDemarchesARealiser: 2,
                  ),
                ),
              )
              .withCampagne(campagne())
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items,
        [
          CampagneEvaluationItem(titre: "Questionnaire", description: "Super test"),
          AccueilCetteSemaineItem(
            rendezvousCount: "3",
            actionsOuDemarchesCount: "2",
            actionsOuDemarchesLabel: "Actions",
            withComptageDesHeures: false,
          ),
          AccueilColorSeparatorItem(),
          AccueilProchaineSessionMiloItem(sessionMilo.id),
          AccueilSuiviDesOffresItem(),
          AccueilEvenementsItem([
            (mockAnimationCollective().id, AccueilEvenementsType.animationCollective),
            (mockSessionMiloAtelierDecouverte().id, AccueilEvenementsType.sessionMilo),
          ]),
          AccueilAlertesItem(getMockedAlerte()),
        ],
      );
    });
  });

  group('pe', () {
    test('should have all items', () {
      // Given
      final store =
          givenState() //
              .loggedInPoleEmploiUser()
              .withAccueilPoleEmploiSuccess()
              .withFeatureFlip(withCampagneRecrutement: true)
              .withCampagne(campagne())
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items,
        [
          CampagneRecrutementItem(onDismiss: () {}),
          CampagneEvaluationItem(titre: "Questionnaire", description: "Super test"),
          AccueilCetteSemaineItem(
            rendezvousCount: "3",
            actionsOuDemarchesCount: "1",
            actionsOuDemarchesLabel: "Démarche",
            withComptageDesHeures: true,
          ),
          AccueilColorSeparatorItem(),
          AccueilProchainRendezvousItem(mockRendezvousPoleEmploi().id),
          AccueilSuiviDesOffresItem(),
          AccueilAlertesItem(getMockedAlerte()),
        ],
      );
    });

    test('should have erreur degradee', () {
      // Given
      final store =
          givenState() //
              .loggedInPoleEmploiUser()
              .withAccueilPoleEmploiSuccessErreurDegradee()
              .withFeatureFlip(withCampagneRecrutement: true)
              .withCampagne(campagne())
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items,
        [
          ErrorDegradeeItem("Certaines données n'ont pas pu être récupérées"),
          CampagneRecrutementItem(onDismiss: () {}),
          CampagneEvaluationItem(titre: "Questionnaire", description: "Super test"),
          AccueilCetteSemaineItem(
            rendezvousCount: "3",
            actionsOuDemarchesCount: "1",
            actionsOuDemarchesLabel: "Démarche",
            withComptageDesHeures: true,
          ),
          AccueilColorSeparatorItem(),
          AccueilProchainRendezvousItem(mockRendezvousPoleEmploi().id),
          AccueilSuiviDesOffresItem(),
          AccueilAlertesItem(getMockedAlerte()),
        ],
      );
    });

    test('should hide rendezvous count section when 0 and accompagnement RSA Conseils Départementaux', () {
      // Given
      final store =
          givenState() //
              .loggedInUser(loginMode: LoginMode.POLE_EMPLOI, accompagnement: Accompagnement.rsaConseilsDepartementaux)
              .copyWith(accueilState: AccueilSuccessState(mockAccueilPoleEmploi(nombreRendezVous: 0)))
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items[0],
        AccueilCetteSemaineItem(
          rendezvousCount: null,
          actionsOuDemarchesCount: "1",
          actionsOuDemarchesLabel: "Démarche",
          withComptageDesHeures: true,
        ),
      );
    });
  });

  group('shouldResetDeeplink', () {
    group('should return true when deeplink only needs one page to be opened', () {
      test('ActionDeepLink > no double opening of pages required', () {
        // Given
        final store = givenState().withHandleDeepLink(ActionDeepLink('id')).store();

        // When
        final viewModel = AccueilViewModel.create(store);

        // Then
        expect(viewModel.shouldResetDeeplink, isTrue);
      });

      test('RendezvousDeepLink > no double opening of pages required', () {
        // Given
        final store = givenState().withHandleDeepLink(RendezvousDeepLink('id')).store();

        // When
        final viewModel = AccueilViewModel.create(store);

        // Then
        expect(viewModel.shouldResetDeeplink, isTrue);
      });

      test('SessionMiloDeepLink > no double opening of pages required', () {
        // Given
        final store = givenState().withHandleDeepLink(SessionMiloDeepLink('id')).store();

        // When
        final viewModel = AccueilViewModel.create(store);

        // Then
        expect(viewModel.shouldResetDeeplink, isTrue);
      });

      test('AlertesDeepLink > no double opening of pages required', () {
        // Given
        final store = givenState().withHandleDeepLink(AlertesDeepLink()).store();

        // When
        final viewModel = AccueilViewModel.create(store);

        // Then
        expect(viewModel.shouldResetDeeplink, isTrue);
      });

      test('BenevolatDeepLink > no double opening of pages required', () {
        // Given
        final store = givenState().withHandleDeepLink(BenevolatDeepLink()).store();

        // When
        final viewModel = AccueilViewModel.create(store);

        // Then
        expect(viewModel.shouldResetDeeplink, isTrue);
      });

      test('LaBonneAlternanceDeepLink > no double opening of pages required', () {
        // Given
        final store = givenState().withHandleDeepLink(LaBonneAlternanceDeepLink()).store();

        // When
        final viewModel = AccueilViewModel.create(store);

        // Then
        expect(viewModel.shouldResetDeeplink, isTrue);
      });
    });

    group('should return false when deeplink needs two pages to be opened', () {
      test('AlerteDeepLink > double opening of pages required', () {
        // Given
        final store = givenState().withHandleDeepLink(AlerteDeepLink(idAlerte: 'id')).store();

        // When
        final viewModel = AccueilViewModel.create(store);

        // Then
        expect(viewModel.shouldResetDeeplink, isFalse);
      });

      test('RappelCreationDemarcheDeepLink > double opening of pages required', () {
        // Given
        final store = givenState().withHandleDeepLink(CreationDemarcheDeepLink()).store();

        // When
        final viewModel = AccueilViewModel.create(store);

        // Then
        expect(viewModel.shouldResetDeeplink, isFalse);
      });

      test('RappelCreationActionDeepLink > double opening of pages required', () {
        // Given
        final store = givenState().withHandleDeepLink(CreationActionDeepLink()).store();

        // When
        final viewModel = AccueilViewModel.create(store);

        // Then
        expect(viewModel.shouldResetDeeplink, isFalse);
      });
    });
  });

  test('should retry', () {
    // Given
    final store = StoreSpy();
    final viewModel = AccueilViewModel.create(store);

    // When
    viewModel.retry();

    // Then
    expect(store.dispatchedAction, isA<AccueilRequestAction>());
  });

  test('should not show cetteSemaine and prochainRendezVous items when accompagnement is Avenir Pro', () {
    // Given
    final store = givenState()
        .loggedInUser(accompagnement: Accompagnement.avenirPro)
        .withAccueilPoleEmploiSuccess()
        .store();

    // When
    final viewModel = AccueilViewModel.create(store);

    // Then
    expect(
      viewModel.items.whereType<AccueilCetteSemaineItem>().isEmpty,
      isTrue,
    );
    expect(
      viewModel.items.whereType<AccueilProchainRendezvousItem>().isEmpty,
      isTrue,
    );
  });

  group('withNewNotifications', () {
    test('should not show new notifications when in app notifications is not success state', () {
      // Given
      final store = givenState().loggedInMiloUser().withInAppNotificationsLoading().store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.withNewNotifications,
        isFalse,
      );
    });

    test('should not show new notifications when there is no notification', () {
      // Given
      final store =
          givenState() //
              .loggedInMiloUser()
              .withInAppNotificationsSuccess([])
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.withNewNotifications,
        isFalse,
      );
    });

    test('should not show new notifications when notification is older than last consultation date', () {
      // Given
      final store =
          givenState() //
              .loggedInMiloUser()
              .copyWith(dateConsultationNotificationState: DateConsultationNotificationState(date: DateTime(2025)))
              .withInAppNotificationsSuccess([mockInAppNotification(date: DateTime(2024))])
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.withNewNotifications,
        isFalse,
      );
    });

    test('should show new notifications when notification is newer than last consultation date', () {
      // Given
      final store =
          givenState() //
              .loggedInMiloUser()
              .copyWith(dateConsultationNotificationState: DateConsultationNotificationState(date: DateTime(2024)))
              .withInAppNotificationsSuccess([mockInAppNotification(date: DateTime(2025))])
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.withNewNotifications,
        isTrue,
      );
    });
  });

  group('remoteCampagneAccueilItems', () {
    test('should display remote campagnes items', () {
      // Given
      final campagne = RemoteCampagneAccueil(
        id: "1",
        title: "title",
        cta: "cta",
        url: "url",
        brand: null,
        dateFin: DateTime(2035),
        dateDebut: DateTime(2024),
        accompagnements: [Accompagnement.cej],
      );
      final store =
          givenState() //
              .loggedInPoleEmploiUser()
              .withAccueilPoleEmploiSuccess()
              .withRemoteCampagneAccueil(campagnes: [campagne]) //
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items.first,
        RemoteCampagneAccueilItem(
          title: "title",
          cta: "cta",
          url: "url",
          onDismissed: () {},
        ),
      );
    });

    test('should not display remote campagnes items from others accompagnements', () {
      // Given
      final campagne = RemoteCampagneAccueil(
        id: "1",
        title: "title",
        cta: "cta",
        url: "url",
        brand: null,
        dateFin: DateTime(2035),
        dateDebut: DateTime(2024),
        accompagnements: [Accompagnement.avenirPro],
      );
      final store =
          givenState() //
              .loggedInPoleEmploiUser()
              .withAccueilPoleEmploiSuccess()
              .withRemoteCampagneAccueil(campagnes: [campagne]) //
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items.first,
        isNot(
          RemoteCampagneAccueilItem(
            title: "title",
            cta: "cta",
            url: "url",
            onDismissed: () {},
          ),
        ),
      );
    });

    test('should not display remote campagnes items from others apps', () {
      // Given
      final campagne = RemoteCampagneAccueil(
        id: "1",
        title: "title",
        cta: "cta",
        url: "url",
        brand: Brand.cej,
        dateFin: DateTime(2035),
        dateDebut: DateTime(2024),
        accompagnements: [Accompagnement.cej],
      );
      final store =
          givenPassEmploiState() //
              .loggedInPoleEmploiUser()
              .withAccueilPoleEmploiSuccess()
              .withRemoteCampagneAccueil(campagnes: [campagne]) //
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items.first,
        isNot(
          RemoteCampagneAccueilItem(
            title: "title",
            cta: "cta",
            url: "url",
            onDismissed: () {},
          ),
        ),
      );
    });

    test('should not display remote campagnes when finished', () {
      // Given
      final campagne = RemoteCampagneAccueil(
        id: "1",
        title: "title",
        cta: "cta",
        url: "url",
        brand: null,
        dateFin: DateTime(2024),
        dateDebut: DateTime(2024),
        accompagnements: [Accompagnement.cej],
      );
      final store =
          givenPassEmploiState() //
              .loggedInPoleEmploiUser()
              .withAccueilPoleEmploiSuccess()
              .withRemoteCampagneAccueil(campagnes: [campagne]) //
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items.first,
        isNot(
          RemoteCampagneAccueilItem(
            title: "title",
            cta: "cta",
            url: "url",
            onDismissed: () {},
          ),
        ),
      );
    });

    test('should not display remote campagnes when not started', () {
      // Given
      final campagne = RemoteCampagneAccueil(
        id: "1",
        title: "title",
        cta: "cta",
        url: "url",
        brand: null,
        dateFin: DateTime(2044),
        dateDebut: DateTime(2044),
        accompagnements: [Accompagnement.cej],
      );
      final store =
          givenPassEmploiState() //
              .loggedInPoleEmploiUser()
              .withAccueilPoleEmploiSuccess()
              .withRemoteCampagneAccueil(campagnes: [campagne]) //
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items.first,
        isNot(
          RemoteCampagneAccueilItem(
            title: "title",
            cta: "cta",
            url: "url",
            onDismissed: () {},
          ),
        ),
      );
    });
  });
  group('offre suivi item', () {
    test('should display offre suivi item when offre suivie is present', () {
      // Given
      final store =
          givenPassEmploiState() //
              .loggedInPoleEmploiUser()
              .withAccueilPoleEmploiSuccess()
              .withOffreSuiviState([mockOffreSuivie()])
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items.firstWhere((element) => element is OffreSuivieAccueilItem),
        OffreSuivieAccueilItem(offreId: mockOffreSuivie().offreDto.id),
      );
    });

    test('should not display any favori created before 3 days', () {
      // Given
      final store =
          givenPassEmploiState() //
              .loggedInPoleEmploiUser()
              .withAccueilPoleEmploiSuccess()
              .favoriListSuccessState(
                [mockFavori(dateDeCreation: DateTime.now().subtract(Duration(days: 2)))],
              )
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(viewModel.items.firstWhereOrNull((element) => element is OffreSuivieAccueilItem), isNull);
    });

    test('should display favori created after 3 days', () {
      // Given
      final store =
          givenPassEmploiState() //
              .loggedInPoleEmploiUser()
              .withAccueilPoleEmploiSuccess()
              .favoriListSuccessState(
                [mockFavori(dateDeCreation: DateTime.now().subtract(Duration(days: 4)))],
              )
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items.firstWhere((element) => element is OffreSuivieAccueilItem),
        OffreSuivieAccueilItem(offreId: mockFavori().id),
      );
    });

    test('should not display favori blacklisted', () {
      // Given
      final store =
          givenPassEmploiState() //
              .loggedInPoleEmploiUser()
              .withAccueilPoleEmploiSuccess()
              .withOffreSuiviState([], blackListedOffreIds: [mockFavori().id]) //
              .favoriListSuccessState(
                [mockFavori(dateDeCreation: DateTime.now().subtract(Duration(days: 4)))],
              )
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(viewModel.items.firstWhereOrNull((element) => element is OffreSuivieAccueilItem), isNull);
    });

    test('should display offre suivi when favori update confirmation ID is present', () {
      // Given
      final store =
          givenPassEmploiState() //
              .loggedInPoleEmploiUser()
              .withAccueilPoleEmploiSuccess()
              .copyWith(
                favoriUpdateState: FavoriUpdateState(
                  {},
                  confirmationOffre: ConfirmationOffre(offreId: "test", newStatus: FavoriStatus.removed),
                ),
              )
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items.firstWhere((element) => element is OffreSuivieAccueilItem),
        OffreSuivieAccueilItem(offreId: "test"),
      );
    });

    test('should display offre suivi when offre suivi confirmation ID is present', () {
      // Given
      final store =
          givenPassEmploiState() //
              .loggedInPoleEmploiUser()
              .withAccueilPoleEmploiSuccess()
              .withOffreSuiviState(
                [],
                confirmationOffre: ConfirmationOffre(offreId: "test", newStatus: FavoriStatus.removed),
              )
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(
        viewModel.items.firstWhere((element) => element is OffreSuivieAccueilItem),
        OffreSuivieAccueilItem(offreId: "test"),
      );
    });
  });

  group('shouldShowAllowNotifications', () {
    test('should show allow notifications when not asked before', () {
      // Given
      final store =
          givenState() //
              .loggedInMiloUser()
              .withOnboardingSuccessState(mockOnboarding(showNotificationsOnboarding: true))
              .withAccueilMiloSuccess()
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(viewModel.shouldShowAllowNotifications, isTrue);
    });

    test('should not show allow notifications when already asked', () {
      // Given
      final store =
          givenState() //
              .loggedInMiloUser()
              .withAccueilMiloSuccess()
              .withOnboardingSuccessState(
                mockOnboarding(
                  showNotificationsOnboarding: false,
                ),
              )
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(viewModel.shouldShowAllowNotifications, isFalse);
    });
  });

  group('onboarding', () {
    test('should show onboarding when not completed', () {
      // Given
      final store =
          givenState() //
              .loggedInMiloUser()
              .withOnboardingSuccessState(mockOnboarding(showNotificationsOnboarding: true))
              .withAccueilMiloSuccess()
              .store();

      // When
      final viewModel = AccueilViewModel.create(store);

      // Then
      expect(viewModel.items.first, OnboardingItem(completedSteps: 1, totalSteps: 6));
    });
  });
}
