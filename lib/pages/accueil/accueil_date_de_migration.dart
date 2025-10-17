import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/external_links.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';

class AccueilDateDeMigration extends StatelessWidget {
  final DateTime dateDeMigration;
  AccueilDateDeMigration({
    required this.dateDeMigration,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      backgroundColor: AppColors.primaryLighten,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.info_rounded, color: AppColors.primary),
          SizedBox(width: Margins.spacing_s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Strings.vosOutilsEvoluent, style: TextStyles.textSBold.copyWith(color: AppColors.primary)),
                SizedBox(height: Margins.spacing_s),
                Text(Strings.vosOutilsEvoluentDescription(dateDeMigration.toDayOfWeekWithFullMonth()),
                    style: TextStyles.textSRegular().copyWith(color: AppColors.primary)),
                SizedBox(height: Margins.spacing_s),
                PrimaryActionButton(
                  heightPadding: Margins.spacing_s,
                  icon: AppIcons.download_rounded,
                  label: Strings.downloadParcoursEmploi,
                  onPressed: () => launchExternalUrl(ExternalLinks.parcoursEmploi(PlatformUtils.getPlatform.isAndroid)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
