import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/models/offre_type.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_emploi_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_immersion_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_service_civique_page.dart';
import 'package:pass_emploi_app/presentation/recherche/recherche_home_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';
import 'package:pass_emploi_app/widgets/mes_outils_card.dart';
import 'package:pass_emploi_app/widgets/onboarding/onboarding_showcase.dart';
import 'package:pass_emploi_app/widgets/tags/data_tag.dart';

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
        child: Column(children: [_NosOffres(viewModel: viewModel)]),
      ),
    );
  }
}

class _NosOffres extends StatelessWidget {
  final RechercheHomePageViewModel viewModel;

  const _NosOffres({required this.viewModel});

  void _onOffreTypeTap(BuildContext context, OffreType offreType) {
    viewModel.onOffreTypeTap(offreType);
    Navigator.push(context, switch (offreType) {
      OffreType.emploi => RechercheOffreEmploiPage.materialPageRoute(onlyAlternance: false),
      OffreType.alternance => RechercheOffreEmploiPage.materialPageRoute(onlyAlternance: true),
      OffreType.immersion => RechercheOffreImmersionPage.materialPageRoute(),
      OffreType.serviceCivique => RechercheOffreServiceCiviquePage.materialPageRoute(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final offreTypes = viewModel.offreTypes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CriteresUtilisateur(metierLabel: viewModel.metierLabel, lieuLabel: viewModel.lieuLabel),
        SizedBox(height: Margins.spacing_base),
        _SolutionGrid(
          tiles: [
            if (offreTypes.contains(OffreType.emploi))
              OnboardingShowcase(
                source: ShowcaseSource.offre,
                child: _BlocSolution(
                  gradientColors: AppColors.gradientOffre,
                  title: Strings.rechercheHomeOffresEmploiTitle,
                  subtitle: Strings.rechercheHomeOffresEmploiSubtitle,
                  svgPath: Drawables.rechercheHomeOffresEmploi,
                  onTap: () => _onOffreTypeTap(context, OffreType.emploi),
                ),
              ),
            if (offreTypes.contains(OffreType.alternance))
              _BlocSolution(
                gradientColors: AppColors.gradientAlternance,
                title: Strings.rechercheHomeOffresAlternanceTitle,
                subtitle: Strings.rechercheHomeOffresAlternanceSubtitle,
                svgPath: Drawables.rechercheHomeOffresAlternance,
                onTap: () => _onOffreTypeTap(context, OffreType.alternance),
              ),
            if (offreTypes.contains(OffreType.immersion))
              _BlocSolution(
                gradientColors: AppColors.gradientImmersion,
                title: Strings.rechercheHomeOffresImmersionTitle,
                subtitle: Strings.rechercheHomeOffresImmersionSubtitle,
                svgPath: Drawables.rechercheHomeOffresImmersion,
                onTap: () => _onOffreTypeTap(context, OffreType.immersion),
              ),
            if (offreTypes.contains(OffreType.serviceCivique))
              _BlocSolution(
                gradientColors: AppColors.gradientServiceCivique,
                title: Strings.rechercheHomeOffresServiceCiviqueTitle,
                subtitle: Strings.rechercheHomeOffresServiceCiviqueSubtitle,
                svgPath: Drawables.rechercheHomeOffresServiceCivique,
                onTap: () => _onOffreTypeTap(context, OffreType.serviceCivique),
              ),
          ],
          gap: Margins.spacing_base,
        ),
        SizedBox(height: Margins.spacing_base),
        MesOutilsCard(),
      ],
    );
  }
}

class _CriteresUtilisateur extends StatelessWidget {
  final String? metierLabel;
  final String? lieuLabel;

  const _CriteresUtilisateur({required this.metierLabel, required this.lieuLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Strings.rechercheHomeCriteresTitle, style: TextStyles.textBaseBold.copyWith(color: context.content)),
        SizedBox(height: Margins.spacing_s),
        Wrap(
          spacing: Margins.spacing_xs,
          runSpacing: Margins.spacing_xs,
          children: [
            _CritereRow(
              icon: AppIcons.work_outline_rounded,
              label: metierLabel,
              emptyLabel: Strings.rechercheHomeCriteresMetierVide,
            ),
            _CritereRow(
              icon: AppIcons.place_outlined,
              label: lieuLabel,
              emptyLabel: Strings.rechercheHomeCriteresLieuVide,
            ),
          ],
        ),
      ],
    );
  }
}

class _CritereRow extends StatelessWidget {
  final IconData icon;
  final String? label;
  final String emptyLabel;

  const _CritereRow({required this.icon, required this.label, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    return DataTag(label: label ?? emptyLabel, iconSemantics: IconWithSemantics(icon, emptyLabel));
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
            Text(title, style: TextStyles.textMBold.copyWith(color: AppColors.contentOnPrimary)),
            SizedBox(height: Margins.spacing_s),
            Text(subtitle, style: TextStyles.textBaseRegular.copyWith(color: AppColors.contentOnPrimary)),
          ],
        ),
      ),
    );
  }
}
