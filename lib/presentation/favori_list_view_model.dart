import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/favori/list/favori_list_actions.dart';
import 'package:pass_emploi_app/features/favori/list/favori_list_state.dart';
import 'package:pass_emploi_app/models/favori.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

class FavoriListViewModel extends Equatable {
  final DisplayState displayState;
  final List<Favori> favoris;
  final List<Favori> postulees;
  final List<Favori> favorisSansPostulation;
  final Function onRetry;

  FavoriListViewModel({
    required this.displayState,
    required this.favoris,
    required this.postulees,
    required this.favorisSansPostulation,
    required this.onRetry,
  });

  static FavoriListViewModel create(Store<AppState> store) {
    final allFavoris = _favoris(store);
    final postulees = allFavoris.where((f) => f.datePostulation != null).toList();
    final favorisSansPostulation = allFavoris.where((f) => f.datePostulation == null).toList();
    return FavoriListViewModel(
      displayState: _displayState(store),
      favoris: allFavoris,
      postulees: postulees,
      favorisSansPostulation: favorisSansPostulation,
      onRetry: () => store.dispatch(FavoriListRequestAction()),
    );
  }

  @override
  List<Object?> get props => [displayState, favoris, postulees, favorisSansPostulation];
}

DisplayState _displayState(Store<AppState> store) {
  final state = store.state.favoriListState;
  if (state is FavoriListLoadingState) return DisplayState.LOADING;
  if (state is FavoriListSuccessState && state.results.isNotEmpty) return DisplayState.CONTENT;
  if (state is FavoriListSuccessState && state.results.isEmpty) return DisplayState.EMPTY;
  return DisplayState.FAILURE;
}

List<Favori> _favoris(Store<AppState> store) {
  final state = store.state.favoriListState;
  return state is FavoriListSuccessState ? state.results : [];
}
