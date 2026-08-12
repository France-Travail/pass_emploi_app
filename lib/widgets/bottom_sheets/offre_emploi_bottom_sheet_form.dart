import 'package:flutter/material.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/models/alerte/offre_emploi_alerte.dart';
import 'package:pass_emploi_app/presentation/alerte_view_model.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/alerte_bottom_sheet_form_content.dart';

class OffreEmploiBottomSheetForm extends StatelessWidget {
  final AlerteViewModel<OffreEmploiAlerte> viewModel;
  final bool onlyAlternance;

  OffreEmploiBottomSheetForm(this.viewModel, this.onlyAlternance);

  @override
  Widget build(BuildContext context) {
    final searchModel = viewModel.searchModel;
    final keyWords = searchModel.keyword;
    final location = searchModel.location?.libelle;

    return AlerteBottomSheetFormContent(
      initialTitle: searchModel.title,
      tags: [
        AlerteFormTag(searchModel.getAlerteTagLabel()),
        if (keyWords != null && keyWords.isNotEmpty) AlerteFormTag(keyWords),
        if (location != null && location.isNotEmpty) AlerteFormTag.location(location),
      ],
      savingFailure: viewModel.savingFailure(),
      onCreate: (title) {
        viewModel.createAlerte(title);
        PassEmploiMatomoTracker.instance.trackScreen(
          onlyAlternance ? AnalyticsActionNames.createAlerteAlternance : AnalyticsActionNames.createAlerteEmploi,
        );
      },
    );
  }
}
