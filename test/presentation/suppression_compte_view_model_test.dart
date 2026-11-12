import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/suppression_compte/suppression_compte_state.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/profil/suppression_compte_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/redux/app_reducer.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

import '../doubles/fixtures.dart';

void main() {
  test('create by MILO should set the accompanied mission locale copy', () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: loggedInState().copyWith(suppressionCompteState: SuppressionCompteNotInitializedState()),
    );

    // When
    final viewModel = SuppressionCompteViewModel.create(store);

    // Then
    expect(viewModel.title, Strings.suppressionPageTitle);
    expect(viewModel.introduction, Strings.warningInformationParagraph1);
    expect(viewModel.warningSuppressionFeatures, Strings.warningPointsMilo);
    expect(viewModel.accompagnementNotice, Strings.warningInformationParagraph2);
    expect(viewModel.poleEmploiNotice, isNull);
    expect(viewModel.confirmLabel, Strings.suppressionButtonLabel);
    expect(viewModel.displayState, isNull);
  });

  test('create by accompanied France Travail should set the accompanied copy', () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: loggedInPoleEmploiState().copyWith(suppressionCompteState: SuppressionCompteNotInitializedState()),
    );

    // When
    final viewModel = SuppressionCompteViewModel.create(store);

    // Then
    expect(viewModel.title, Strings.suppressionPageTitle);
    expect(viewModel.introduction, Strings.warningInformationParagraph1);
    expect(viewModel.warningSuppressionFeatures, Strings.warningPointsFtAccompagne);
    expect(viewModel.accompagnementNotice, Strings.warningInformationParagraph2);
    expect(viewModel.poleEmploiNotice, Strings.warningInformationPoleEmploi);
    expect(viewModel.confirmLabel, Strings.suppressionButtonLabel);
    expect(viewModel.displayState, isNull);
  });

  test('create by unaccompanied France Travail should hide the accompaniment notices', () {
    for (final accompagnement in [Accompagnement.ftEspaceCandidat, Accompagnement.ftDemandeurDEmploi]) {
      final store = Store<AppState>(
        reducer,
        initialState: loggedInState().copyWith(
          loginState: successUserState(loginMode: LoginMode.POLE_EMPLOI, accompagnement: accompagnement),
          suppressionCompteState: SuppressionCompteNotInitializedState(),
        ),
      );

      final viewModel = SuppressionCompteViewModel.create(store);

      expect(viewModel.title, Strings.suppressionPageTitle);
      expect(viewModel.warningSuppressionFeatures, Strings.warningPointsFtNonAccompagne);
      expect(viewModel.accompagnementNotice, isNull);
      expect(viewModel.poleEmploiNotice, isNull);
      expect(viewModel.confirmLabel, Strings.suppressionButtonLabel);
    }
  });

  test('create by invite should set the data deletion copy', () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: loggedInState().copyWith(
        loginState: successUserState(loginMode: LoginMode.INVITE, accompagnement: Accompagnement.cej),
        suppressionCompteState: SuppressionCompteNotInitializedState(),
      ),
    );

    // When
    final viewModel = SuppressionCompteViewModel.create(store);

    // Then
    expect(viewModel.title, Strings.suppressionDonneesButtonLabel);
    expect(viewModel.introduction, Strings.suppressionDonneesIntroduction);
    expect(viewModel.warningSuppressionFeatures, Strings.warningPointsInvite);
    expect(viewModel.accompagnementNotice, isNull);
    expect(viewModel.poleEmploiNotice, isNull);
    expect(viewModel.confirmLabel, Strings.suppressionDonneesButtonLabel);
  });

  test('create when state is FAILURE', () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: loggedInPoleEmploiState().copyWith(suppressionCompteState: SuppressionCompteFailureState()),
    );

    // When
    final viewModel = SuppressionCompteViewModel.create(store);

    // Then
    expect(viewModel.displayState, DisplayState.FAILURE);
  });

  test('create when state is SUCCESS', () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: loggedInPoleEmploiState().copyWith(suppressionCompteState: SuppressionCompteSuccessState()),
    );

    // When
    final viewModel = SuppressionCompteViewModel.create(store);

    // Then
    expect(viewModel.displayState, DisplayState.CONTENT);
  });

  test('create when state is LOADING', () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: loggedInPoleEmploiState().copyWith(suppressionCompteState: SuppressionCompteLoadingState()),
    );

    // When
    final viewModel = SuppressionCompteViewModel.create(store);

    // Then
    expect(viewModel.displayState, DisplayState.LOADING);
  });

}


