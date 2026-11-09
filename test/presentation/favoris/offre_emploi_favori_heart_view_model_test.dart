import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/favori/ids/favori_ids_state.dart';
import 'package:pass_emploi_app/features/favori/update/favori_update_state.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/offre_emploi.dart';
import 'package:pass_emploi_app/presentation/favori_heart_view_model.dart';
import 'package:pass_emploi_app/redux/app_reducer.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/favoris/favoris_repository.dart';
import 'package:redux/redux.dart';

import '../../dsl/app_state_dsl.dart';

void main() {
  test("create when id is in favori list should set isFavori to true", () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: AppState.initialState().copyWith(
        offreEmploiFavorisIdsState: FavoriIdsState<OffreEmploi>.success({FavoriDto("offreId")}),
      ),
    );

    // When
    final viewModel = FavoriHeartViewModel.create("offreId", store, store.state.offreEmploiFavorisIdsState);
    // Then
    expect(viewModel.isFavori, true);
  });

  test("create when id is not in favori list should set isFavori to false", () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: AppState.initialState().copyWith(
        offreEmploiFavorisIdsState: FavoriIdsState<OffreEmploi>.success({FavoriDto("notOffreId")}),
      ),
    );

    // When
    final viewModel = FavoriHeartViewModel.create("offreId", store, store.state.offreEmploiFavorisIdsState);

    // Then
    expect(viewModel.isFavori, false);
  });

  test("create when id is in favori and an error occurred should set withError to true", () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: AppState.initialState().copyWith(
        offreEmploiFavorisIdsState: FavoriIdsState<OffreEmploi>.success({FavoriDto("offreId")}),
        favoriUpdateState: FavoriUpdateState({"offreId": FavoriUpdateStatus.ERROR}),
      ),
    );
    // When
    final viewModel = FavoriHeartViewModel.create("offreId", store, store.state.offreEmploiFavorisIdsState);

    // Then
    expect(viewModel.withError, true);
    expect(viewModel.isFavori, true);
  });

  test("create when id is not in favori and an error occurred should set withError to true", () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: AppState.initialState().copyWith(
        offreEmploiFavorisIdsState: FavoriIdsState<OffreEmploi>.success({FavoriDto("toto")}),
        favoriUpdateState: FavoriUpdateState({"offreId": FavoriUpdateStatus.ERROR}),
      ),
    );
    // When
    final viewModel = FavoriHeartViewModel.create("offreId", store, store.state.offreEmploiFavorisIdsState);

    // Then
    expect(viewModel.withError, true);
    expect(viewModel.isFavori, false);
  });

  test("create when id status is loading should set withLoading to true", () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: AppState.initialState().copyWith(
        favoriUpdateState: FavoriUpdateState({"offreId": FavoriUpdateStatus.LOADING}),
      ),
    );
    // When
    final viewModel = FavoriHeartViewModel.create("offreId", store, store.state.offreEmploiFavorisIdsState);

    // Then
    expect(viewModel.withLoading, true);
  });

  test("create should show the favorite button when the user is not a guest", () {
    // Given
    final store = givenState().loggedInPoleEmploiUser().store();

    // When
    final viewModel = FavoriHeartViewModel.create("offreId", store, store.state.offreEmploiFavorisIdsState);

    // Then
    expect(viewModel.isVisible, isTrue);
  });

  test("create should hide the favorite button for a guest", () {
    // Given
    final store = givenState().loggedInUser(loginMode: LoginMode.INVITE).store();

    // When
    final viewModel = FavoriHeartViewModel.create("offreId", store, store.state.offreEmploiFavorisIdsState);

    // Then
    expect(viewModel.isVisible, isFalse);
  });
}
