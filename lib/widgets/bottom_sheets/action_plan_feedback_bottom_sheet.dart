import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/ui/external_links.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_sheet.dart';

class ActionPlanFeedbackBottomSheet extends StatelessWidget {
  const ActionPlanFeedbackBottomSheet({super.key});

  static const _feedbackFeature = 'action-plan';

  static Future<bool?> show(BuildContext context) {
    return showDsfrBottomSheet<bool?>(
      context: context,
      name: AnalyticsScreenNames.actionPlanFeedback,
      builder: (context) => const ActionPlanFeedbackBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DsfrBottomSheet(
      shrinkWrap: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DsfrSpacings.s2w,
          0,
          DsfrSpacings.s2w,
          DsfrSpacings.s2w,
        ),
        child: Tracker(
          tracking: AnalyticsScreenNames.actionPlanFeedback,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                Strings.actionPlanFeedbackTitle,
                style: DsfrTextStyle.headline5(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    Strings.actionPlanFeedbackDescription,
                    style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                  const SizedBox(height: DsfrSpacings.s2w),
                  DsfrButton(
                    label: Strings.actionPlanFeedbackGiveOpinion,
                    variant: DsfrButtonVariant.primary,
                    size: DsfrComponentSize.lg,
                    icon: DsfrIcons.systemExternalLinkFill,
                    onPressed: () => launchExternalUrl(ExternalLinks.actionPlanFeedback),
                  ),
                ],
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              DsfrButton(
                label: Strings.onboardingQuestionnaireSkip,
                variant: DsfrButtonVariant.secondary,
                size: DsfrComponentSize.lg,
                onPressed: () => _continueToForm(context, AnalyticsEventNames.actionPlanFeedbackSkipAction),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _continueToForm(BuildContext context, String action) {
    PassEmploiMatomoTracker.instance.trackEvent(
      eventCategory: AnalyticsEventNames.feedbackCategory(_feedbackFeature),
      action: action,
    );
    Navigator.of(context).pop(true);
  }
}
