import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/offre_emploi.dart';
import 'package:pass_emploi_app/presentation/favori_heart_view_model.dart';
import 'package:pass_emploi_app/redux/reducers/app_reducer.dart';
import 'package:pass_emploi_app/redux/states/app_state.dart';
import 'package:pass_emploi_app/redux/states/favoris_state.dart';
import 'package:pass_emploi_app/redux/states/offre_emploi_favoris_update_state.dart';
import 'package:redux/redux.dart';

main() {
  test("create when id is in favori list should set isFavori to true", () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: AppState.initialState().copyWith(
        offreEmploiFavorisState: FavorisState<OffreEmploi>.idsLoaded({"offreId"}),
      ),
    );

    // When
    final viewModel = FavoriHeartViewModel.create("offreId", store, store.state.offreEmploiFavorisState);
    // Then
    expect(viewModel.isFavori, true);
  });

  test("create when id is not in favori list should set isFavori to false", () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: AppState.initialState().copyWith(
        offreEmploiFavorisState: FavorisState<OffreEmploi>.idsLoaded({"notOffreId"}),
      ),
    );

    // When
    final viewModel = FavoriHeartViewModel.create("offreId", store, store.state.offreEmploiFavorisState);

    // Then
    expect(viewModel.isFavori, false);
  });

  test("create when id is in favori and an error occurred should set withError to true", () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: AppState.initialState().copyWith(
        offreEmploiFavorisState: FavorisState<OffreEmploi>.idsLoaded({"offreId"}),
        favorisUpdateState: FavorisUpdateState({"offreId": FavorisUpdateStatus.ERROR}),
      ),
    );
    // When
    final viewModel = FavoriHeartViewModel.create("offreId", store, store.state.offreEmploiFavorisState);

    // Then
    expect(viewModel.withError, true);
    expect(viewModel.isFavori, true);
  });

  test("create when id is not in favori and an error occurred should set withError to true", () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: AppState.initialState().copyWith(
        offreEmploiFavorisState: FavorisState<OffreEmploi>.idsLoaded({"toto"}),
        favorisUpdateState: FavorisUpdateState({"offreId": FavorisUpdateStatus.ERROR}),
      ),
    );
    // When
    final viewModel = FavoriHeartViewModel.create("offreId", store, store.state.offreEmploiFavorisState);

    // Then
    expect(viewModel.withError, true);
    expect(viewModel.isFavori, false);
  });

  test("create when id status is loading should set withLoading to true", () {
    // Given
    final store = Store<AppState>(
      reducer,
      initialState: AppState.initialState().copyWith(
        favorisUpdateState: FavorisUpdateState({"offreId": FavorisUpdateStatus.LOADING}),
      ),
    );
    // When
    final viewModel = FavoriHeartViewModel.create("offreId", store, store.state.offreEmploiFavorisState);

    // Then
    expect(viewModel.withLoading, true);
  });
}
