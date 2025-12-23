import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/models/offre_type.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_emploi_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_immersion_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_service_civique_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherches_recentes.dart';
import 'package:pass_emploi_app/pages/suggestions_recherche/suggestions_recherche_list_page.dart';
import 'package:pass_emploi_app/presentation/recherche/recherche_home_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';
import 'package:pass_emploi_app/widgets/onboarding/onboarding_showcase.dart';
import 'package:pass_emploi_app/widgets/textes.dart';
import 'package:pass_emploi_app/widgets/voir_suggestions_recherche_bandeau.dart';

class RechercheHomePage extends StatefulWidget {
  @override
  State<RechercheHomePage> createState() => _RechercheHomePageState();
}

class _RechercheHomePageState extends State<RechercheHomePage> {
  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.rechercheHome,
      child: StoreConnector<AppState, RechercheHomePageViewModel>(
        converter: (store) => RechercheHomePageViewModel.create(store),
        builder: _builder,
      ),
    );
  }

  Widget _builder(BuildContext context, RechercheHomePageViewModel viewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Margins.spacing_base),
        child: Column(children: [_NosOffres(offreTypes: viewModel.offreTypes)]),
      ),
    );
  }
}

class _NosOffres extends StatelessWidget {
  final List<OffreType> offreTypes;

  const _NosOffres({required this.offreTypes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MediumSectionTitle(Strings.rechercheHomeNosOffres),
        SizedBox(height: Margins.spacing_base),
        RecherchesRecentesBandeau(paddingIfExists: EdgeInsets.only(bottom: Margins.spacing_base)),

        _SolutionGrid(
          tiles: [
            if (offreTypes.contains(OffreType.emploi))
              OnboardingShowcase(
                source: ShowcaseSource.offre,
                child: _BlocSolution(
                  gradientColors: [
                    Color(0xFF274996),
                    Color(0xFF3B69D1),
                  ],
                  title: Strings.rechercheHomeOffresEmploiTitle,
                  subtitle: Strings.rechercheHomeOffresEmploiSubtitle,
                  svgPath: Drawables.rechercheHomeOffresEmploi,
                  onTap: () =>
                      Navigator.push(context, RechercheOffreEmploiPage.materialPageRoute(onlyAlternance: false)),
                ),
              ),
            if (offreTypes.contains(OffreType.alternance))
              _BlocSolution(
                gradientColors: [
                  Color(0xFF172B5A),
                  Color(0xFF2186C7),
                ],
                title: Strings.rechercheHomeOffresAlternanceTitle,
                subtitle: Strings.rechercheHomeOffresAlternanceSubtitle,
                svgPath: Drawables.rechercheHomeOffresAlternance,
                onTap: () => Navigator.push(context, RechercheOffreEmploiPage.materialPageRoute(onlyAlternance: true)),
              ),
            if (offreTypes.contains(OffreType.immersion))
              _BlocSolution(
                gradientColors: [
                  Color(0xFF5149A8),
                  Color(0xFF603CBC),
                  Color(0xFF950EFF),
                ],
                title: Strings.rechercheHomeOffresImmersionTitle,
                subtitle: Strings.rechercheHomeOffresImmersionSubtitle,
                svgPath: Drawables.rechercheHomeOffresImmersion,
                onTap: () => Navigator.push(context, RechercheOffreImmersionPage.materialPageRoute()),
              ),
            if (offreTypes.contains(OffreType.serviceCivique))
              _BlocSolution(
                gradientColors: [
                  Color(0xFF15616D),
                  Color(0xFF0C7A81),
                ],
                title: Strings.rechercheHomeOffresServiceCiviqueTitle,
                subtitle: Strings.rechercheHomeOffresServiceCiviqueSubtitle,
                svgPath: Drawables.rechercheHomeOffresServiceCivique,
                onTap: () => Navigator.push(context, RechercheOffreServiceCiviquePage.materialPageRoute()),
              ),
          ],
          gap: Margins.spacing_base,
        ),
        SizedBox(height: Margins.spacing_base),
        VoirSuggestionsRechercheBandeau(
          onTapShowSuggestions: () {
            PassEmploiMatomoTracker.instance.trackScreen(AnalyticsScreenNames.rechercheSuggestionsListe);
            Navigator.push(context, SuggestionsRechercheListPage.materialPageRoute());
          },
        ),
      ],
    );
  }
}

class _SolutionGrid extends StatelessWidget {
  final List<Widget> tiles;
  final double gap;

  const _SolutionGrid({required this.tiles, required this.gap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final tileWidth = (totalWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: tileWidth,
                  minHeight: _responsiveChildHeight(context),
                ),
                child: tile,
              ),
          ],
        );
      },
    );
  }

  double _responsiveChildHeight(BuildContext context) {
    final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    return 200 * textScaleFactor;
  }
}

class _BlocSolution extends StatelessWidget {
  final String title;
  final String subtitle;
  final String svgPath;
  final List<Color> gradientColors;
  final void Function() onTap;

  const _BlocSolution({
    required this.title,
    required this.subtitle,
    required this.svgPath,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: CardContainer(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(svgPath, width: Dimens.icon_size_m, height: Dimens.icon_size_m),
            SizedBox(height: Margins.spacing_s),
            Text(title, style: TextStyles.textMBold.copyWith(color: Colors.white)),
            SizedBox(height: Margins.spacing_s),
            Text(subtitle, style: TextStyles.textBaseRegular.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
