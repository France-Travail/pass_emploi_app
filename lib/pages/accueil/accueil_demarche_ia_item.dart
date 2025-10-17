import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche_form_page.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';

class AccueilIaDemarches extends StatelessWidget {
  const AccueilIaDemarches({super.key});

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      Navigator.push(context, CreateDemarcheFormPage.route(startPoint: StartPoint.ftIa));
      PassEmploiMatomoTracker.instance.trackEvent(
        eventCategory: AnalyticsEventNames.createDemarcheEventCategory(null),
        action: AnalyticsEventNames.createDemarcheFromAccueilAction,
      );
    }

    return Semantics(
      button: true,
      child: CardContainer(
        onTap: onPressed,
        gradient: LinearGradient(
          colors: AppColors.gradientTertiary,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: ExcludeSemantics(
                child: SvgPicture.asset(Drawables.iaFtIllustration),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: Margins.spacing_xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Strings.iaDemarchesAccueilTitle,
                          style: TextStyles.textBaseBold.copyWith(color: Colors.white)),
                      SizedBox(height: Margins.spacing_s),
                      Text(Strings.iaDemarchesAccueilSubtitle,
                          style: TextStyles.textSRegular().copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                SizedBox(height: Margins.spacing_s),
                PrimaryActionButton(
                  heightPadding: Margins.spacing_s,
                  backgroundColor: Colors.white,
                  textColor: AppColors.primary,
                  label: Strings.iaDemarchesAccueilHint,
                  onPressed: onPressed,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
