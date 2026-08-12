import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pass_emploi_app/features/alerte/get/alerte_get_action.dart';
import 'package:pass_emploi_app/features/recherche/evenement_emploi/evenement_emploi_criteres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/evenement_emploi/evenement_emploi_filtres_recherche.dart';
import 'package:pass_emploi_app/features/recherche/recherche_actions.dart';
import 'package:pass_emploi_app/features/recherche/recherche_state.dart';
import 'package:pass_emploi_app/models/alerte/alerte.dart';
import 'package:pass_emploi_app/models/alerte/evenement_emploi_alerte.dart';
import 'package:pass_emploi_app/models/alerte/immersion_alerte.dart';
import 'package:pass_emploi_app/models/alerte/offre_emploi_alerte.dart';
import 'package:pass_emploi_app/models/alerte/service_civique_alerte.dart';
import 'package:pass_emploi_app/models/recherche/recherche_request.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:redux/redux.dart';

enum RechercheType { emploi, alternance, immersion, serviceCivique, evenementEmploi, unknown }

class RechercheCriteresFullScreen<Result> extends StatefulWidget {
  final RechercheState Function(AppState) rechercheState;
  final Widget Function({required Function(int) onNumberOfCriteresChanged}) buildCriteresContentWidget;
  final RechercheType rechercheType;

  const RechercheCriteresFullScreen({
    super.key,
    required this.rechercheState,
    required this.buildCriteresContentWidget,
    required this.rechercheType,
  });

  @override
  State<RechercheCriteresFullScreen<Result>> createState() => _RechercheCriteresFullScreenState<Result>();
}

class _RechercheCriteresFullScreenState<Result> extends State<RechercheCriteresFullScreen<Result>> {
  int? _criteresActifsCount;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _RechercheCriteresFullScreenViewModel<Result>>(
      converter: (store) => _RechercheCriteresFullScreenViewModel.create(store, widget.rechercheState),
      distinct: true,
      builder: (context, viewModel) {
        return SizedBox.expand(
          child: ColoredBox(
            color: DsfrColorDecisions.backgroundDefaultGrey(context),
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Padding(
                padding: const EdgeInsets.all(DsfrSpacings.s2w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    widget.buildCriteresContentWidget(
                      onNumberOfCriteresChanged: (number) {
                        setState(() => _criteresActifsCount = number);
                        SemanticsService.announce(
                          intl.Intl.plural(
                            _criteresActifsCount ?? 0,
                            zero: Strings.rechercheCriteresActifsZero,
                            one: Strings.rechercheCriteresActifsOne,
                            other: Strings.rechercheCriteresActifsPlural(_criteresActifsCount ?? 0),
                          ),
                          TextDirection.ltr,
                        );
                      },
                    ),
                    _RecentSearches<Result>(
                      rechercheState: widget.rechercheState,
                      rechercheType: widget.rechercheType,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RechercheCriteresFullScreenViewModel<Result> extends Equatable {
  final bool canSeeResults;

  const _RechercheCriteresFullScreenViewModel({
    required this.canSeeResults,
  });

  factory _RechercheCriteresFullScreenViewModel.create(
    Store<AppState> store,
    RechercheState Function(AppState) rechercheState,
  ) {
    final state = rechercheState(store.state);
    return _RechercheCriteresFullScreenViewModel(
      canSeeResults: state.results != null,
    );
  }

  @override
  List<Object?> get props => [canSeeResults];
}

class _RecentSearches<Result> extends StatelessWidget {
  final RechercheState Function(AppState) rechercheState;
  final RechercheType rechercheType;

  const _RecentSearches({required this.rechercheState, required this.rechercheType});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _RecentSearchesViewModel>(
      distinct: true,
      converter: (store) => _RecentSearchesViewModel.create(store, rechercheState, rechercheType),
      builder: (context, viewModel) {
        if (viewModel.items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s2w),
              child: Row(
                children: [
                  Icon(
                    DsfrIcons.systemTimeLine,
                    size: 16,
                    color: DsfrColorDecisions.textTitleGrey(context),
                  ),
                  const SizedBox(width: DsfrSpacings.s1w),
                  Expanded(
                    child: Text(
                      Strings.rechercheRecentesTitle,
                      style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                    ),
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DsfrSpacings.s1w),
                border: Border.all(color: DsfrColorDecisions.artworkDecorativeBlueFrance(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < viewModel.items.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: DsfrColorDecisions.artworkDecorativeBlueFrance(context),
                      ),
                    _RechercheRecenteTile(
                      alerte: viewModel.items[i].alerte,
                      text: viewModel.items[i].title,
                      onTap: () => viewModel.onTapRecentSearch(viewModel.items[i].alerte),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RechercheRecenteTile extends StatelessWidget {
  final Alerte alerte;
  final String text;
  final VoidCallback onTap;

  const _RechercheRecenteTile({required this.alerte, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(DsfrSpacings.s2w),
          child: Text(
            text,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textActionHighBlueFrance(context)),
          ),
        ),
      ),
    );
  }
}

class _RecentSearchesItem {
  final Alerte alerte;
  final String title;

  _RecentSearchesItem({required this.alerte, required this.title});
}

class _RecentSearchesViewModel extends Equatable {
  final List<_RecentSearchesItem> items;
  final void Function(Alerte alerte) onTapRecentSearch;

  const _RecentSearchesViewModel({
    required this.items,
    required this.onTapRecentSearch,
  });

  factory _RecentSearchesViewModel.create(
    Store<AppState> store,
    RechercheState Function(AppState) rechercheState,
    RechercheType rechercheType,
  ) {
    final all = store.state.recherchesRecentesState.recentSearches;

    final filtered = all.where((a) => _matchesType(a, rechercheType)).take(5).toList();

    return _RecentSearchesViewModel(
      items: [
        for (final alerte in filtered)
          _RecentSearchesItem(
            alerte: alerte,
            title: alerte.getTitle(),
          ),
      ],
      onTapRecentSearch: (alerte) {
        if (alerte is EvenementEmploiAlerte) {
          store.dispatch(
            RechercheRequestAction(
              RechercheRequest(
                EvenementEmploiCriteresRecherche(location: alerte.location, secteurActivite: alerte.secteurActivite),
                EvenementEmploiFiltresRecherche.noFiltre(),
                1,
              ),
            ),
          );
          return;
        }
        store.dispatch(FetchAlerteResultsAction(alerte));
      },
    );
  }

  @override
  List<Object?> get props => [items.map((e) => e.alerte).toList()];
}

bool _matchesType(Alerte alerte, RechercheType type) {
  return switch (type) {
    RechercheType.emploi => alerte is OffreEmploiAlerte && alerte.onlyAlternance == false,
    RechercheType.alternance => alerte is OffreEmploiAlerte && alerte.onlyAlternance == true,
    RechercheType.immersion => alerte is ImmersionAlerte,
    RechercheType.serviceCivique => alerte is ServiceCiviqueAlerte,
    RechercheType.evenementEmploi => alerte is EvenementEmploiAlerte,
    RechercheType.unknown => false,
  };
}
