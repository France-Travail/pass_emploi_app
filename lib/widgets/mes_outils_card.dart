import 'package:flutter/material.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/pages/boite_a_outils_page.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';

class MesOutilsCard extends StatelessWidget {
  const MesOutilsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      onTap: () {
        PassEmploiMatomoTracker.instance.trackEvent(
          eventCategory: AnalyticsEventNames.mesOutilsCategory,
          action: AnalyticsEventNames.mesOutilsAction,
        );
        Navigator.push(context, BoiteAOutilsPage.materialPageRoute());
      },
      child: Row(
        children: [
          Image.asset(
            "assets/roadsign.webp",
            height: 56,
            width: 56,
          ),
          SizedBox(width: Margins.spacing_base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Strings.mesOutils,
                  style: TextStyles.textBaseBold,
                ),
                SizedBox(height: Margins.spacing_xs),
                Text(
                  Strings.mesOutilsDescription,
                  style: TextStyles.textSMedium(),
                ),
              ],
            ),
          ),
          SizedBox(width: Margins.spacing_s),
          Icon(AppIcons.chevron_right_rounded),
        ],
      ),
    );
  }
}
