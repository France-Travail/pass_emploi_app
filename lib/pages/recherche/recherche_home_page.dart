import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/models/solution_type.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_emploi_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_immersion_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_service_civique_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherches_recentes.dart';
import 'package:pass_emploi_app/pages/suggestions_recherche/suggestions_recherche_list_page.dart';
import 'package:pass_emploi_app/presentation/recherche/recherche_home_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';
import 'package:pass_emploi_app/widgets/voir_suggestions_recherche_bandeau.dart';

class RechercheHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.rechercheV2Home,
      child: StoreConnector<AppState, RechercheHomePageViewModel>(
        converter: (store) => RechercheHomePageViewModel.create(store),
        builder: _builder,
        distinct: true,
      ),
    );
  }

  Widget _builder(BuildContext context, RechercheHomePageViewModel viewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Margins.spacing_base),
        child: Column(
          children: [
            RecherchesRecentes(),
            _NosOffres(solutionTypes: viewModel.solutionTypes),
          ],
        ),
      ),
    );
  }
}

class _NosOffres extends StatelessWidget {
  final List<SolutionType> solutionTypes;

  const _NosOffres({required this.solutionTypes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.rechercheHomeNosOffres,
          style: TextStyles.textLBold(color: AppColors.primary),
        ),
        SizedBox(height: Margins.spacing_base),
        VoirSuggestionsRechercheBandeau(
          onTapShowSuggestions: () {
            PassEmploiMatomoTracker.instance.trackScreen(AnalyticsScreenNames.rechercheSuggestionsListe);
            Navigator.push(context, SuggestionsRechercheListPage.materialPageRoute());
          },
        ),
        SizedBox(height: Margins.spacing_base),
        if (solutionTypes.contains(SolutionType.OffreEmploi)) ...[
          _BlocSolution(
            title: Strings.rechercheHomeOffresEmploiTitle,
            subtitle: Strings.rechercheHomeOffresEmploiSubtitle,
            icon: Icon(AppIcons.description_rounded, color: AppColors.additional4, size: Dimens.icon_size_m),
            onTap: () => Navigator.push(context, RechercheOffreEmploiPage.materialPageRoute(onlyAlternance: false)),
          ),
          SizedBox(height: Margins.spacing_base),
        ],
        if (solutionTypes.contains(SolutionType.Alternance)) ...[
          _BlocSolution(
            title: Strings.rechercheHomeOffresAlternanceTitle,
            subtitle: Strings.rechercheHomeOffresAlternanceSubtitle,
            icon: Icon(AppIcons.signpost_rounded, color: AppColors.additional3, size: Dimens.icon_size_m),
            onTap: () => Navigator.push(context, RechercheOffreEmploiPage.materialPageRoute(onlyAlternance: true)),
          ),
          SizedBox(height: Margins.spacing_base),
        ],
        if (solutionTypes.contains(SolutionType.Immersion)) ...[
          _BlocSolution(
            title: Strings.rechercheHomeOffresImmersionTitle,
            subtitle: Strings.rechercheHomeOffresImmersionSubtitle,
            icon: Icon(AppIcons.immersion, color: AppColors.additional1, size: Dimens.icon_size_m),
            onTap: () => Navigator.push(context, RechercheOffreImmersionPage.materialPageRoute()),
          ),
          SizedBox(height: Margins.spacing_base),
        ],
        if (solutionTypes.contains(SolutionType.ServiceCivique)) ...[
          _BlocSolution(
            title: Strings.rechercheHomeOffresServiceCiviqueTitle,
            subtitle: Strings.rechercheHomeOffresServiceCiviqueSubtitle,
            icon: Row(
              children: [
                Icon(AppIcons.service_civique, color: AppColors.additional2, size: Dimens.icon_size_base),
                SizedBox(width: Margins.spacing_s), // due to icon not having the same width as the other icons
              ],
            ),
            onTap: () => Navigator.push(context, RechercheOffreServiceCiviquePage.materialPageRoute()),
          ),
        ],
      ],
    );
  }
}

class _BlocSolution extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final void Function() onTap;

  const _BlocSolution({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: Margins.spacing_base),
              Expanded(child: Text(title, style: TextStyles.textMBold)),
            ],
          ),
          SizedBox(height: Margins.spacing_base),
          Text(subtitle, style: TextStyles.textBaseRegular),
          SizedBox(height: Margins.spacing_base),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Strings.rechercheHomeCardLink, style: TextStyles.textBaseRegular),
                Icon(AppIcons.chevron_right_rounded, color: AppColors.contentColor, size: Dimens.icon_size_base),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
