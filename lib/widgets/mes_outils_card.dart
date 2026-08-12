import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/pages/boite_a_outils_page.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';

class MesOutilsCard extends StatelessWidget {
  const MesOutilsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DsfrColorDecisions.backgroundDefaultGrey(context),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: InkWell(
        onTap: () {
          PassEmploiMatomoTracker.instance.trackEvent(
            eventCategory: AnalyticsEventNames.mesOutilsCategory,
            action: AnalyticsEventNames.mesOutilsAction,
          );
          Navigator.push(context, BoiteAOutilsPage.materialPageRoute());
        },
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: DsfrColorDecisions.artworkDecorativeBlueFrance(context)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DsfrSpacings.s2w),
            child: Row(
              children: [
                Image.asset(
                  "assets/roadsign.webp",
                  height: 56,
                  width: 56,
                ),
                const SizedBox(width: DsfrSpacings.s2w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Strings.mesOutils,
                        style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                      ),
                      const SizedBox(height: DsfrSpacings.s1v),
                      Text(
                        Strings.mesOutilsDescription,
                        style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DsfrSpacings.s1w),
                Icon(
                  DsfrIcons.systemArrowRightSLine,
                  color: DsfrColorDecisions.textTitleBlueFrance(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
