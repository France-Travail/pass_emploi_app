import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/demarche/create_demarche_form/create_demarche_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_date_input_suggestions.dart';

class CreateDemarchePersonnaliseeStep3Page extends StatelessWidget {
  const CreateDemarchePersonnaliseeStep3Page(this.viewModel);
  final CreateDemarcheFormChangeNotifier viewModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: DsfrSpacings.s2w),
          DsfrDateInputSuggestions(
            label: Strings.thematiquesDemarcheDateShort,
            dateSource: viewModel.personnaliseeStep3ViewModel.dateSource,
            onDateChanged: (date) {
              viewModel.dateDemarchePersonnaliseeChanged(date);
              if (!date.isNone) {
                Future.delayed(const Duration(milliseconds: 50), () {
                  if (context.mounted) FocusScope.of(context).nextFocus();
                });
              }
            },
          ),
          const SizedBox(height: DsfrSpacings.s3w),
          DsfrButton(
            label: Strings.addALaDemarche,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.md,
            onPressed: viewModel.isDemarchePersonnaliseeDateValid ? viewModel.submitDemarchePersonnalisee : null,
          ),
          const SizedBox(height: DsfrSpacings.s5w),
        ],
      ),
    );
  }
}
