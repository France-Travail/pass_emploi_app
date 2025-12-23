import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/favori/ids/favori_ids_state.dart';
import 'package:pass_emploi_app/features/recherche/evenement_emploi/evenement_emploi_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/evenement_emploi/evenement_emploi_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/features/recherche/recherche_state.dart';
import 'package:pass_emploi_app/models/alerte/alerte_from_request.dart';
import 'package:pass_emploi_app/models/alerte/immersion_alerte.dart';
import 'package:pass_emploi_app/models/alerte/offre_emploi_alerte.dart';
import 'package:pass_emploi_app/models/alerte/service_civique_alerte.dart';
import 'package:pass_emploi_app/models/recherche/recherche_request.dart';
import 'package:pass_emploi_app/presentation/recherche/actions_recherche_view_model.dart';
import 'package:pass_emploi_app/presentation/recherche/bloc_resultat_recherche_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
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

  RechercheState rechercheState(AppState appState);

  FavoriIdsState<Result> favorisState(AppState appState);

  Widget buildAlertBottomSheet();

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
    const backgroundColor = AppColors.grey100;
    return Tracker(
      tracking: AnalyticsScreenNames.rechercheInitiale(widget.analyticsType()),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: widget.appBarTitle() != null
            ? SecondaryAppBar(title: widget.appBarTitle()!, backgroundColor: backgroundColor)
            : null,
        floatingActionButton: ActionsRecherche(
          buildViewModel: widget.buildActionsRechercheViewModel,
          buildAlertBottomSheet: widget.buildAlertBottomSheet,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        resizeToAvoidBottomInset: false,
        body: StoreConnector<AppState, bool>(
          distinct: true,
          converter: (store) {
            final state = widget.rechercheState(store.state);
            return const [
              RechercheStatus.nouvelleRecherche,
              RechercheStatus.initialLoading,
              RechercheStatus.failure,
            ].contains(state.status);
          },
          builder: (context, showCriteresFullScreen) {
            return AnimatedSwitcher(
              duration: AnimationDurations.fast,
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: showCriteresFullScreen
                  ? RechercheCriteresFullScreen<Result>(
                      key: const ValueKey("rechercheCriteresFullScreen"),
                      analyticsType: widget.analyticsType(),
                      rechercheState: widget.rechercheState,
                      buildCriteresContentWidget: widget.buildCriteresContentWidget,
                    )
                  : Padding(
                      key: const ValueKey("rechercheResultats"),
                      padding: const EdgeInsets.only(
                        left: Margins.spacing_base,
                        top: Margins.spacing_base,
                        right: Margins.spacing_base,
                      ),
                      child: SingleChildScrollView(
                        clipBehavior: Clip.none,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            StoreConnector<AppState, _EditCriteresTitleSubtitleViewModel>(
                              distinct: true,
                              converter: (store) => _EditCriteresTitleSubtitleViewModel.fromState(
                                rechercheState: widget.rechercheState(store.state),
                              ),
                              builder: (context, vm) => EditCriteresButton<Result>(
                                title: vm.title,
                                subtitle: vm.subtitle,
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
                            ),
                          ],
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  void _onFiltreApplied() => (_listResultatKey.currentState as ResultatRechercheContenuState?)?.scrollToTop();
}

class _EditCriteresTitleSubtitleViewModel extends Equatable {
  final String title;
  final String subtitle;

  const _EditCriteresTitleSubtitleViewModel({required this.title, required this.subtitle});

  factory _EditCriteresTitleSubtitleViewModel.fromState({required RechercheState rechercheState}) {
    final request = rechercheState.request;
    if (request == null) return const _EditCriteresTitleSubtitleViewModel(title: "", subtitle: "");

    final typedRequest = request;
    final alerte = createAlerteFromRequest(typedRequest);

    final subtitle = alerte?.getTitle() ?? "";

    // Exception: for Evenement Emploi, title is the selected Secteur d'activité (or "Tous les secteurs...").
    if (typedRequest is RechercheRequest<EvenementEmploiCriteresRecherche, EvenementEmploiFiltresRecherche>) {
      final secteur = typedRequest.criteres.secteurActivite;
      return _EditCriteresTitleSubtitleViewModel(
        title: secteur?.label ?? Strings.secteurActiviteAll,
        subtitle: subtitle,
      );
    }

    // Default: title is the "type de recherche", like recent searches bandeau.
    if (alerte is OffreEmploiAlerte) {
      return _EditCriteresTitleSubtitleViewModel(
        title: alerte.onlyAlternance
            ? Strings.rechercheHomeOffresAlternanceTitle
            : Strings.rechercheHomeOffresEmploiTitle,
        subtitle: subtitle,
      );
    }
    if (alerte is ImmersionAlerte) {
      return _EditCriteresTitleSubtitleViewModel(title: Strings.rechercheHomeOffresImmersionTitle, subtitle: subtitle);
    }
    if (alerte is ServiceCiviqueAlerte) {
      return _EditCriteresTitleSubtitleViewModel(
        title: Strings.rechercheHomeOffresServiceCiviqueTitle,
        subtitle: subtitle,
      );
    }

    return _EditCriteresTitleSubtitleViewModel(title: "", subtitle: subtitle);
  }

  @override
  List<Object?> get props => [title, subtitle];
}
