import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
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
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/utils/store_extensions.dart';
import 'package:pass_emploi_app/widgets/alerte_card.dart';
import 'package:pass_emploi_app/widgets/animated_list_loader.dart';
import 'package:pass_emploi_app/widgets/buttons/filtre_button.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/cards/alerte_deletable_card.dart';
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
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
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
            padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, DsfrSpacings.s2w, DsfrSpacings.s2w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    Strings.alertesCountTitle(alertes.length),
                    style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                ),
                const SizedBox(height: DsfrSpacings.s3v),
                Text(
                  Strings.alertesCreationHint,
                  style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textTitleGrey(context)),
                ),
              ],
            ),
          ),
        ),
        if (alertes.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
              child: SizedBox(height: DsfrSpacings.s2w),
            ),
          ),
        if (alertes.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
              child: _noAlerte(),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(DsfrSpacings.s2w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index.isOdd) return const SizedBox(height: DsfrSpacings.s3v);
                  final itemIndex = index ~/ 2;
                  final alerte = alertes[itemIndex];
                  return switch (alerte) {
                    OffreEmploiAlerte() => _buildEmploiCard(context, alerte, viewModel),
                    ImmersionAlerte() => _buildImmersionCard(context, alerte, viewModel),
                    ServiceCiviqueAlerte() => _buildServiceCiviqueCard(context, alerte, viewModel),
                    _ => const SizedBox.shrink(),
                  };
                },
                childCount: alertes.isEmpty ? 0 : alertes.length * 2 - 1,
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(DsfrSpacings.s2w),
            child: _suggestionsSection(context, suggestionsViewModel),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: DsfrSpacings.s8w)),
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
      trackingSource: AlerteCardTrackingSource.alertes,
    );
  }

  Widget _buildImmersionCard(BuildContext context, ImmersionAlerte alertesImmersion, AlerteListViewModel viewModel) {
    return AlerteDeletableCard(
      offreType: OffreType.immersion,
      onTap: () => viewModel.offreImmersionSelected(alertesImmersion),
      onDelete: () => _showDeleteDialog(viewModel, alertesImmersion.id, AlerteType.IMMERSION),
      title: alertesImmersion.title,
      place: alertesImmersion.ville,
      trackingSource: AlerteCardTrackingSource.alertes,
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
      trackingSource: AlerteCardTrackingSource.alertes,
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
    AlerteDeleteDialog.show(context, alerteId, type).then((result) {
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

Widget _suggestionsSection(BuildContext context, SuggestionsRechercheListViewModel viewModel) {
  final content = switch (viewModel.displayState) {
    DisplayState.EMPTY => _SuggestionsEmpty(viewModel: viewModel),
    DisplayState.CONTENT => _SuggestionsList(viewModel: viewModel),
    DisplayState.LOADING => Center(
      child: CircularProgressIndicator(
        color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
      ),
    ),
    DisplayState.FAILURE => Retry(Strings.vosSuggestionsAlertesError, () => viewModel.retryFetchSuggestions()),
  };
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        header: true,
        child: Text(
          Strings.suggestionsDeRechercheTitle,
          style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
      ),
      const SizedBox(height: DsfrSpacings.s2w),
      content,
    ],
  );
}

class _SuggestionsList extends StatelessWidget {
  final SuggestionsRechercheListViewModel viewModel;

  const _SuggestionsList({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final suggestionIds = viewModel.suggestionIds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.suggestionsDeRechercheHeader,
          style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        for (int index = 0; index < suggestionIds.length; index++) ...[
          _SuggestionCard(suggestionId: suggestionIds[index]),
          if (index < suggestionIds.length - 1) const SizedBox(height: DsfrSpacings.s3v),
        ],
      ],
    );
  }
}

class _SuggestionsEmpty extends StatelessWidget {
  final SuggestionsRechercheListViewModel viewModel;

  const _SuggestionsEmpty({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return DsfrAlert(
      type: DsfrAlertType.info,
      title: Strings.emptySuggestionAlerteListTitre,
      description: DsfrAlertDescriptionText(
        viewModel.loginMode?.isMiLo() == true
            ? Strings.emptySuggestionAlerteListDescriptionMilo
            : Strings.emptySuggestionAlerteListDescriptionPoleEmploi,
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String suggestionId;

  const _SuggestionCard({required this.suggestionId});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SuggestionRechercheCardViewModel?>(
      builder: _builder,
      converter: (store) => SuggestionRechercheCardViewModel.create(store, suggestionId),
      distinct: true,
    );
  }

  Widget _builder(BuildContext context, SuggestionRechercheCardViewModel? viewModel) {
    if (viewModel == null) return const SizedBox.shrink();

    final source = viewModel.source;
    final localisation = viewModel.localisation;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s3v),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: DsfrSpacings.s1w,
              runSpacing: DsfrSpacings.s1v,
              children: [
                DsfrTag(
                  label: _suggestionTypeLabel(viewModel.type),
                  size: DsfrComponentSize.sm,
                  backgroundColor: DsfrColorDecisions.backgroundContrastGrey(context),
                  textColor: DsfrColorDecisions.textLabelGrey(context),
                ),
                if (source != null)
                  DsfrTag(
                    label: source,
                    size: DsfrComponentSize.sm,
                    backgroundColor: DsfrColorDecisions.backgroundContrastGrey(context),
                    textColor: DsfrColorDecisions.textLabelGrey(context),
                  ),
              ],
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            Text(
              viewModel.titre,
              style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleBlueFrance(context)),
            ),
            if (localisation != null && localisation.isNotEmpty) ...[
              const SizedBox(height: DsfrSpacings.s1v),
              Row(
                children: [
                  Icon(
                    DsfrIcons.mapMapPin2Line,
                    size: DsfrSpacings.s2w,
                    color: DsfrColorDecisions.textDefaultGrey(context),
                  ),
                  const SizedBox(width: DsfrSpacings.s1v),
                  Expanded(
                    child: Text(
                      localisation,
                      style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: DsfrSpacings.s2w),
            _SuggestionButtons(
              onTapAjouter: () => _onAjouter(context, viewModel),
              onTapRefuser: viewModel.refuserSuggestion,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAjouter(BuildContext context, SuggestionRechercheCardViewModel viewModel) async {
    if (!viewModel.withLocationForm) {
      viewModel.ajouterSuggestion();
      return;
    }

    final locationAndRayon = await Navigator.of(context).push(
      SuggestionsAlerteLocationForm.materialPageRoute(type: viewModel.type),
    );
    if (locationAndRayon == null) return;

    final (Location location, double rayon) = locationAndRayon;
    viewModel.ajouterSuggestion(location: location, rayon: rayon);
  }
}

class _SuggestionButtons extends StatelessWidget {
  final VoidCallback onTapAjouter;
  final VoidCallback onTapRefuser;

  const _SuggestionButtons({required this.onTapAjouter, required this.onTapRefuser});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DsfrButton(
            label: Strings.refuserLabel,
            variant: DsfrButtonVariant.secondary,
            size: DsfrComponentSize.md,
            onPressed: onTapRefuser,
          ),
        ),
        const SizedBox(width: DsfrSpacings.s2w),
        Expanded(
          child: DsfrButton(
            label: Strings.ajouter,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.md,
            onPressed: onTapAjouter,
          ),
        ),
      ],
    );
  }
}

String _suggestionTypeLabel(OffreType type) {
  return switch (type) {
    OffreType.emploi => Strings.offreTypeEmploiLabel,
    OffreType.alternance => Strings.alternanceTag,
    OffreType.immersion => Strings.immersionTag,
    OffreType.serviceCivique => Strings.serviceCiviqueTag,
  };
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
      duration: const Duration(days: 365),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      content: ColoredBox(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        child: DsfrAlert(
          type: DsfrAlertType.success,
          title: Strings.suggestionRechercheAjoutee,
          description: DsfrAlertDescriptionWidget(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Strings.suggestionRechercheAjouteeDescription,
                  style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                ),
                const SizedBox(height: DsfrSpacings.s1w),
                DsfrLink(
                  label: Strings.voirResultatsSuggestion,
                  icon: DsfrIcons.systemArrowRightLine,
                  iconPosition: DsfrLinkIconPosition.end,
                  size: DsfrComponentSize.md,
                  onTap: () {
                    newViewModel.seeOffreResults();
                    newViewModel.resetTraiterState();
                    clearAllSnackBars();
                  },
                ),
              ],
            ),
          ),
          onClose: () {
            newViewModel.resetTraiterState();
            clearAllSnackBars();
          },
        ),
      ),
    ),
  );
}
