import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/favori/ids/favori_ids_state.dart';
import 'package:pass_emploi_app/features/recherche/evenement_emploi/evenement_emploi_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/evenement_emploi/evenement_emploi_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/features/recherche/recherche_state.dart';
import 'package:pass_emploi_app/models/alerte/alerte_from_request.dart';
import 'package:pass_emploi_app/models/recherche/recherche_request.dart';
import 'package:pass_emploi_app/presentation/recherche/actions_recherche_view_model.dart';
import 'package:pass_emploi_app/presentation/recherche/bloc_resultat_recherche_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/recherche/actions_recherche.dart';
import 'package:pass_emploi_app/widgets/recherche/bloc_resultat_recherche.dart';
import 'package:pass_emploi_app/widgets/recherche/edit_criteres_button.dart';
import 'package:pass_emploi_app/widgets/recherche/recherche_criteres_full_screen.dart';
import 'package:pass_emploi_app/widgets/recherche/resultat_recherche_contenu.dart';
import 'package:redux/redux.dart';

abstract class RechercheOffrePage<Result> extends StatefulWidget {
  ActionsRechercheViewModel buildActionsRechercheViewModel(Store<AppState> store);

  String? appBarTitle();

  String analyticsType();

  String placeHolderTitle();

  String placeHolderSubtitle();

  String emptyTitle();

  String Function(int count) resultsCountLabel() => Strings.rechercheResultsOffresCount;

  RechercheState rechercheState(AppState appState);

  RechercheType rechercheType();

  FavoriIdsState<Result> favorisState(AppState appState);

  Widget? buildAlertBottomSheet();

  bool withCreateAlerte() => true;

  bool withBackButton() => true;

  Future<bool?>? buildFiltresBottomSheet(BuildContext context);

  Widget buildCriteresContentWidget({required Function(int) onNumberOfCriteresChanged});

  Widget buildResultItem(
    BuildContext context,
    Result item,
    int index,
    BlocResultatRechercheViewModel<Result> resultViewModel,
  );

  @override
  State<RechercheOffrePage<Result>> createState() => _RechercheOffrePageState();
}

class _RechercheOffrePageState<Result> extends State<RechercheOffrePage<Result>> {
  Store<AppState>? _store;
  final _listResultatKey = GlobalKey();

  @override
  void dispose() {
    _store?.dispatch(RechercheResetAction<Result>());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _store = StoreProvider.of<AppState>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Tracker(
      tracking: AnalyticsScreenNames.rechercheInitiale(widget.analyticsType()),
      child: Theme(
        data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
        child: Builder(
          builder: (context) {
            final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
            final pageTitle = widget.appBarTitle();
            return StoreConnector<AppState, _RechercheOffreLayout>(
              distinct: true,
              converter: (store) {
                final state = widget.rechercheState(store.state);
                final showCriteresFullScreen = state.status == RechercheStatus.nouvelleRecherche;
                return _RechercheOffreLayout(
                  showCriteresFullScreen: showCriteresFullScreen,
                  showBackAppBar: widget.withBackButton() || (showCriteresFullScreen && state.results != null),
                );
              },
              builder: (context, layout) {
                return Scaffold(
                  backgroundColor: backgroundColor,
                  appBar: layout.showBackAppBar
                      ? _RechercheBackAppBar<Result>(
                          backgroundColor: backgroundColor,
                          rechercheState: widget.rechercheState,
                        )
                      : null,
                  floatingActionButton: ActionsRecherche(
                    buildViewModel: widget.buildActionsRechercheViewModel,
                    buildAlertBottomSheet: widget.buildAlertBottomSheet,
                    hasResults: (appState) {
                      final results = widget.rechercheState(appState).results;
                      return results != null && results.isNotEmpty;
                    },
                  ),
                  floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                  resizeToAvoidBottomInset: false,
                  body: AnimatedSwitcher(
                    duration: AnimationDurations.fast,
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: layout.showCriteresFullScreen
                        ? Column(
                            key: const ValueKey("rechercheCriteresFullScreen"),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (pageTitle != null) _PageTitle(pageTitle),
                              Expanded(
                                child: RechercheCriteresFullScreen<Result>(
                                  rechercheState: widget.rechercheState,
                                  buildCriteresContentWidget: widget.buildCriteresContentWidget,
                                  rechercheType: widget.rechercheType(),
                                ),
                              ),
                            ],
                          )
                        : Padding(
                            key: const ValueKey("rechercheResultats"),
                            padding: const EdgeInsets.only(
                              left: DsfrSpacings.s2w,
                              right: DsfrSpacings.s2w,
                            ),
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (pageTitle != null) ...[
                                    _PageTitle(pageTitle, withHorizontalPadding: false),
                                    const SizedBox(height: DsfrSpacings.s2w),
                                  ] else
                                    const SizedBox(height: DsfrSpacings.s2w),
                                  StoreConnector<AppState, _EditCriteresSearchLabelViewModel>(
                                    distinct: true,
                                    converter: (store) => _EditCriteresSearchLabelViewModel.fromState(
                                      rechercheState: widget.rechercheState(store.state),
                                    ),
                                    builder: (context, vm) => EditCriteresButton<Result>(
                                      searchLabel: vm.searchLabel,
                                      buildViewModel: widget.buildActionsRechercheViewModel,
                                      buildFiltresBottomSheet: () => widget.buildFiltresBottomSheet(context),
                                      onFiltreApplied: _onFiltreApplied,
                                    ),
                                  ),
                                  BlocResultatRecherche<Result>(
                                    listResultatKey: _listResultatKey,
                                    rechercheState: widget.rechercheState,
                                    favorisState: widget.favorisState,
                                    buildResultItem: widget.buildResultItem,
                                    analyticsType: widget.analyticsType(),
                                    placeHolderTitle: widget.placeHolderTitle(),
                                    placeHolderSubtitle: widget.placeHolderSubtitle(),
                                    emptyTitle: widget.emptyTitle(),
                                    resultsCountLabel: widget.resultsCountLabel(),
                                    buildAlertBottomSheet:
                                        widget.withCreateAlerte() ? widget.buildAlertBottomSheet : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _onFiltreApplied() => (_listResultatKey.currentState as ResultatRechercheContenuState?)?.scrollToTop();
}

class _RechercheOffreLayout extends Equatable {
  final bool showCriteresFullScreen;
  final bool showBackAppBar;

  const _RechercheOffreLayout({
    required this.showCriteresFullScreen,
    required this.showBackAppBar,
  });

  @override
  List<Object?> get props => [showCriteresFullScreen, showBackAppBar];
}

class _RechercheBackAppBar<Result> extends StatelessWidget implements PreferredSizeWidget {
  const _RechercheBackAppBar({
    required this.backgroundColor,
    required this.rechercheState,
  });

  final Color backgroundColor;
  final RechercheState Function(AppState) rechercheState;

  static const double _toolbarHeight = 48;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _RechercheBackAppBarViewModel>(
      distinct: true,
      converter: (store) {
        final state = rechercheState(store.state);
        return _RechercheBackAppBarViewModel(
          canCloseCriteresToResults:
              state.status == RechercheStatus.nouvelleRecherche && state.results != null,
        );
      },
      builder: (context, viewModel) {
        return AppBar(
          primary: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: backgroundColor,
          toolbarHeight: _toolbarHeight,
          centerTitle: false,
          automaticallyImplyLeading: false,
          titleSpacing: DsfrSpacings.s1w,
          leadingWidth: 140,
          leading: Align(
            alignment: Alignment.centerLeft,
            child: BackLabelButton(
              onPressed: () {
                if (viewModel.canCloseCriteresToResults) {
                  StoreProvider.of<AppState>(context).dispatch(RechercheCloseCriteresAction<Result>());
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _RechercheBackAppBarViewModel extends Equatable {
  final bool canCloseCriteresToResults;

  const _RechercheBackAppBarViewModel({required this.canCloseCriteresToResults});

  @override
  List<Object?> get props => [canCloseCriteresToResults];
}

class _PageTitle extends StatelessWidget {
  const _PageTitle(this.title, {this.withHorizontalPadding = true});

  final String title;
  final bool withHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        withHorizontalPadding ? DsfrSpacings.s2w : 0,
        DsfrSpacings.s1w,
        withHorizontalPadding ? DsfrSpacings.s2w : 0,
        DsfrSpacings.s1w,
      ),
      child: AutoFocusA11y(
        child: Semantics(
          header: true,
          child: Text(
            title,
            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
      ),
    );
  }
}

class _EditCriteresSearchLabelViewModel extends Equatable {
  final String searchLabel;

  const _EditCriteresSearchLabelViewModel({required this.searchLabel});

  factory _EditCriteresSearchLabelViewModel.fromState({required RechercheState rechercheState}) {
    final request = rechercheState.request;
    if (request == null) return const _EditCriteresSearchLabelViewModel(searchLabel: "");

    final alerte = createAlerteFromRequest(request);

    if (request is RechercheRequest<EvenementEmploiCriteresRecherche, EvenementEmploiFiltresRecherche>) {
      final secteur = request.criteres.secteurActivite?.label ?? Strings.secteurActiviteAll;
      final location = request.criteres.location.libelle;
      return _EditCriteresSearchLabelViewModel(searchLabel: "$secteur - $location");
    }

    return _EditCriteresSearchLabelViewModel(searchLabel: alerte?.getTitle() ?? "");
  }

  @override
  List<Object?> get props => [searchLabel];
}
