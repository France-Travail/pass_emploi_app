import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/features/recherche/recherche_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

enum BlocResultatRechercheDisplayState { recherche, loading, failure, empty, results, editRecherche }

class BlocResultatRechercheViewModel<Result> extends Equatable {
  final BlocResultatRechercheDisplayState displayState;
  final List<Result> items;
  final bool withLoadMore;
  final Function() onListWithOpacityTouch;
  final Function() onLoadMore;
  final Function() onRetry;

  BlocResultatRechercheViewModel({
    required this.displayState,
    required this.items,
    required this.withLoadMore,
    required this.onListWithOpacityTouch,
    required this.onLoadMore,
    required this.onRetry,
  });

  factory BlocResultatRechercheViewModel.create(
    Store<AppState> store,
    RechercheState Function(AppState) rechercheState,
  ) {
    final state = rechercheState(store.state);
    return BlocResultatRechercheViewModel(
      displayState: _displayState(state),
      items: state.results as List<Result>? ?? [],
      withLoadMore: state.canLoadMore,
      onListWithOpacityTouch: () => store.dispatch(RechercheCloseCriteresAction<Result>()),
      onLoadMore: () => store.dispatch(RechercheLoadMoreAction<Result>()),
      onRetry: () => store.dispatch(RechercheRetryAction<Result>()),
    );
  }

  @override
  List<Object?> get props => [displayState, items, withLoadMore];
}

BlocResultatRechercheDisplayState _displayState(RechercheState state) {
  switch (state.status) {
    case RechercheStatus.initialLoading:
      return BlocResultatRechercheDisplayState.loading;
    case RechercheStatus.failure:
      return BlocResultatRechercheDisplayState.failure;
    case RechercheStatus.success:
      return state.results?.isEmpty == true
          ? BlocResultatRechercheDisplayState.empty
          : BlocResultatRechercheDisplayState.results;
    case RechercheStatus.updateLoading:
      return BlocResultatRechercheDisplayState.results;
    case RechercheStatus.nouvelleRecherche:
      if (state.results == null) return BlocResultatRechercheDisplayState.recherche;
      return state.results?.isEmpty == true
          ? BlocResultatRechercheDisplayState.empty
          : BlocResultatRechercheDisplayState.editRecherche;
  }
}
