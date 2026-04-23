import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/immersion/details/immersion_details_actions.dart';
import 'package:pass_emploi_app/features/immersion/details/immersion_details_state.dart';
import 'package:pass_emploi_app/models/immersion.dart';
import 'package:pass_emploi_app/models/immersion_contact.dart';
import 'package:pass_emploi_app/models/immersion_details.dart';
import 'package:pass_emploi_app/presentation/immersion/immersion_details_view_model.dart';
import 'package:pass_emploi_app/redux/app_reducer.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:redux/redux.dart';

import '../../doubles/spies.dart';
import '../../dsl/app_state_dsl.dart';

void main() {
  test('create when state is loading should set display state properly', () {
    // Given
    final store = _store(ImmersionDetailsLoadingState());

    // When
    final viewModel = ImmersionDetailsViewModel.create(store, Platform.ANDROID);

    // Then
    expect(viewModel.displayState, ImmersionDetailsPageDisplayState.SHOW_LOADER);
  });

  test('create when state is failure should set display state properly', () {
    // Given
    final store = _store(ImmersionDetailsFailureState());

    // When
    final viewModel = ImmersionDetailsViewModel.create(store, Platform.ANDROID);

    // Then
    expect(viewModel.displayState, ImmersionDetailsPageDisplayState.SHOW_ERROR);
  });

  test('create when state is success should set display state properly and fill generic immersion info', () {
    // Given
    final store = _store(ImmersionDetailsSuccessState(_mockImmersion()));

    // When
    final viewModel = ImmersionDetailsViewModel.create(store, Platform.ANDROID);

    // Then
    expect(viewModel.displayState, ImmersionDetailsPageDisplayState.SHOW_DETAILS);
    expect(viewModel.id, '12345');
    expect(viewModel.title, 'Métier');
    expect(viewModel.companyName, 'Nom établissement');
    expect(viewModel.secteurActivite, 'Secteur');
    expect(viewModel.ville, 'Ville');
    expect(viewModel.address, 'Adresse');
  });

  test("getDetails when state is incomplete data should set display state properly and convert data to view model", () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState:
          AppState.initialState() //
              .offreDateDerniereConsultation({"10298": DateTime(2024, 1, 1)}) //
              .copyWith(
                immersionDetailsState: ImmersionDetailsIncompleteDataState(
                  Immersion(
                    id: "10298",
                    siret: "",
                    appellationCode: "",
                    locationId: "",
                    metier: "incomplete-metier",
                    ville: "incomplete-ville",
                    secteurActivite: "incomplete-secteur",
                    nomEtablissement: "incomplete-nom",
                  ),
                ),
              ),
    );

    // When
    final viewModel = ImmersionDetailsViewModel.create(store, Platform.ANDROID);

    // Then
    expect(viewModel.displayState, ImmersionDetailsPageDisplayState.SHOW_INCOMPLETE_DETAILS);
    expect(viewModel.id, "10298");
    expect(viewModel.title, "incomplete-metier");
    expect(viewModel.companyName, "incomplete-nom");
    expect(viewModel.secteurActivite, "incomplete-secteur");
    expect(viewModel.ville, "incomplete-ville");
    expect(viewModel.dateDerniereConsultation, DateTime(2024, 1, 1));
    expect(viewModel.address, isNull);
    expect(viewModel.fitForDisabledWorkers, isFalse);
    expect(viewModel.contactInformation, isNull);
    expect(viewModel.withSecondaryCallToActions, isNull);
    expect(viewModel.secondaryCallToActions, isNull);
  });

  group('fit for disabled workers', () {
    test('when fit for disabled workers should return true', () {
      // Given
      final store = _successStore(_mockImmersion(fitForDisabledWorkers: true));

      // When
      final viewModel = ImmersionDetailsViewModel.create(store, Platform.ANDROID);

      // Then
      expect(viewModel.fitForDisabledWorkers, isTrue);
    });

    test('when entreprise is not accueillante should return false', () {
      // Given
      final store = _successStore(_mockImmersion(fitForDisabledWorkers: false));

      // When
      final viewModel = ImmersionDetailsViewModel.create(store, Platform.ANDROID);

      // Then
      expect(viewModel.fitForDisabledWorkers, isFalse);
    });
  });
  group('Contact information…', () {
    test('when contact is not set', () {
      // Given
      final store = _successStore(_mockImmersionWithContact(address: "Address"));

      // When
      final viewModel = ImmersionDetailsViewModel.create(store, Platform.ANDROID);

      // Then
      expect(viewModel.contactInformation, 'Address');
    });

    test('when contact mode is PRESENTIEL should only display address', () {
      // Given
      final store = _successStore(
        _mockImmersionWithContact(
          contactMode: ImmersionContactMode.PRESENTIEL,
          address: "Address",
        ),
      );

      // When
      final viewModel = ImmersionDetailsViewModel.create(store, Platform.ANDROID);

      // Then
      expect(viewModel.contactInformation, 'Address');
    });
  });

  test('View model triggers ImmersionDetailsAction.request() when onRetry is performed', () {
    final store = StoreSpy();
    final viewModel = ImmersionDetailsViewModel.create(store, Platform.ANDROID);

    viewModel.onRetry("immersion-id");

    expect(store.dispatchedAction, isA<ImmersionDetailsRequestAction>());
    expect((store.dispatchedAction as ImmersionDetailsRequestAction).immersionId, "immersion-id");
  });
}

Store<AppState> _store(ImmersionDetailsState immersionDetailsState) {
  return Store<AppState>(
    reducer,
    initialState: AppState.initialState().copyWith(immersionDetailsState: immersionDetailsState),
  );
}

Store<AppState> _successStore(ImmersionDetails immersion) => _store(ImmersionDetailsSuccessState(immersion));

ImmersionDetails _mockImmersion({
  bool fitForDisabledWorkers = false,
  ImmersionContactMode mode = ImmersionContactMode.INCONNU,
}) {
  return ImmersionDetails(
    id: '12345',
    siret: 'Siret',
    appellationCode: 'appellationCode',
    locationId: 'locationId',
    metier: 'Métier',
    companyName: 'Nom établissement',
    secteurActivite: 'Secteur',
    ville: 'Ville',
    address: 'Adresse',
    informationComplementaire: 'Information complémentaire',
    website: '',
    fitForDisabledWorkers: fitForDisabledWorkers,
    contactMode: mode,
  );
}

ImmersionDetails _mockImmersionWithContact({String? address, ImmersionContactMode? contactMode}) {
  return ImmersionDetails(
    id: '',
    siret: '',
    appellationCode: '',
    locationId: '',
    metier: '',
    companyName: '',
    secteurActivite: '',
    ville: '',
    address: address ?? '',
    informationComplementaire: 'Information complémentaire',
    website: '',
    fitForDisabledWorkers: false,
    contactMode: contactMode ?? ImmersionContactMode.INCONNU,
  );
}
