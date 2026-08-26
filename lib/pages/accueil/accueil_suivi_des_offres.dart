import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/deep_link/deep_link_actions.dart';
import 'package:pass_emploi_app/models/deep_link.dart';
import 'package:pass_emploi_app/presentation/accueil/accueil_item.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/textes.dart';

class AccueilSuiviDesOffres extends StatelessWidget {
  final AccueilSuiviDesOffresItem item;

  AccueilSuiviDesOffres(this.item);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LargeSectionTitle(Strings.accueilOffresEnregistreesSection),
        const SizedBox(height: DsfrSpacings.s2w),
        Semantics(
          button: true,
          label: '${Strings.suivezVosOffres}. ${Strings.suivezVosOffresDescription}',
          onTap: () => _goToOffresEnregistrees(context),
          child: ExcludeSemantics(
            child: DsfrTile(
              size: DsfrComponentSize.sm,
              direction: Axis.horizontal,
              title: Strings.suivezVosOffres,
              description: Strings.suivezVosOffresDescription,
              imageAsset: 'assets/illustrations/accueil_offres_suivies.webp',
              onTap: () => _goToOffresEnregistrees(context),
            ),
          ),
        ),
      ],
    );
  }

  void _goToOffresEnregistrees(BuildContext context) {
    PassEmploiMatomoTracker.instance.trackEvent(
      eventCategory: AnalyticsEventNames.accueilCategory,
      action: AnalyticsEventNames.acceuilClicSurSuiviDesOffres,
    );
    StoreProvider.of<AppState>(
      context,
    ).dispatch(HandleDeepLinkAction(OffresEnregistreesDeepLink(), DeepLinkOrigin.inAppNavigation));
  }
}
