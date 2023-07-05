import 'package:flutter/material.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche_personnalisee_page.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';

class CreateCustomDemarche extends StatelessWidget {
  const CreateCustomDemarche();

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      backgroundColor: AppColors.primaryLighten,
      child: Column(
        children: [
          Icon(
            AppIcons.search_rounded,
            color: AppColors.accent2,
            size: 40,
          ),
          SizedBox(height: Margins.spacing_base),
          Text(
            "Vous ne trouvez pas ce que vous cherchez ?",
            style: TextStyles.textBaseBold,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Margins.spacing_base),
          Text(
            "Créez une démarche personnalisée qui correspond à votre situation.",
            style: TextStyles.textBaseRegular,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Margins.spacing_base),
          PrimaryActionButton(
            label: Strings.createDemarchePersonnalisee,
            onPressed: () => Navigator.push(context, CreateDemarchePersonnaliseePage.materialPageRoute()).then((value) {
              // forward result to previous page
              if (value != null) Navigator.pop(context, value);
            }),
          ),
        ],
      ),
    );
  }
}
