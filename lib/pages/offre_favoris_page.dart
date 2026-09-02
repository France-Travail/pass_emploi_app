import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/features/favori/ids/favori_ids_state.dart';
import 'package:pass_emploi_app/features/favori/list/favori_list_actions.dart';
import 'package:pass_emploi_app/models/favori.dart';
import 'package:pass_emploi_app/models/immersion.dart';
import 'package:pass_emploi_app/models/offre_emploi.dart';
import 'package:pass_emploi_app/models/offre_type.dart';
import 'package:pass_emploi_app/models/service_civique.dart';
import 'package:pass_emploi_app/pages/immersion/immersion_details_page.dart';
import 'package:pass_emploi_app/pages/offre_emploi/offre_emploi_details_page.dart';
import 'package:pass_emploi_app/pages/service_civique/service_civique_detail_page.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/presentation/favori_list_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/animation_durations.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/animated_list_loader.dart';
import 'package:pass_emploi_app/widgets/cards/suivi_offre_card.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_empty_state.dart';
import 'package:pass_emploi_app/widgets/favori_state_selector.dart';
import 'package:pass_emploi_app/widgets/retry.dart';
import 'package:redux/redux.dart';

class OffreFavorisPage extends StatelessWidget {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.offreFavorisList,
      child: StoreConnector<AppState, FavoriListViewModel>(
        onInit: (store) => store.dispatch(FavoriListRequestAction()),
        converter: (store) => FavoriListViewModel.create(store),
        builder: _builder,
        distinct: true,
      ),
    );
  }

  Widget _builder(BuildContext context, FavoriListViewModel viewModel) {
    return Center(
      child: AnimatedSwitcher(
        duration: AnimationDurations.fast,
        child: switch (viewModel.displayState) {
          DisplayState.LOADING => _Loading(),
          DisplayState.FAILURE => Retry(Strings.offresEnregistreesError, () => viewModel.onRetry()),
          DisplayState.EMPTY => _Empty(),
          DisplayState.CONTENT => _Content(viewModel: viewModel, scrollController: _scrollController),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.viewModel, required this.scrollController});

  final FavoriListViewModel viewModel;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
      children: [
        const SizedBox(height: DsfrSpacings.s2w),
        Semantics(
          header: true,
          child: Text(
            Strings.suiviPostuleesCount(viewModel.postulees.length),
            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s3v),
        ..._cards(context, viewModel.postulees, showCandidatureBadge: true),
        const SizedBox(height: DsfrSpacings.s2w),
        Semantics(
          header: true,
          child: Text(
            Strings.suiviFavorisCount(viewModel.favorisSansPostulation.length),
            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s3v),
        if (viewModel.favorisSansPostulation.isEmpty)
          Text(
            Strings.suiviFavorisEmptyHint,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textTitleGrey(context)),
          )
        else
          ..._cards(context, viewModel.favorisSansPostulation, showCandidatureBadge: false),
        const SizedBox(height: DsfrSpacings.s3w),
      ],
    );
  }

  List<Widget> _cards(BuildContext context, List<Favori> items, {required bool showCandidatureBadge}) {
    return [
      for (final favori in items) ...[
        _buildFavoriCard(context, favori, showCandidatureBadge: showCandidatureBadge),
        const SizedBox(height: DsfrSpacings.s3v),
      ],
    ];
  }

  Widget _buildFavoriCard(BuildContext context, Favori favori, {required bool showCandidatureBadge}) {
    return switch (favori.type) {
      OffreType.emploi || OffreType.alternance => _buildItem<OffreEmploi>(
        context: context,
        favori: favori,
        showCandidatureBadge: showCandidatureBadge,
        selectState: (store) => store.state.offreEmploiFavorisIdsState,
        onTap: () => Navigator.push(
          context,
          OffreEmploiDetailsPage.materialPageRoute(
            favori.id,
            fromAlternance: favori.type == OffreType.alternance,
          ),
        ),
      ),
      OffreType.immersion => _buildItem<Immersion>(
        context: context,
        favori: favori,
        showCandidatureBadge: showCandidatureBadge,
        selectState: (store) => store.state.immersionFavorisIdsState,
        onTap: () => Navigator.push(
          context,
          ImmersionDetailsPage.materialPageRoute(
            favori.id,
            popPageWhenFavoriIsRemoved: true,
          ),
        ),
      ),
      OffreType.serviceCivique => _buildItem<ServiceCivique>(
        context: context,
        favori: favori,
        showCandidatureBadge: showCandidatureBadge,
        selectState: (store) => store.state.serviceCiviqueFavorisIdsState,
        onTap: () => Navigator.push(
          context,
          ServiceCiviqueDetailPage.materialPageRoute(favori.id, true),
        ),
      ),
    };
  }

  Widget _buildItem<T>({
    required BuildContext context,
    required Favori favori,
    required bool showCandidatureBadge,
    required FavoriIdsState<T> Function(Store<AppState> store) selectState,
    required VoidCallback onTap,
  }) {
    return FavorisStateContext<T>(
      selectState: selectState,
      child: SuiviOffreCard<T>(
        id: favori.id,
        offreType: favori.type,
        title: favori.titre,
        company: favori.organisation,
        place: favori.localisation,
        origin: favori.origin,
        onTap: onTap,
        showCandidatureBadge: showCandidatureBadge,
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DsfrEmptyState(
      centered: true,
      title: Strings.offresEnregistreesEmptyTitle,
      subtitle: Strings.offresEnregistreesEmptySubtitle,
      buttonLabel: Strings.offresEnregistreesEmptyButton,
      onButtonPressed: () => DefaultTabController.of(context).animateTo(0),
    );
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AnimatedListLoader(
      placeholders: [
        for (var i = 0; i < 5; i++) ...[
          AnimatedListLoader.placeholderBuilder(width: screenWidth, height: 120),
          const SizedBox(height: DsfrSpacings.s2w),
        ],
      ],
    );
  }
}
