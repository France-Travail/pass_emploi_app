import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/alerte/get/alerte_get_action.dart';
import 'package:pass_emploi_app/features/alerte/list/alerte_list_actions.dart';
import 'package:pass_emploi_app/features/deep_link/deep_link_actions.dart';
import 'package:pass_emploi_app/features/suggestions_recherche/list/suggestions_recherche_actions.dart';
import 'package:pass_emploi_app/models/alerte/alerte.dart';
import 'package:pass_emploi_app/models/alerte/immersion_alerte.dart';
import 'package:pass_emploi_app/models/alerte/offre_emploi_alerte.dart';
import 'package:pass_emploi_app/models/alerte/service_civique_alerte.dart';
import 'package:pass_emploi_app/models/deep_link.dart';
import 'package:pass_emploi_app/models/location.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/offre_type.dart';
import 'package:pass_emploi_app/pages/generic_success_page.dart';
import 'package:pass_emploi_app/pages/offre_filters_bottom_sheet.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_emploi_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_immersion_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_service_civique_page.dart';
import 'package:pass_emploi_app/pages/suggestions_recherche/suggestions_alerte_location_form.dart';
import 'package:pass_emploi_app/presentation/alerte/alerte_list_view_model.dart';
import 'package:pass_emploi_app/presentation/alerte/alerte_navigation_state.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/suggestions/suggestion_recherche_card_view_model.dart';
import 'package:pass_emploi_app/presentation/suggestions/suggestions_recherche_list_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/redux/store_connector_aware.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/utils/store_extensions.dart';
import 'package:pass_emploi_app/widgets/animated_list_loader.dart';
import 'package:pass_emploi_app/widgets/buttons/filtre_button.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/buttons/secondary_button.dart';
import 'package:pass_emploi_app/widgets/cards/alerte_deletable_card.dart';
import 'package:pass_emploi_app/widgets/cards/base_cards/base_card.dart';
import 'package:pass_emploi_app/widgets/cards/base_cards/widgets/card_complement.dart';
import 'package:pass_emploi_app/widgets/cards/base_cards/widgets/card_tag.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';
import 'package:pass_emploi_app/widgets/dialogs/alerte_delete_dialog.dart';
import 'package:pass_emploi_app/widgets/illustration/empty_state_placeholder.dart';
import 'package:pass_emploi_app/widgets/illustration/illustration.dart';
import 'package:pass_emploi_app/widgets/loading_overlay.dart';
import 'package:pass_emploi_app/widgets/retry.dart';
import 'package:pass_emploi_app/widgets/snack_bar/show_snack_bar.dart';

class AlertePage extends StatefulWidget {
  @override
  State<AlertePage> createState() => _AlertePageState();
}

class _AlertePageState extends State<AlertePage> {
  OffreFilter _selectedFilter = OffreFilter.tous;
  bool _shouldNavigate = true;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.alerteList,
      child: StoreConnector<AppState, AlerteListViewModel>(
        onInit: (store) {
          store.dispatch(AlerteListRequestAction());
          store.dispatch(SuggestionsRechercheRequestAction());
          final deepLink = store.getDeepLinkAs<AlerteDeepLink>();
          if (deepLink != null) {
            store.dispatch(FetchAlerteResultsFromIdAction(deepLink.idAlerte));
          }
        },
        onWillChange: (oldVM, newVM) => _onWillChange(oldVM, newVM),
        builder: (context, viewModel) => _body(viewModel),
        converter: (store) => AlerteListViewModel.createFromStore(store),
        distinct: true,
      ),
    );
  }

  void _onWillChange(AlerteListViewModel? _, AlerteListViewModel? newViewModel) {
    if (!_shouldNavigate || newViewModel == null) return;
    final page = switch (newViewModel.searchNavigationState) {
      AlerteNavigationState.OFFRE_EMPLOI => RechercheOffreEmploiPage(onlyAlternance: false),
      AlerteNavigationState.OFFRE_ALTERNANCE => RechercheOffreEmploiPage(onlyAlternance: true),
      AlerteNavigationState.OFFRE_IMMERSION => RechercheOffreImmersionPage(),
      AlerteNavigationState.SERVICE_CIVIQUE => RechercheOffreServiceCiviquePage(),
      AlerteNavigationState.NONE => null,
    };
    if (page != null) _goToPage(page);
  }

  Future<bool> _goToPage(Widget page) {
    _shouldNavigate = false;
    return Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) => _shouldNavigate = true);
  }

  Widget _body(AlerteListViewModel viewModel) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: _content(viewModel),
      floatingActionButton: _floatingActionButton(context, viewModel),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _floatingActionButton(BuildContext context, AlerteListViewModel viewModel) {
    if (viewModel.displayState != DisplayState.CONTENT) return SizedBox();

    if (_selectedFilter == OffreFilter.tous && viewModel.alertes.isEmpty) {
      return PrimaryActionButton(label: Strings.alertesListEmptyButton, onPressed: () => _goToRecherche(context));
    }

    return FiltreButton(
      onPressed: () async {
        OffreFiltersBottomSheet.show(context, _selectedFilter).then((result) {
          if (result != null) _filterSelected(result);
        });
      },
    );
  }

  Widget _content(AlerteListViewModel viewModel) {
    return StoreConnectorAware<SuggestionsRechercheListViewModel>(
      converter: (store) => SuggestionsRechercheListViewModel.create(store),
      onDidChange: (oldVM, newVM) => _displaySuccessSnackbar(context, oldVM, newVM),
      distinct: true,
      builder: (context, suggestionsViewModel) {
        final displayState = viewModel.displayState;
        return Stack(
          children: [
            AnimatedSwitcher(
              duration: AnimationDurations.fast,
              child: switch (displayState) {
                DisplayState.LOADING => _AlerteLoading(),
                DisplayState.FAILURE => Retry(Strings.alerteGetError, () => viewModel.onRetry()),
                _ => _alertesWithSuggestions(viewModel, suggestionsViewModel),
              },
            ),
            if (suggestionsViewModel.traiterDisplayState == DisplayState.LOADING) LoadingOverlay(),
          ],
        );
      },
    );
  }

  Widget _alertesWithSuggestions(
    AlerteListViewModel viewModel,
    SuggestionsRechercheListViewModel suggestionsViewModel,
  ) {
    final List<Alerte> alertes = viewModel.getAlertesFiltered(_selectedFilter);
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              top: Margins.spacing_base,
              left: Margins.spacing_base,
              right: Margins.spacing_base,
            ),
            child: _SectionTitle(title: Strings.alertesTabTitle),
          ),
        ),
        if (alertes.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_base),
              child: _noAlerte(),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(Margins.spacing_base),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index.isOdd) return SizedBox(height: Margins.spacing_base);
                  final itemIndex = index ~/ 2;
                  final alerte = alertes[itemIndex];
                  return switch (alerte) {
                    OffreEmploiAlerte() => _buildEmploiCard(context, alerte, viewModel),
                    ImmersionAlerte() => _buildImmersionCard(context, alerte, viewModel),
                    ServiceCiviqueAlerte() => _buildServiceCiviqueCard(context, alerte, viewModel),
                    _ => SizedBox.shrink(),
                  };
                },
                childCount: alertes.isEmpty ? 0 : alertes.length * 2 - 1,
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Margins.spacing_base),
            child: _suggestionsSection(suggestionsViewModel),
          ),
        ),
      ],
    );
  }

  Widget _noAlerte() {
    return Column(
      children: [
        _selectedFilter == OffreFilter.tous
            ? _EmptyListPlaceholder.noFavori()
            : _EmptyListPlaceholder.noFavoriFiltered(),
        SizedBox(height: Margins.spacing_huge),
      ],
    );
  }

  Widget _buildEmploiCard(BuildContext context, OffreEmploiAlerte offreEmploi, AlerteListViewModel viewModel) {
    final type = offreEmploi.onlyAlternance ? AlerteType.ALTERNANCE : AlerteType.EMPLOI;
    return AlerteDeletableCard(
      offreType: offreEmploi.onlyAlternance ? OffreType.alternance : OffreType.emploi,
      onTap: () => viewModel.offreEmploiSelected(offreEmploi),
      onDelete: () => _showDeleteDialog(viewModel, offreEmploi.id, type),
      title: offreEmploi.title,
      place: offreEmploi.location?.libelle,
    );
  }

  Widget _buildImmersionCard(BuildContext context, ImmersionAlerte alertesImmersion, AlerteListViewModel viewModel) {
    return AlerteDeletableCard(
      offreType: OffreType.immersion,
      onTap: () => viewModel.offreImmersionSelected(alertesImmersion),
      onDelete: () => _showDeleteDialog(viewModel, alertesImmersion.id, AlerteType.IMMERSION),
      title: alertesImmersion.title,
      place: alertesImmersion.ville,
    );
  }

  Widget _buildServiceCiviqueCard(
    BuildContext context,
    ServiceCiviqueAlerte alertesServiceCivique,
    AlerteListViewModel viewModel,
  ) {
    return AlerteDeletableCard(
      offreType: OffreType.serviceCivique,
      onTap: () => viewModel.offreServiceCiviqueSelected(alertesServiceCivique),
      onDelete: () => _showDeleteDialog(viewModel, alertesServiceCivique.id, AlerteType.SERVICE_CIVIQUE),
      title: alertesServiceCivique.titre,
      place: alertesServiceCivique.ville?.isNotEmpty == true ? alertesServiceCivique.ville : null,
    );
  }

  void _goToRecherche(BuildContext context) {
    Navigator.of(context).pop();
    StoreProvider.of<AppState>(
      context,
    ).dispatch(HandleDeepLinkAction(RechercheDeepLink(), DeepLinkOrigin.inAppNavigation));
  }

  void _showDeleteDialog(AlerteListViewModel viewModel, String alerteId, AlerteType type) {
    final context = this.context;
    showDialog(context: context, builder: (_) => AlerteDeleteDialog(alerteId, type)).then((result) {
      if (result == true && context.mounted) {
        Navigator.push(
          context,
          GenericSuccessPage.route(
            title: Strings.alerteDeleteSuccessTitle,
            content: Strings.alerteDeleteSuccessContent,
          ),
        );
      }
    });
  }

  void _filterSelected(OffreFilter filter) {
    setState(() => _selectedFilter = filter);
    _scrollController.jumpTo(0);
    PassEmploiMatomoTracker.instance.trackScreen(switch (filter) {
      OffreFilter.tous => AnalyticsScreenNames.alerteList,
      OffreFilter.emploi => AnalyticsScreenNames.alerteListFilterEmploi,
      OffreFilter.alternance => AnalyticsScreenNames.alerteListFilterAlternance,
      OffreFilter.immersion => AnalyticsScreenNames.alerteListFilterImmersion,
      OffreFilter.serviceCivique => AnalyticsScreenNames.alerteListFilterServiceCivique,
    });
  }
}

class _EmptyListPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;

  _EmptyListPlaceholder({required this.title, required this.subtitle});

  factory _EmptyListPlaceholder.noFavori() {
    return _EmptyListPlaceholder(title: Strings.alertesListEmptyTitle, subtitle: Strings.alertesListEmptySubtitle);
  }

  factory _EmptyListPlaceholder.noFavoriFiltered() {
    return _EmptyListPlaceholder(
      title: Strings.alertesFilteredListEmptyTitle,
      subtitle: Strings.alertesFilteredListEmptySubtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyStatePlaceholder(
        illustration: Illustration.grey(Icons.search, withWhiteBackground: true),
        title: title,
        subtitle: subtitle,
      ),
    );
  }
}

class _AlerteLoading extends StatelessWidget {
  const _AlerteLoading();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final placeholders = _placeholders(screenWidth);
    return AnimatedListLoader(placeholders: placeholders);
  }

  List<Widget> _placeholders(double screenWidth) => [
    AnimatedListLoader.placeholderBuilder(width: screenWidth, height: 170),
    SizedBox(height: Margins.spacing_base),
    AnimatedListLoader.placeholderBuilder(width: screenWidth, height: 170),
    SizedBox(height: Margins.spacing_base),
    AnimatedListLoader.placeholderBuilder(width: screenWidth, height: 170),
    SizedBox(height: Margins.spacing_base),
    AnimatedListLoader.placeholderBuilder(width: screenWidth, height: 170),
    SizedBox(height: Margins.spacing_base),
    AnimatedListLoader.placeholderBuilder(width: screenWidth, height: 170),
  ];
}

Widget _suggestionsSection(SuggestionsRechercheListViewModel viewModel) {
  final content = switch (viewModel.displayState) {
    DisplayState.EMPTY => _SuggestionsEmpty(viewModel: viewModel),
    DisplayState.CONTENT => _SuggestionsList(viewModel: viewModel),
    DisplayState.LOADING => Center(child: CircularProgressIndicator()),
    DisplayState.FAILURE => Retry(Strings.vosSuggestionsAlertesError, () => viewModel.retryFetchSuggestions()),
  };
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _SectionTitle(title: Strings.suggestionsDeRechercheTitle),
      SizedBox(height: Margins.spacing_base),
      content,
      SizedBox(height: Margins.spacing_base),
    ],
  );
}

class _SuggestionsList extends StatelessWidget {
  final SuggestionsRechercheListViewModel viewModel;

  _SuggestionsList({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final suggestionIds = viewModel.suggestionIds;
    return Column(
      children: [
        for (int index = 0; index < suggestionIds.length; index++) ...[
          index == 0
              ? _SuggestionsHeader(suggestionId: suggestionIds[index])
              : _SuggestionCard(suggestionId: suggestionIds[index]),
          if (index < suggestionIds.length - 1) SizedBox(height: Margins.spacing_base),
        ],
      ],
    );
  }
}

class _SuggestionsEmpty extends StatelessWidget {
  final SuggestionsRechercheListViewModel viewModel;

  _SuggestionsEmpty({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: Margins.spacing_xl),
          Center(
            child: SizedBox(
              height: 130,
              width: 130,
              child: Illustration.grey(AppIcons.checklist_rounded),
            ),
          ),
          SizedBox(height: Margins.spacing_base),
          Text(Strings.emptySuggestionAlerteListTitre, style: TextStyles.textBaseBold, textAlign: TextAlign.center),
          SizedBox(height: Margins.spacing_base),
          Text(
            viewModel.loginMode?.isMiLo() == true
                ? Strings.emptySuggestionAlerteListDescriptionMilo
                : Strings.emptySuggestionAlerteListDescriptionPoleEmploi,
            style: TextStyles.textBaseRegular,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Margins.spacing_xl),
        ],
      ),
    );
  }
}

class _SuggestionsHeader extends StatelessWidget {
  final String suggestionId;

  _SuggestionsHeader({required this.suggestionId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(Strings.suggestionsDeRechercheHeader, style: TextStyles.textBaseRegular),
        SizedBox(height: Margins.spacing_base),
        _SuggestionCard(suggestionId: suggestionId),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String suggestionId;

  _SuggestionCard({required this.suggestionId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SuggestionRechercheCardViewModel?>(
      builder: _builder,
      converter: (store) => SuggestionRechercheCardViewModel.create(store, suggestionId),
      distinct: true,
    );
  }

  Widget _builder(BuildContext context, SuggestionRechercheCardViewModel? viewModel) {
    if (viewModel == null) return SizedBox(height: 0);
    final source = viewModel.source;

    if (1 == 1) {
      // TODO:
      return CardContainer(
        padding: EdgeInsets.all(Margins.spacing_base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(AppIcons.notification_add_outlined, color: AppColors.primary),
                SizedBox(width: Margins.spacing_base),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${Strings.alerte} ${viewModel.type.toAlerteTagLabel()}", style: TextStyles.textSBold),
                      Text(viewModel.titre, style: TextStyles.textSRegular()),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Margins.spacing_base),
            _SuggestionButtons(
              onTapAjouter: () => viewModel.ajouterSuggestion(),
              onTapRefuser: () => viewModel.refuserSuggestion(),
            ),
          ],
        ),
      );
    }

    return BaseCard(
      title: viewModel.titre,
      tag: viewModel.type.toCardTag(),
      complements: [if (viewModel.localisation != null) CardComplement.place(text: viewModel.localisation!)],
      secondaryTags: [
        if (source != null) CardTag.secondary(text: source, semanticsLabel: Strings.source + source),
      ],
      actions: [
        _SuggestionButtons(
          onTapAjouter: () async {
            if (viewModel.withLocationForm) {
              await _selectLocationAndRayon(
                context,
                viewModel.type,
                onSelected: (location, rayon) => viewModel.ajouterSuggestion(location: location, rayon: rayon),
              );
            } else {
              viewModel.ajouterSuggestion();
            }
          },
          onTapRefuser: viewModel.refuserSuggestion,
        ),
      ],
    );
  }

  Future<void> _selectLocationAndRayon(
    BuildContext context,
    OffreType type, {
    required void Function(Location? location, double? rayon) onSelected,
  }) async {
    final locationAndRayon = await Navigator.of(
      context,
    ).push(SuggestionsAlerteLocationForm.materialPageRoute(type: type));

    if (locationAndRayon != null) {
      final (Location location, double rayon) = locationAndRayon;
      onSelected(location, rayon);
    }
  }
}

class _SuggestionButtons extends StatelessWidget {
  final Function() onTapAjouter;
  final Function() onTapRefuser;

  _SuggestionButtons({required this.onTapAjouter, required this.onTapRefuser});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Refuser(onTapRefuser: onTapRefuser)),
        SizedBox(width: Margins.spacing_base),
        Expanded(child: _Ajouter(onTapAjouter: onTapAjouter)),
      ],
    );
  }
}

class _Refuser extends StatelessWidget {
  final Function() onTapRefuser;

  _Refuser({required this.onTapRefuser});

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      label: Strings.refuserLabel,
      onPressed: onTapRefuser,
    );
  }
}

class _Ajouter extends StatelessWidget {
  final Function() onTapAjouter;

  _Ajouter({required this.onTapAjouter});

  @override
  Widget build(BuildContext context) {
    return PrimaryActionButton(
      heightPadding: Margins.spacing_base,
      label: Strings.ajouter,
      iconRightPadding: Margins.spacing_xs,
      withShadow: false,
      onPressed: onTapAjouter,
    );
  }
}

void _displaySuccessSnackbar(
  BuildContext context,
  SuggestionsRechercheListViewModel? oldViewModel,
  SuggestionsRechercheListViewModel newViewModel,
) {
  if (newViewModel.traiterDisplayState != DisplayState.CONTENT) return;
  if (oldViewModel?.traiterDisplayState == DisplayState.CONTENT) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      padding: const EdgeInsets.only(left: 24, bottom: 14),
      duration: Duration(days: 365),
      backgroundColor: AppColors.successLighten,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Icon(
                    AppIcons.check_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  Strings.suggestionRechercheAjoutee,
                  style: TextStyles.textBaseBoldWithColor(AppColors.success),
                ),
              ),
              _CloseSnackbar(newViewModel),
            ],
          ),
          Text(
            Strings.suggestionRechercheAjouteeDescription,
            style: TextStyles.textBaseRegularWithColor(AppColors.success),
          ),
          SizedBox(height: Margins.spacing_s),
          _SeeResults(newViewModel),
        ],
      ),
    ),
  );
}

class _CloseSnackbar extends StatelessWidget {
  final SuggestionsRechercheListViewModel viewModel;

  _CloseSnackbar(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        viewModel.resetTraiterState();
        clearAllSnackBars();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
        child: Icon(
          AppIcons.close_rounded,
          color: AppColors.success,
        ),
      ),
    );
  }
}

class _SeeResults extends StatelessWidget {
  final SuggestionsRechercheListViewModel viewModel;

  _SeeResults(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        viewModel.seeOffreResults();
        viewModel.resetTraiterState();
        clearAllSnackBars();
      },
      child: Row(
        children: [
          Text(
            Strings.voirResultatsSuggestion,
            style: TextStyles.textBaseBoldWithColor(AppColors.success).copyWith(decoration: TextDecoration.underline),
          ),
          Icon(
            AppIcons.chevron_right_rounded,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyles.textMBold.copyWith(color: AppColors.primary));
  }
}
