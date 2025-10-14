import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/favori/ids/favori_ids_state.dart';
import 'package:pass_emploi_app/features/favori/update/favori_update_state.dart';
import 'package:pass_emploi_app/features/offres_suivies/offres_suivies_state.dart';
import 'package:pass_emploi_app/models/offre_dto.dart';
import 'package:pass_emploi_app/models/offre_emploi_details.dart';
import 'package:pass_emploi_app/models/offre_suivie.dart';
import 'package:pass_emploi_app/presentation/offre_suivie_form_viewmodel.dart';
import 'package:pass_emploi_app/repositories/favoris/favoris_repository.dart';

import '../doubles/fixtures.dart';
import '../dsl/app_state_dsl.dart';
import '../features/mon_suivi/mon_suivi_test.dart';

void main() {
  final offre = mockOffreEmploiDetails();
  final offreId = offre.id;
  group('OffreSuivieFormViewmodel', () {
    group('home page', () {
      test('should show offre suivie', () {
        withClock(Clock.fixed(mercredi14Fevrier12h00), () {
          // Given
          final store = givenState() //
              .loggedInPoleEmploiUser()
              .offreEmploiDetailsSuccess()
              .copyWith(
                offresSuiviesState: OffresSuiviesState(
                  offresSuivies: [
                    OffreSuivie(
                      dateConsultation: DateTime(2023),
                      offreDto: OffreEmploiDto(offre.toOffreEmploi),
                    ),
                  ],
                ),
              )
              .store();

          // When
          final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

          // Then
          expect(viewModel.dateConsultation, "Vous avez consulté cette offre il y a 409 jours");
          expect(viewModel.offreLien, "Technicien / Technicienne d'installation de réseaux câblés  (H/F)");
          expect(viewModel.showConfirmation, false);
          expect(viewModel.confirmationMessage, null);
        });
      });

      test('should show offre suivie confirmation', () {
        withClock(Clock.fixed(mercredi14Fevrier12h00), () {
          // Given
          final store = givenState() //
              .loggedInPoleEmploiUser()
              .offreEmploiDetailsSuccess()
              .copyWith(
                offresSuiviesState: OffresSuiviesState(
                  offresSuivies: [
                    OffreSuivie(
                      dateConsultation: DateTime(2023),
                      offreDto: OffreEmploiDto(offre.toOffreEmploi),
                    ),
                  ],
                  confirmationOffreId: mockOffreEmploiDetails().id,
                ),
              )
              .store();

          // When
          final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

          // Then
          expect(viewModel.dateConsultation, "Vous avez consulté cette offre il y a 409 jours");
          expect(viewModel.offreLien, "Technicien / Technicienne d'installation de réseaux câblés  (H/F)");
          expect(viewModel.showConfirmation, true);
          expect(viewModel.confirmationMessage, null);
          expect(viewModel.confirmationButton, 'Voir l’offre suivante');
        });
      });

      test('should show offre suivie confirmation when in favoris', () {
        withClock(Clock.fixed(mercredi14Fevrier12h00), () {
          // Given
          final store = givenState() //
              .loggedInPoleEmploiUser()
              .offreEmploiDetailsSuccess()
              .copyWith(
                offreEmploiFavorisIdsState: FavoriIdsState.success({FavoriDto(mockOffreEmploiDetails().id)}),
              )
              .copyWith(
                offresSuiviesState: OffresSuiviesState(
                  offresSuivies: [
                    OffreSuivie(
                      dateConsultation: DateTime(2023),
                      offreDto: OffreEmploiDto(offre.toOffreEmploi),
                    ),
                  ],
                  confirmationOffreId: mockOffreEmploiDetails().id,
                ),
              )
              .store();

          // When
          final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

          // Then
          expect(viewModel.offreLien, "Technicien / Technicienne d'installation de réseaux câblés  (H/F)");
          expect(viewModel.showConfirmation, true);
          expect(viewModel.confirmationMessage, 'Souhaitez-vous créer la démarche ? ');
          expect(viewModel.confirmationButton, 'Voir l’offre suivante');
        });
      });
    });

    group('_showConfirmation', () {
      test('should return true when confirmationFavoris is true', () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .offreEmploiDetailsSuccess()
            .copyWith(
              favoriUpdateState: FavoriUpdateState(
                {},
                confirmationPostuleOffreId: offreId,
              ),
            )
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

        // Then
        expect(viewModel.showConfirmation, true);
      });

      test('should return true when confirmationOffreSuivie is true', () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .offreEmploiDetailsSuccess()
            .copyWith(
              offresSuiviesState: OffresSuiviesState(
                offresSuivies: [],
                confirmationOffreId: mockOffreEmploiDetails().id,
              ),
            )
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

        // Then
        expect(viewModel.showConfirmation, true);
      });

      test('should return true when both confirmationFavoris and confirmationOffreSuivie are true', () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .offreEmploiDetailsSuccess()
            .copyWith(
              favoriUpdateState: FavoriUpdateState(
                {},
                confirmationPostuleOffreId: offreId,
              ),
              offresSuiviesState: OffresSuiviesState(
                offresSuivies: [],
                confirmationOffreId: mockOffreEmploiDetails().id,
              ),
            )
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

        // Then
        expect(viewModel.showConfirmation, true);
      });

      test('should return false when neither confirmationFavoris nor confirmationOffreSuivie are true', () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .offreEmploiDetailsSuccess()
            .copyWith(
              favoriUpdateState: FavoriUpdateState(
                {},
                confirmationPostuleOffreId: null,
              ),
              offresSuiviesState: OffresSuiviesState(
                offresSuivies: [],
                confirmationOffreId: null,
              ),
            )
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

        // Then
        expect(viewModel.showConfirmation, false);
      });

      test('should return false when confirmationFavoris is for different offre', () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .offreEmploiDetailsSuccess()
            .copyWith(
              favoriUpdateState: FavoriUpdateState(
                {},
                confirmationPostuleOffreId: "different-offre-id",
              ),
              offresSuiviesState: OffresSuiviesState(
                offresSuivies: [],
                confirmationOffreId: null,
              ),
            )
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

        // Then
        expect(viewModel.showConfirmation, false);
      });

      test('should return false when confirmationOffreSuivie is for different offre', () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .offreEmploiDetailsSuccess()
            .copyWith(
              favoriUpdateState: FavoriUpdateState(
                {},
                confirmationPostuleOffreId: null,
              ),
              offresSuiviesState: OffresSuiviesState(
                offresSuivies: [],
                confirmationOffreId: "different-offre-id",
              ),
            )
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

        // Then
        expect(viewModel.showConfirmation, false);
      });

      test('should return true when confirmationFavoris is true even if confirmationOffreSuivie is for different offre',
          () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .offreEmploiDetailsSuccess()
            .copyWith(
              favoriUpdateState: FavoriUpdateState(
                {},
                confirmationPostuleOffreId: offreId,
              ),
              offresSuiviesState: OffresSuiviesState(
                offresSuivies: [],
                confirmationOffreId: "different-offre-id",
              ),
            )
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

        // Then
        expect(viewModel.showConfirmation, true);
      });

      test('should return true when confirmationOffreSuivie is true even if confirmationFavoris is for different offre',
          () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .offreEmploiDetailsSuccess()
            .copyWith(
              favoriUpdateState: FavoriUpdateState(
                {},
                confirmationPostuleOffreId: "different-offre-id",
              ),
              offresSuiviesState: OffresSuiviesState(
                offresSuivies: [],
                confirmationOffreId: offre.id,
              ),
            )
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

        // Then
        expect(viewModel.showConfirmation, true);
      });
    });

    group('_onNotYetPostuled', () {
      // should return null when isFavorisNonPostule is false and isHomePage is true
      test('should return null when isFavorisNonPostule is false and isHomePage is true', () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .favoriListSuccessState([mockFavori(id: mockOffreEmploiDetails().id, datePostulation: DateTime(2025))])
            .offreEmploiDetailsSuccess()
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

        // Then
        expect(viewModel.onNotYetPostuled, isNull);
      });

      test('should return null when isFavorisNonPostule is true and isHomePage is false', () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .favoriListSuccessState([mockFavoriNonPostule(id: mockOffreEmploiDetails().id)])
            .offreEmploiDetailsSuccess()
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, false);

        // Then
        expect(viewModel.onNotYetPostuled, isNull);
      });

      test('should return function when isFavorisNonPostule is true and isHomePage is true', () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .favoriListSuccessState([mockFavoriNonPostule(id: mockOffreEmploiDetails().id)])
            .offreEmploiDetailsSuccess()
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

        // Then
        expect(viewModel.onNotYetPostuled, isNotNull);
      });
    });

    group('dateConsultation', () {
      test('should return null when isFavorisNonPostule is true and isHomePage is false', () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .favoriListSuccessState([mockFavoriNonPostule(id: mockOffreEmploiDetails().id)])
            .offreEmploiDetailsSuccess()
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, false);

        // Then
        expect(viewModel.dateConsultation, isNull);
      });

      test('should return date when isFavorisNonPostule is true and isHomePage is true', () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .favoriListSuccessState([mockFavoriNonPostule(id: mockOffreEmploiDetails().id)])
            .offreEmploiDetailsSuccess()
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

        // Then
        expect(viewModel.dateConsultation, isNotNull);
        expect(viewModel.dateConsultation!.contains("enregistré"), isTrue);
      });

      test('should return date when offreSuivie is not null', () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .offreEmploiDetailsSuccess()
            .withOffreSuiviState([mockOffreSuivie(id: mockOffreEmploiDetails().id)]).store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

        // Then
        expect(viewModel.dateConsultation, isNotNull);
        expect(viewModel.dateConsultation!.contains("consulté"), isTrue);
      });

      test('should return null when offreSuivie is null', () {
        // Given
        final store = givenState() //
            .loggedInPoleEmploiUser()
            .offreEmploiDetailsSuccess()
            .store();

        // When
        final viewModel = OffreSuivieFormViewmodel.create(store, offreId, true);

        // Then
        expect(viewModel.dateConsultation, isNull);
      });
    });
  });
}
