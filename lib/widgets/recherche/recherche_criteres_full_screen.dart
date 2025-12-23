import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
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
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:redux/redux.dart';

class RechercheCriteresFullScreen<Result> extends StatefulWidget {
  final String analyticsType;
  final RechercheState Function(AppState) rechercheState;
  final Widget Function({required Function(int) onNumberOfCriteresChanged}) buildCriteresContentWidget;

  const RechercheCriteresFullScreen({
    super.key,
    required this.analyticsType,
    required this.rechercheState,
    required this.buildCriteresContentWidget,
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
            color: Colors.white,
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Padding(
                padding: const EdgeInsets.all(Margins.spacing_base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Margins.spacing_base),
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
                    const SizedBox(height: Margins.spacing_base),
                    _RecentSearches<Result>(
                      analyticsType: widget.analyticsType,
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
  final String analyticsType;

  const _RecentSearches({required this.analyticsType});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _RecentSearchesViewModel>(
      distinct: true,
      converter: (store) => _RecentSearchesViewModel.create(store, analyticsType),
      builder: (context, viewModel) {
        if (viewModel.items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                Strings.rechercheRecentesTitle,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: Margins.spacing_s),
              for (final item in viewModel.items) ...[
                _RechercheRecenteTile(
                  alerte: item.alerte,
                  text: item.subtitle,
                  onTap: () => viewModel.onTapRecentSearch(item.alerte),
                ),
                Divider(
                  color: AppColors.grey500,
                  height: 1,
                ),
              ],
            ],
          ),
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
          padding: const EdgeInsets.symmetric(vertical: Margins.spacing_base),
          child: Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                color: AppColors.grey800,
                size: Dimens.icon_size_m,
              ),
              SizedBox(width: Margins.spacing_base),
              Expanded(
                child: Text(
                  text,
                  style: TextStyles.textBaseRegular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSearchesItem {
  final Alerte alerte;
  final String subtitle;

  _RecentSearchesItem({required this.alerte, required this.subtitle});
}

class _RecentSearchesViewModel extends Equatable {
  final List<_RecentSearchesItem> items;
  final void Function(Alerte alerte) onTapRecentSearch;

  const _RecentSearchesViewModel({
    required this.items,
    required this.onTapRecentSearch,
  });

  factory _RecentSearchesViewModel.create(Store<AppState> store, String analyticsType) {
    final all = store.state.recherchesRecentesState.recentSearches;
    final type = _rechercheTypeFromAnalytics(analyticsType);

    final filtered = all.where((a) => _matchesType(a, type)).take(5).toList();

    return _RecentSearchesViewModel(
      items: [
        for (final alerte in filtered)
          _RecentSearchesItem(
            alerte: alerte,
            subtitle: alerte.getTitle(),
          ),
      ],
      onTapRecentSearch: (alerte) {
        if (alerte is EvenementEmploiAlerte) {
          store.dispatch(
            RechercheRequestAction(
              RechercheRequest(
                EvenementEmploiCriteresRecherche(location: alerte.location, secteurActivite: null),
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

enum _RechercheType { emploi, alternance, immersion, serviceCivique, evenementEmploi, unknown }

_RechercheType _rechercheTypeFromAnalytics(String analyticsType) {
  switch (analyticsType) {
    case AnalyticsScreenNames.emploiRecherche:
      return _RechercheType.emploi;
    case AnalyticsScreenNames.alternanceRecherche:
      return _RechercheType.alternance;
    case AnalyticsScreenNames.immersionRecherche:
      return _RechercheType.immersion;
    case AnalyticsScreenNames.serviceCiviqueRecherche:
      return _RechercheType.serviceCivique;
    case AnalyticsScreenNames.evenementEmploiRecherche:
      return _RechercheType.evenementEmploi;
    default:
      return _RechercheType.unknown;
  }
}

bool _matchesType(Alerte alerte, _RechercheType type) {
  switch (type) {
    case _RechercheType.emploi:
      return alerte is OffreEmploiAlerte && alerte.onlyAlternance == false;
    case _RechercheType.alternance:
      return alerte is OffreEmploiAlerte && alerte.onlyAlternance == true;
    case _RechercheType.immersion:
      return alerte is ImmersionAlerte;
    case _RechercheType.serviceCivique:
      return alerte is ServiceCiviqueAlerte;
    case _RechercheType.evenementEmploi:
      return alerte is EvenementEmploiAlerte;
    case _RechercheType.unknown:
      return false;
  }
}
