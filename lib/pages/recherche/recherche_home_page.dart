import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/models/offre_type.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_emploi_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_immersion_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_service_civique_page.dart';
import 'package:pass_emploi_app/presentation/recherche/recherche_home_page_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/emoji_solution_tile.dart';
import 'package:pass_emploi_app/widgets/mes_outils_card.dart';
import 'package:pass_emploi_app/widgets/onboarding/onboarding_showcase.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: DsfrSpacings.s2w),
            _CriteresUtilisateur(metierLabel: viewModel.metierLabel, lieuLabel: viewModel.lieuLabel),
            const SizedBox(height: DsfrSpacings.s3v),
            _NosOffres(viewModel: viewModel),
            const SizedBox(height: DsfrSpacings.s2w),
            const MesOutilsCard(),
            const SizedBox(height: DsfrSpacings.s3w),
          ],
        ),
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
        Semantics(
          header: true,
          child: Text(
            Strings.rechercheHomeExplorerParType,
            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        EmojiSolutionGrid(
          tiles: [
            if (offreTypes.contains(OffreType.emploi))
              OnboardingShowcase(
                source: ShowcaseSource.offre,
                child: EmojiSolutionTile(
                  emoji: Strings.rechercheHomeEmploiEmoji,
                  emojiBackground: DsfrColors.blueEcume925,
                  title: Strings.rechercheHomeOffresEmploiTitle,
                  subtitle: Strings.rechercheHomeOffresEmploiSubtitle,
                  onTap: () => _onOffreTypeTap(context, OffreType.emploi),
                ),
              ),
            if (offreTypes.contains(OffreType.alternance))
              EmojiSolutionTile(
                emoji: Strings.rechercheHomeAlternanceEmoji,
                emojiBackground: DsfrColors.success950,
                title: Strings.rechercheHomeOffresAlternanceTitle,
                subtitle: Strings.rechercheHomeOffresAlternanceSubtitle,
                onTap: () => _onOffreTypeTap(context, OffreType.alternance),
              ),
            if (offreTypes.contains(OffreType.immersion))
              EmojiSolutionTile(
                emoji: Strings.rechercheHomeImmersionEmoji,
                emojiBackground: DsfrColors.greenTilleulVerveine950,
                title: Strings.rechercheHomeOffresImmersionTitle,
                subtitle: Strings.rechercheHomeOffresImmersionSubtitle,
                onTap: () => _onOffreTypeTap(context, OffreType.immersion),
              ),
            if (offreTypes.contains(OffreType.serviceCivique))
              EmojiSolutionTile(
                emoji: Strings.rechercheHomeServiceCiviqueEmoji,
                emojiBackground: DsfrColors.purpleGlycine925,
                title: Strings.rechercheHomeOffresServiceCiviqueTitle,
                subtitle: Strings.rechercheHomeOffresServiceCiviqueSubtitle,
                onTap: () => _onOffreTypeTap(context, OffreType.serviceCivique),
              ),
          ],
        ),
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
    return Semantics(
      container: true,
      label: Strings.rechercheHomeCriteresTitle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DsfrColorDecisions.backgroundDefaultGrey(context),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: DsfrColorDecisions.backgroundOpenBlueFrance(context)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s3v, vertical: DsfrSpacings.s1w + 2),
          child: Wrap(
            spacing: DsfrSpacings.s1w,
            runSpacing: DsfrSpacings.s1w,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                Strings.rechercheHomeCriteresTitle.toUpperCase(),
                style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
              DsfrTag(
                label: metierLabel ?? Strings.rechercheHomeCriteresMetierVide,
                size: DsfrComponentSize.md,
                backgroundColor: DsfrColorDecisions.backgroundContrastGrey(context),
                textColor: DsfrColorDecisions.textLabelGrey(context),
              ),
              DsfrTag(
                label: lieuLabel ?? Strings.rechercheHomeCriteresLieuVide,
                size: DsfrComponentSize.md,
                icon: DsfrIcons.mapMapPin2Line,
                backgroundColor: DsfrColorDecisions.backgroundContrastGrey(context),
                textColor: DsfrColorDecisions.textLabelGrey(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
