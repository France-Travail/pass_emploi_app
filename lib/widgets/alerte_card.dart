import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/models/alerte/alerte.dart';
import 'package:pass_emploi_app/models/alerte/immersion_alerte.dart';
import 'package:pass_emploi_app/models/alerte/offre_emploi_alerte.dart';
import 'package:pass_emploi_app/models/alerte/service_civique_alerte.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_emploi_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_immersion_page.dart';
import 'package:pass_emploi_app/pages/recherche/recherche_offre_service_civique_page.dart';
import 'package:pass_emploi_app/presentation/alerte/alerte_navigation_state.dart';
import 'package:pass_emploi_app/presentation/alerte_card_view_model.dart';
import 'package:pass_emploi_app/presentation/alerte_navigator_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/redux/store_connector_aware.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';

class AlerteNavigator extends StatefulWidget {
  final Widget child;

  AlerteNavigator({required this.child});

  @override
  State<AlerteNavigator> createState() => _AlerteNavigatorState();
}

class _AlerteNavigatorState extends State<AlerteNavigator> {
  bool _shouldNavigate = true;

  @override
  Widget build(BuildContext context) {
    return StoreConnectorAware<AlerteNavigatorViewModel>(
      converter: (store) => AlerteNavigatorViewModel.create(store),
      builder: (_, __) => widget.child,
      onWillChange: _onWillChange,
      distinct: true,
    );
  }

  void _onWillChange(AlerteNavigatorViewModel? _, AlerteNavigatorViewModel? newViewModel) {
    if (!_shouldNavigate || newViewModel == null) return;
    final Widget? page = switch (newViewModel.searchNavigationState) {
      AlerteNavigationState.OFFRE_EMPLOI => RechercheOffreEmploiPage(onlyAlternance: false),
      AlerteNavigationState.OFFRE_ALTERNANCE => RechercheOffreEmploiPage(onlyAlternance: true),
      AlerteNavigationState.OFFRE_IMMERSION => RechercheOffreImmersionPage(),
      AlerteNavigationState.SERVICE_CIVIQUE => RechercheOffreServiceCiviquePage(),
      AlerteNavigationState.NONE => null,
    };
    if (page != null) {
      _shouldNavigate = false;
      Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) => _shouldNavigate = true);
    }
  }
}

class AlerteCardContent extends StatelessWidget {
  const AlerteCardContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onDelete,
    required this.onTap,
    required this.trackingSource,
  });

  final String title;
  final String subtitle;
  final void Function()? onDelete;
  final void Function() onTap;
  final AlerteCardTrackingSource trackingSource;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DsfrColorDecisions.backgroundDefaultGrey(context),
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      child: InkWell(
        onTap: () {
          _trackAlerteCardPressed(trackingSource);
          onTap();
        },
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DsfrSpacings.s3v),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleBlueFrance(context)),
                      ),
                      Text(
                        subtitle,
                        style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textTitleGrey(context)),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    tooltip: Strings.alerteDeleteMessageTitle,
                    icon: Icon(
                      DsfrIcons.systemDeleteBinLine,
                      color: DsfrColorDecisions.textTitleBlueFrance(context),
                      size: DsfrSpacings.s2w,
                    ),
                  ),
                Icon(
                  DsfrIcons.systemArrowRightSLine,
                  color: DsfrColorDecisions.textTitleBlueFrance(context),
                  size: DsfrSpacings.s2w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum AlerteCardTrackingSource { accueil, alertes }

void _trackAlerteCardPressed(AlerteCardTrackingSource source) {
  PassEmploiMatomoTracker.instance.trackEvent(
    eventCategory: AnalyticsEventNames.alerteCategory,
    action: AnalyticsEventNames.alerteCardPressed,
    eventName: source.name,
  );
}

class AlerteCard extends StatelessWidget {
  final Alerte alerte;

  AlerteCard(this.alerte);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AlerteCardViewModel>(
      converter: (store) => AlerteCardViewModel.create(store),
      builder: (context_, viewModel) => _Body(alerte, viewModel),
      distinct: true,
    );
  }
}

class _Body extends StatelessWidget {
  final Alerte alerte;
  final AlerteCardViewModel viewModel;

  _Body(this.alerte, this.viewModel);

  @override
  Widget build(BuildContext context) {
    final alerteCast = alerte;
    return switch (alerteCast) {
      OffreEmploiAlerte() => _buildEmploiAndAlternanceCard(alerteCast, viewModel),
      ImmersionAlerte() => _buildImmersionCard(alerteCast, viewModel),
      ServiceCiviqueAlerte() => _buildServiceCiviqueCard(alerteCast, viewModel),
      _ => Container(),
    };
  }
}

Widget _buildEmploiAndAlternanceCard(OffreEmploiAlerte alerte, AlerteCardViewModel viewModel) {
  return AlerteCardContent(
    title: _buildAlerteTitle(alerte.onlyAlternance ? Strings.alternanceTag : Strings.emploiTag),
    subtitle: _buildAlerteSubtitle(alerte.title),
    onTap: () => viewModel.fetchAlerteResult(alerte),
    onDelete: null,
    trackingSource: AlerteCardTrackingSource.accueil,
  );
}

Widget _buildImmersionCard(ImmersionAlerte alerte, AlerteCardViewModel viewModel) {
  return AlerteCardContent(
    title: _buildAlerteTitle(Strings.immersionTag),
    subtitle: _buildAlerteSubtitle(alerte.title),
    onTap: () => viewModel.fetchAlerteResult(alerte),
    onDelete: null,
    trackingSource: AlerteCardTrackingSource.accueil,
  );
}

Widget _buildServiceCiviqueCard(ServiceCiviqueAlerte alerte, AlerteCardViewModel viewModel) {
  return AlerteCardContent(
    title: _buildAlerteTitle(Strings.serviceCiviqueTag),
    subtitle: _buildAlerteSubtitle(alerte.titre),
    onTap: () => viewModel.fetchAlerteResult(alerte),
    onDelete: null,
    trackingSource: AlerteCardTrackingSource.accueil,
  );
}

String _buildAlerteTitle(String tagLabel) => "Alerte $tagLabel";

String _buildAlerteSubtitle(String title) {
  return title;
}
