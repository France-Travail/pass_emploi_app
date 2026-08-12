import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/favori/ids/favori_ids_state.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/features/recherche/recherche_state.dart';
import 'package:pass_emploi_app/models/alerte/alerte_from_request.dart';
import 'package:pass_emploi_app/models/alerte/immersion_alerte.dart';
import 'package:pass_emploi_app/models/alerte/offre_emploi_alerte.dart';
import 'package:pass_emploi_app/models/alerte/service_civique_alerte.dart';
import 'package:pass_emploi_app/presentation/recherche/bloc_resultat_recherche_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/utils/context_extensions.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/animated_list_loader.dart';
import 'package:pass_emploi_app/widgets/recherche/recherche_empty_state.dart';
import 'package:pass_emploi_app/widgets/recherche/recherche_message_placeholder.dart';
import 'package:pass_emploi_app/widgets/recherche/resultat_recherche_contenu.dart';
import 'package:pass_emploi_app/widgets/retry.dart';

class BlocResultatRecherche<Result> extends StatefulWidget {
  final Key listResultatKey;
  final RechercheState Function(AppState) rechercheState;
  final FavoriIdsState<Result> Function(AppState) favorisState;
  final Widget Function(BuildContext, Result, int, BlocResultatRechercheViewModel<Result>) buildResultItem;
  final String analyticsType;
  final String placeHolderTitle;
  final String placeHolderSubtitle;
  final String emptyTitle;
  final String Function(int count) resultsCountLabel;
  final Widget? Function()? buildAlertBottomSheet;

  BlocResultatRecherche({
    required this.listResultatKey,
    required this.rechercheState,
    required this.favorisState,
    required this.buildResultItem,
    required this.analyticsType,
    required this.placeHolderTitle,
    required this.placeHolderSubtitle,
    required this.emptyTitle,
    required this.resultsCountLabel,
    this.buildAlertBottomSheet,
  });

  @override
  State<BlocResultatRecherche<Result>> createState() => _BlocResultatRechercheState<Result>();
}

class _BlocResultatRechercheState<Result> extends State<BlocResultatRecherche<Result>> {
  int _numberOfSearchSent = 0;
  int? _lastNumberSearchAnalyticSent;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, BlocResultatRechercheViewModel<Result>>(
      builder: _builder,
      converter: (store) => BlocResultatRechercheViewModel.create(store, widget.rechercheState),
      onDidChange: (previousViewModel, viewModel) {
        _trackSearchResults(viewModel, previousViewModel, context);
      },
      distinct: true,
    );
  }

  Widget _builder(BuildContext context, BlocResultatRechercheViewModel<Result> viewModel) {
    switch (viewModel.displayState) {
      case BlocResultatRechercheDisplayState.recherche:
        return RechercheMessagePlaceholder(widget.placeHolderTitle, subtitle: widget.placeHolderSubtitle);
      case BlocResultatRechercheDisplayState.loading:
        return _buildLoadingPlaceholder(context);
      case BlocResultatRechercheDisplayState.failure:
        return Retry(Strings.genericError, () => viewModel.onRetry());
      case BlocResultatRechercheDisplayState.empty:
        return StoreConnector<AppState, _EmptyCriteriaViewModel>(
          distinct: true,
          converter: (store) => _EmptyCriteriaViewModel.fromState(widget.rechercheState(store.state)),
          builder: (context, criteria) => RechercheEmptyState<Result>(
            title: widget.emptyTitle,
            subtitle: Strings.rechercheEmptySubtitle(
              metier: criteria.metier,
              lieu: criteria.lieu,
            ),
            buildAlertBottomSheet: widget.buildAlertBottomSheet,
          ),
        );
      case BlocResultatRechercheDisplayState.results:
      case BlocResultatRechercheDisplayState.editRecherche:
        final bool withOpacity = viewModel.displayState == BlocResultatRechercheDisplayState.editRecherche;
        final bool disabled = withOpacity && !A11yUtils.withScreenReader(context);
        return Semantics(
          label: Strings.listOffres,
          child: GestureDetector(
            onTapDown: (_) => viewModel.onListWithOpacityTouch(),
            child: AnimatedOpacity(
              opacity: disabled ? 0.2 : 1,
              duration: const Duration(milliseconds: 200),
              child: AbsorbPointer(
                absorbing: disabled,
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (hasFocus) {
                      // A11y - to close bandeau recherche when focus goes to the list
                      context.dispatch(RechercheCloseCriteresAction<Result>());
                    }
                  },
                  child: ResultatRechercheContenu<Result>(
                    key: widget.listResultatKey,
                    analyticsType: widget.analyticsType,
                    viewModel: viewModel,
                    favorisState: widget.favorisState,
                    buildResultItem: widget.buildResultItem,
                    resultsCountLabel: widget.resultsCountLabel,
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return AnimatedListLoader(
      nested: true,
      placeholders: [
        for (var i = 0; i < 3; i++) ...[
          AnimatedListLoader.placeholderBuilder(width: double.infinity, height: 120),
          if (i < 2) const SizedBox(height: DsfrSpacings.s2w),
        ],
      ],
    );
  }

  void _trackSearchResults(
    BlocResultatRechercheViewModel<Result> viewModel,
    BlocResultatRechercheViewModel<Result>? previousViewModel,
    BuildContext context,
  ) {
    if (viewModel.displayState == BlocResultatRechercheDisplayState.recherche) _numberOfSearchSent += 1;
    if (viewModel.displayState == BlocResultatRechercheDisplayState.results) {
      if (_lastNumberSearchAnalyticSent == _numberOfSearchSent) return;
      _lastNumberSearchAnalyticSent = _numberOfSearchSent;

      PassEmploiMatomoTracker.instance.trackScreen(
        _numberOfSearchSent == 0
            ? AnalyticsScreenNames.rechercheInitialeResultats(widget.analyticsType)
            : AnalyticsScreenNames.rechercheModifieeResultats(widget.analyticsType),
      );
    }
  }
}

class _EmptyCriteriaViewModel extends Equatable {
  final String? metier;
  final String? lieu;

  const _EmptyCriteriaViewModel({this.metier, this.lieu});

  factory _EmptyCriteriaViewModel.fromState(RechercheState rechercheState) {
    final request = rechercheState.request;
    if (request == null) return const _EmptyCriteriaViewModel();

    final alerte = createAlerteFromRequest(request);
    if (alerte is OffreEmploiAlerte) {
      return _EmptyCriteriaViewModel(
        metier: alerte.keyword?.isNotEmpty == true ? alerte.keyword : null,
        lieu: alerte.location?.libelle,
      );
    }
    if (alerte is ImmersionAlerte) {
      return _EmptyCriteriaViewModel(
        metier: alerte.metier.isNotEmpty ? alerte.metier : null,
        lieu: alerte.ville,
      );
    }
    if (alerte is ServiceCiviqueAlerte) {
      return _EmptyCriteriaViewModel(lieu: alerte.ville);
    }
    return _EmptyCriteriaViewModel(
      metier: alerte?.getTitle(),
      lieu: alerte?.getLocation()?.libelle,
    );
  }

  @override
  List<Object?> get props => [metier, lieu];
}
