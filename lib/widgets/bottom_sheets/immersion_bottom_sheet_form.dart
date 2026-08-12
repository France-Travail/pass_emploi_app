import 'package:flutter/material.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/models/alerte/immersion_alerte.dart';
import 'package:pass_emploi_app/presentation/alerte_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/alerte_bottom_sheet_form_content.dart';

class ImmersionBottomSheetForm extends StatelessWidget {
  final AlerteViewModel<ImmersionAlerte> viewModel;

  ImmersionBottomSheetForm(this.viewModel);

  @override
  Widget build(BuildContext context) {
    final searchModel = viewModel.searchModel;
    return AlerteBottomSheetFormContent(
      initialTitle: searchModel.title,
      tags: [
        AlerteFormTag(Strings.immersionTag),
        AlerteFormTag(searchModel.metier),
        AlerteFormTag.location(searchModel.ville),
      ],
      savingFailure: viewModel.savingFailure(),
      onCreate: (title) {
        viewModel.createAlerte(title);
        PassEmploiMatomoTracker.instance.trackScreen(AnalyticsActionNames.createAlerteImmersion);
      },
    );
  }
}
