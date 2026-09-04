import 'package:flutter/material.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/models/alerte/service_civique_alerte.dart';
import 'package:pass_emploi_app/presentation/alerte_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/alerte_bottom_sheet_form_content.dart';

class ServiceCiviqueBottomSheetForm extends StatelessWidget {
  final AlerteViewModel<ServiceCiviqueAlerte> viewModel;

  ServiceCiviqueBottomSheetForm(this.viewModel);

  @override
  Widget build(BuildContext context) {
    final searchModel = viewModel.searchModel;
    final domaine = searchModel.domaine?.titre;
    final ville = searchModel.ville;

    return AlerteBottomSheetFormContent(
      initialTitle: searchModel.titre,
      tags: [
        AlerteFormTag(Strings.serviceCiviqueTag),
        if (domaine != null && domaine.isNotEmpty) AlerteFormTag(domaine),
        if (ville != null && ville.isNotEmpty) AlerteFormTag.location(ville),
      ],
      savingFailure: viewModel.savingFailure(),
      onCreate: (title) {
        viewModel.createAlerte(title);
        PassEmploiMatomoTracker.instance.trackScreen(AnalyticsActionNames.createAlerteServiceCivique);
      },
    );
  }
}
