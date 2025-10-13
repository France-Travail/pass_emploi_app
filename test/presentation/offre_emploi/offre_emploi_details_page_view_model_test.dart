import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/favori/ids/favori_ids_state.dart';
import 'package:pass_emploi_app/features/favori/update/favori_update_state.dart';
import 'package:pass_emploi_app/features/offres_suivies/offres_suivies_state.dart';
import 'package:pass_emploi_app/models/image_source.dart';
import 'package:pass_emploi_app/models/offre_dto.dart';
import 'package:pass_emploi_app/models/offre_emploi.dart';
import 'package:pass_emploi_app/models/offre_emploi_details.dart';
import 'package:pass_emploi_app/models/offre_suivie.dart';
import 'package:pass_emploi_app/presentation/offre_emploi/offre_emploi_details_page_view_model.dart';
import 'package:pass_emploi_app/presentation/offre_emploi/offre_emploi_origin_view_model.dart';
import 'package:pass_emploi_app/repositories/favoris/favoris_repository.dart';

import '../../doubles/fixtures.dart';
import '../../dsl/app_state_dsl.dart';

void main() {
  test("getDetails when state is loading should set display state properly", () {
    // Given
    final store = givenState().loggedIn().offreEmploiDetailsLoading().store();

    // When
    final viewModel = OffreEmploiDetailsPageViewModel.create(store);

    // Then
    expect(viewModel.displayState, OffreEmploiDetailsPageDisplayState.SHOW_LOADER);
  });

  test("getDetails when state is failure should set display state properly", () {
    // Given
    final store = givenState().loggedIn().offreEmploiDetailsFailure().store();

    // When
    final viewModel = OffreEmploiDetailsPageViewModel.create(store);

    // Then
    expect(viewModel.displayState, OffreEmploiDetailsPageDisplayState.SHOW_ERROR);
  });

  test("getDetails when state is success should set display state properly and convert data to view model", () {
    withClock(Clock.fixed(DateTime(2021, 12, 1)), () {
      // Given
      final detailedOffer = mockOffreEmploiDetails();
      final store = givenState()
          .loggedInPoleEmploiUser()
          .offreDateDerniereConsultation({detailedOffer.id: DateTime(2024, 1, 1)})
          .offreEmploiDetailsSuccess(offreEmploiDetails: detailedOffer)
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.displayState, OffreEmploiDetailsPageDisplayState.SHOW_DETAILS);
      expect(viewModel.id, detailedOffer.id);
      expect(viewModel.title, detailedOffer.title);
      expect(viewModel.urlRedirectPourPostulation, detailedOffer.urlRedirectPourPostulation);
      expect(viewModel.companyName, detailedOffer.companyName);
      expect(viewModel.contractType, detailedOffer.contractType);
      expect(viewModel.dateDerniereConsultation, DateTime(2024, 1, 1));
      expect(viewModel.duration, detailedOffer.duration);
      expect(viewModel.location, detailedOffer.location);
      expect(viewModel.salary, detailedOffer.salary);
      expect(viewModel.description, detailedOffer.description);
      expect(viewModel.experience, detailedOffer.experience);
      expect(viewModel.requiredExperience, detailedOffer.requiredExperience);
      expect(viewModel.companyUrl, detailedOffer.companyUrl);
      expect(viewModel.companyAdapted, detailedOffer.companyAdapted);
      expect(viewModel.companyAccessibility, detailedOffer.companyAccessibility);
      expect(viewModel.companyDescription, detailedOffer.companyDescription);
      expect(viewModel.lastUpdate, "il y a 8 jours");
      expect(viewModel.skills, detailedOffer.skills);
      expect(viewModel.softSkills, detailedOffer.softSkills);
      expect(
          viewModel.educations, [EducationViewModel("Bac+5 et plus ou équivalents conduite projet industriel", "E")]);
      expect(viewModel.languages, detailedOffer.languages);
      expect(viewModel.driverLicences, detailedOffer.driverLicences);
    });
  });

  test("getDetails when state is incomplete data should set display state properly and convert data to view model", () {
    // Given
    final offreEmploi = mockOffreEmploi();
    final store = givenState() //
        .loggedInPoleEmploiUser()
        .offreEmploiDetailsIncompleteData(offreEmploi: offreEmploi)
        .store();

    // When
    final viewModel = OffreEmploiDetailsPageViewModel.create(store);

    // Then
    expect(viewModel.displayState, OffreEmploiDetailsPageDisplayState.SHOW_INCOMPLETE_DETAILS);
    expect(viewModel.id, "123DXPM");
    expect(viewModel.title, "Technicien / Technicienne en froid et climatisation");
    expect(viewModel.urlRedirectPourPostulation, null);
    expect(viewModel.companyName, "RH TT INTERIM");
    expect(viewModel.contractType, "MIS");
    expect(viewModel.duration, "Temps plein");
    expect(viewModel.location, "77 - LOGNES");
    expect(viewModel.salary, null);
    expect(viewModel.description, null);
    expect(viewModel.experience, null);
    expect(viewModel.requiredExperience, null);
    expect(viewModel.companyUrl, null);
    expect(viewModel.companyAdapted, null);
    expect(viewModel.companyAccessibility, null);
    expect(viewModel.companyDescription, null);
    expect(viewModel.lastUpdate, null);
    expect(viewModel.skills, null);
    expect(viewModel.softSkills, null);
    expect(viewModel.educations, null);
    expect(viewModel.languages, null);
    expect(viewModel.driverLicences, null);
  });

  test("getDetails should remove new line from duration field", () {
    // Given
    final store = givenState() //
        .loggedInPoleEmploiUser()
        .offreEmploiDetailsIncompleteData(offreEmploi: mockOffreEmploi(duration: '35h\nTravail en journée'))
        .store();

    // When
    final viewModel = OffreEmploiDetailsPageViewModel.create(store);

    // Then
    expect(viewModel.displayState, OffreEmploiDetailsPageDisplayState.SHOW_INCOMPLETE_DETAILS);
    expect(viewModel.id, "123DXPM");
    expect(viewModel.title, "Technicien / Technicienne en froid et climatisation");
    expect(viewModel.urlRedirectPourPostulation, null);
    expect(viewModel.companyName, "RH TT INTERIM");
    expect(viewModel.contractType, "MIS");
    expect(viewModel.duration, "35h - Travail en journée");
    expect(viewModel.location, "77 - LOGNES");
    expect(viewModel.salary, null);
    expect(viewModel.description, null);
    expect(viewModel.experience, null);
    expect(viewModel.requiredExperience, null);
    expect(viewModel.companyUrl, null);
    expect(viewModel.companyAdapted, null);
    expect(viewModel.companyAccessibility, null);
    expect(viewModel.companyDescription, null);
    expect(viewModel.lastUpdate, null);
    expect(viewModel.skills, null);
    expect(viewModel.softSkills, null);
    expect(viewModel.educations, null);
    expect(viewModel.languages, null);
    expect(viewModel.driverLicences, null);
  });

  group("shouldShowCvBottomSheet", () {
    test("is false with Milo account", () {
      // Given
      final store = givenState().loggedInMiloUser().offreEmploiDetailsSuccess().store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.shouldShowCvBottomSheet, false);
    });

    test("is true with PoleEmploi account", () {
      // Given
      final store = givenState().loggedInPoleEmploiUser().offreEmploiDetailsSuccess().store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.shouldShowCvBottomSheet, true);
    });
  });

  group("origin", () {
    test('when origin is France Travail', () {
      // Given
      final store = givenState() //
          .loggedInPoleEmploiUser()
          .offreEmploiDetailsSuccess(
            offreEmploiDetails: mockOffreEmploiDetails(origin: FranceTravailOrigin()),
          )
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(
        viewModel.originViewModel,
        OffreEmploiOriginViewModel(
          "France Travail",
          AssetsImageSource("assets/logo-france-travail.webp"),
        ),
      );
    });

    test('when origin is partenaire', () {
      // Given
      final store = givenState() //
          .loggedInPoleEmploiUser()
          .offreEmploiDetailsSuccess(
            offreEmploiDetails: mockOffreEmploiDetails(
              origin: PartenaireOrigin(
                name: "Indeed",
                logoUrl: "http://logo-indeed.jpg",
              ),
            ),
          )
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(
        viewModel.originViewModel,
        OffreEmploiOriginViewModel(
          "Indeed",
          NetworkImageSource("http://logo-indeed.jpg"),
        ),
      );
    });
  });

  group('offre suivie', () {
    test('should display offre suivie bottom sheet', () {
      // Given
      final store = givenState() //
          .loggedInPoleEmploiUser()
          .offreEmploiDetailsSuccess()
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.shouldShowOffreSuivieBottomSheet, true);
    });

    test('should not display offre suivie bottom sheet when already present in offre suivie state', () {
      // Given
      final store = givenState() //
          .loggedInPoleEmploiUser()
          .offreEmploiDetailsSuccess()
          .copyWith(
            offresSuiviesState: OffresSuiviesState(
              offresSuivies: [
                OffreSuivie(
                  dateConsultation: DateTime(2025),
                  offreDto: OffreEmploiDto(
                    mockOffreEmploiDetails().toOffreEmploi,
                  ),
                )
              ],
            ),
          )
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.shouldShowOffreSuivieBottomSheet, false);
    });

    test('should not display offre suivie bottom sheet when already present in favoris', () {
      // Given
      final store = givenState() //
          .loggedInPoleEmploiUser()
          .offreEmploiDetailsSuccess()
          .copyWith(
            offreEmploiFavorisIdsState: FavoriIdsState.success({FavoriDto(mockOffreEmploiDetails().id)}),
          )
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.shouldShowOffreSuivieBottomSheet, false);
    });
  });

  group('_shouldShowOffreSuiviForm', () {
    test('should display offre suivie form when present in offres suivies', () {
      // Given
      final store = givenState() //
          .loggedInPoleEmploiUser()
          .offreEmploiDetailsSuccess()
          .copyWith(
            offresSuiviesState: OffresSuiviesState(
              offresSuivies: [
                OffreSuivie(
                  dateConsultation: DateTime(2025),
                  offreDto: OffreEmploiDto(
                    mockOffreEmploiDetails().toOffreEmploi,
                  ),
                )
              ],
            ),
          )
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.shouldShowOffreSuiviForm, true);
    });

    test('should display offre suivie form when present in confirmation offre', () {
      // Given
      final store = givenState() //
          .loggedInPoleEmploiUser()
          .offreEmploiDetailsSuccess()
          .copyWith(
            offresSuiviesState: OffresSuiviesState(
              offresSuivies: [],
              confirmationOffre: OffreSuivie(
                dateConsultation: DateTime(2025),
                offreDto: OffreEmploiDto(
                  mockOffreEmploiDetails().toOffreEmploi,
                ),
              ),
            ),
          )
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.shouldShowOffreSuiviForm, true);
    });

    test('should display offre suivie form when is in favoris and not postulated', () {
      // Given
      final store = givenState() //
          .loggedInPoleEmploiUser()
          .offreEmploiDetailsSuccess()
          .copyWith(
            offresSuiviesState: OffresSuiviesState(
              offresSuivies: [],
              confirmationOffre: null,
            ),
            offreEmploiFavorisIdsState: FavoriIdsState.success({
              FavoriDto(
                mockOffreEmploiDetails().id,
                datePostulation: null,
              )
            }),
          )
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.shouldShowOffreSuiviForm, true);
    });

    test('should display offre suivie form when confirmation favoris is true', () {
      // Given
      final store = givenState() //
          .loggedInPoleEmploiUser()
          .offreEmploiDetailsSuccess()
          .copyWith(
            offresSuiviesState: OffresSuiviesState(
              offresSuivies: [],
              confirmationOffre: null,
            ),
            favoriUpdateState: FavoriUpdateState(
              {},
              confirmationPostuleOffreId: mockOffreEmploiDetails().id,
            ),
          )
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.shouldShowOffreSuiviForm, true);
    });

    test('should not display offre suivie form when postulated', () {
      // Given
      final store = givenState() //
          .loggedInPoleEmploiUser()
          .offreEmploiDetailsSuccess()
          .copyWith(
            offresSuiviesState: OffresSuiviesState(
              offresSuivies: [],
              confirmationOffre: null,
            ),
            offreEmploiFavorisIdsState:
                FavoriIdsState.success({FavoriDto(mockOffreEmploiDetails().id, datePostulation: DateTime(2025))}),
          )
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.shouldShowOffreSuiviForm, false);
    });

    test('should not display offre suivie form when not in any list', () {
      // Given
      final store = givenState() //
          .loggedInPoleEmploiUser()
          .offreEmploiDetailsSuccess()
          .copyWith(
            offresSuiviesState: OffresSuiviesState(
              offresSuivies: [],
              confirmationOffre: null,
            ),
            favoriUpdateState: FavoriUpdateState(
              {},
              confirmationPostuleOffreId: null,
            ),
          )
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.shouldShowOffreSuiviForm, false);
    });

    test('should display offre suivie form when both in offres suivies and favoris', () {
      // Given
      final store = givenState() //
          .loggedInPoleEmploiUser()
          .offreEmploiDetailsSuccess()
          .copyWith(
            offresSuiviesState: OffresSuiviesState(
              offresSuivies: [
                OffreSuivie(
                  dateConsultation: DateTime(2025),
                  offreDto: OffreEmploiDto(
                    mockOffreEmploiDetails().toOffreEmploi,
                  ),
                )
              ],
            ),
            offreEmploiFavorisIdsState: FavoriIdsState.success({
              FavoriDto(
                mockOffreEmploiDetails().id,
                datePostulation: null,
              )
            }),
          )
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.shouldShowOffreSuiviForm, true);
    });

    test('should display offre suivie form when in favoris with confirmation and postulated', () {
      // Given
      final store = givenState() //
          .loggedInPoleEmploiUser()
          .offreEmploiDetailsSuccess()
          .copyWith(
            offresSuiviesState: OffresSuiviesState(
              offresSuivies: [],
              confirmationOffre: null,
            ),
            offreEmploiFavorisIdsState:
                FavoriIdsState.success({FavoriDto(mockOffreEmploiDetails().id, datePostulation: DateTime(2025))}),
            favoriUpdateState: FavoriUpdateState(
              {},
              confirmationPostuleOffreId: mockOffreEmploiDetails().id,
            ),
          )
          .store();

      // When
      final viewModel = OffreEmploiDetailsPageViewModel.create(store);

      // Then
      expect(viewModel.shouldShowOffreSuiviForm, true);
    });
  });
}
