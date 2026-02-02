import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
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
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';

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
  });

  final String title;
  final String subtitle;
  final void Function()? onDelete;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      onTap: onTap,
      padding: EdgeInsets.all(Margins.spacing_base),
      child: Row(
        children: [
          Icon(AppIcons.notifications_outlined, color: AppColors.primary),
          SizedBox(width: Margins.spacing_base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyles.textSBold),
                Text(subtitle, style: TextStyles.textSRegular()),
              ],
            ),
          ),
          SizedBox(width: Margins.spacing_base),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: Container(
                padding: EdgeInsets.all(Margins.spacing_s),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighten,
                  shape: BoxShape.circle,
                ),
                child: Icon(AppIcons.delete, color: AppColors.primary),
              ),
            ),
          SizedBox(width: Margins.spacing_base),
          Icon(AppIcons.chevron_right_rounded, color: AppColors.contentColor),
        ],
      ),
    );
  }
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
  );
}

Widget _buildImmersionCard(ImmersionAlerte alerte, AlerteCardViewModel viewModel) {
  return AlerteCardContent(
    title: _buildAlerteTitle(Strings.immersionTag),
    subtitle: _buildAlerteSubtitle(alerte.title),
    onTap: () => viewModel.fetchAlerteResult(alerte),
    onDelete: null,
  );
}

Widget _buildServiceCiviqueCard(ServiceCiviqueAlerte alerte, AlerteCardViewModel viewModel) {
  return AlerteCardContent(
    title: _buildAlerteTitle(Strings.serviceCiviqueTag),
    subtitle: _buildAlerteSubtitle(alerte.titre),
    onTap: () => viewModel.fetchAlerteResult(alerte),
    onDelete: null,
  );
}

String _buildAlerteTitle(String tagLabel) => "Alerte $tagLabel";

String _buildAlerteSubtitle(String title) {
  return title;
}
