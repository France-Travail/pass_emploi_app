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
import 'package:pass_emploi_app/widgets/alerte_card.dart';
import 'package:pass_emploi_app/widgets/textes.dart';

class AccueilAlertes extends StatelessWidget {
  final AccueilAlertesItem item;

  AccueilAlertes(this.item);

  @override
  Widget build(BuildContext context) {
    final hasContent = item.alertes.isNotEmpty;
    return AlerteNavigator(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LargeSectionTitle(Strings.accueilMesAlertesSection),
          const SizedBox(height: DsfrSpacings.s2w),
          if (hasContent) _AvecAlertes(item),
          if (!hasContent) const _SansAlerte(),
        ],
      ),
    );
  }
}

class _AvecAlertes extends StatelessWidget {
  final AccueilAlertesItem item;

  _AvecAlertes(this.item);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final search in item.alertes) ...[
          AlerteCard(search),
          const SizedBox(height: DsfrSpacings.s2w),
        ],
        DsfrButton(
          label: Strings.accueilVoirMesAlertes,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.md,
          onPressed: () => goToAlerte(context),
        ),
      ],
    );
  }

  void goToAlerte(BuildContext context) {
    PassEmploiMatomoTracker.instance.trackScreen(AnalyticsScreenNames.alerteListFromAccueil);
    StoreProvider.of<AppState>(
      context,
    ).dispatch(HandleDeepLinkAction(AlertesDeepLink(), DeepLinkOrigin.inAppNavigation));
  }
}

class _SansAlerte extends StatelessWidget {
  const _SansAlerte();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsfrAlert(
          type: DsfrAlertType.info,
          description: DsfrAlertDescriptionText(Strings.accueilPasDalerteDescription),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: Strings.accueilPasDalerteBouton,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.md,
          onPressed: () => goToRecherche(context),
        ),
      ],
    );
  }

  void goToRecherche(BuildContext context) {
    StoreProvider.of<AppState>(context).dispatch(
      HandleDeepLinkAction(
        RechercheDeepLink(),
        DeepLinkOrigin.inAppNavigation,
      ),
    );
  }
}
