import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_state.dart';
import 'package:pass_emploi_app/models/actualite_mission_locale.dart';
import 'package:pass_emploi_app/presentation/actualite_mission_locale/actualite_mission_locale_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';

import '../../dsl/app_state_dsl.dart';

void main() {
  test('create when actualite mission locale state is not initialized', () {
    // Given
    final store = givenState()
        .copyWith(actualiteMissionLocaleState: ActualiteMissionLocaleNotInitializedState())
        .store();

    // When
    final viewModel = ActualiteMissionLocaleViewModel.create(store);

    // Then
    expect(viewModel.displayState, DisplayState.LOADING);
    expect(viewModel.actualites, isEmpty);
  });

  test('create when actualite mission locale state is loading', () {
    // Given
    final store = givenState().copyWith(actualiteMissionLocaleState: ActualiteMissionLocaleLoadingState()).store();

    // When
    final viewModel = ActualiteMissionLocaleViewModel.create(store);

    // Then
    expect(viewModel.displayState, DisplayState.LOADING);
    expect(viewModel.actualites, isEmpty);
  });

  test('create when actualite mission locale state is failure', () {
    // Given
    final store = givenState().copyWith(actualiteMissionLocaleState: ActualiteMissionLocaleFailureState()).store();

    // When
    final viewModel = ActualiteMissionLocaleViewModel.create(store);

    // Then
    expect(viewModel.displayState, DisplayState.FAILURE);
    expect(viewModel.actualites, isEmpty);
  });

  test('create when actualite mission locale state is success and empty', () {
    // Given
    final store = givenState().copyWith(actualiteMissionLocaleState: ActualiteMissionLocaleSuccessState([])).store();

    // When
    final viewModel = ActualiteMissionLocaleViewModel.create(store);

    // Then
    expect(viewModel.displayState, DisplayState.EMPTY);
    expect(viewModel.actualites, isEmpty);
  });

  test('create when actualite mission locale state is success with items', () {
    // Given
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day, 14, 0);
    final deletedDate = now.subtract(Duration(days: 1));
    final olderDate = DateTime(2021, 1, 1, 9, 5);

    final actualites = [
      _actualite(
        titre: 'Titre ancien',
        contenu: 'Corps ancien',
        titreLien: 'Titre lien ancien',
        lien: 'https://old.example.com',
        nomPrenomConseiller: 'Ancien Conseiller',
        dateCreation: olderDate,
      ),
      _actualite(
        titre: 'Titre supprime',
        contenu: 'Corps supprime',
        titreLien: null,
        lien: null,
        nomPrenomConseiller: 'Conseiller Supprime',
        dateCreation: deletedDate,
        isSupprime: true,
      ),
      _actualite(
        titre: 'Titre du jour',
        contenu: 'Corps du jour',
        titreLien: 'Titre lien du jour',
        lien: 'https://today.example.com',
        nomPrenomConseiller: 'Conseiller du Jour',
        dateCreation: todayDate,
      ),
    ];

    final store = givenState()
        .copyWith(actualiteMissionLocaleState: ActualiteMissionLocaleSuccessState(actualites))
        .store();

    // When
    final viewModel = ActualiteMissionLocaleViewModel.create(store);

    // Then
    expect(viewModel.displayState, DisplayState.CONTENT);
    expect(viewModel.actualites, [
      ActualiteMissionLocaleItemViewModel(
        titre: 'Titre du jour',
        corps: 'Corps du jour',
        titreLien: 'Titre lien du jour',
        lien: 'https://today.example.com',
        heureEtNomConseiller: Strings.hourAndPostOwner(todayDate.toHourWithHSeparator(), 'Conseiller du Jour'),
        dateCreation: Strings.today,
      ),
      ActualiteMissionLocaleItemSupprimeViewModel(
        dateCreation: deletedDate.toDay(),
      ),
      ActualiteMissionLocaleItemViewModel(
        titre: 'Titre ancien',
        corps: 'Corps ancien',
        titreLien: 'Titre lien ancien',
        lien: 'https://old.example.com',
        heureEtNomConseiller: Strings.hourAndPostOwner(olderDate.toHourWithHSeparator(), 'Ancien Conseiller'),
        dateCreation: Strings.simpleDayFormat(olderDate.toDay()),
      ),
    ]);
  });

  test('onRetry dispatches ActualiteMissionLocaleRequestAction', () {
    // Given
    final store = givenState().copyWith(actualiteMissionLocaleState: ActualiteMissionLocaleFailureState()).spyStore();
    final viewModel = ActualiteMissionLocaleViewModel.create(store);

    // When
    viewModel.onRetry();

    // Then
    expect(store.dispatchedActions, hasLength(1));
    expect(store.dispatchedActions.first, isA<ActualiteMissionLocaleRequestAction>());
  });
}

ActualiteMissionLocale _actualite({
  required String titre,
  required String contenu,
  required String? titreLien,
  required String? lien,
  required String nomPrenomConseiller,
  required DateTime dateCreation,
  bool isSupprime = false,
}) {
  return ActualiteMissionLocale(
    titre: titre,
    contenu: contenu,
    titreLien: titreLien,
    lien: lien,
    nomPrenomConseiller: nomPrenomConseiller,
    dateCreation: dateCreation,
    isSupprime: isSupprime,
  );
}
