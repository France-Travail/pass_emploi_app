import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class OnboardingQuestionnaireProgressCard extends StatelessWidget {
  const OnboardingQuestionnaireProgressCard({
    super.key,
    required this.answers,
    required this.onResume,
  });

  final OnboardingQuestionnaireAnswers answers;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final current = answers.answeredStepsCount;
    final total = OnboardingQuestionnaireAnswers.totalStepsCount;
    final progress = total == 0 ? 0.0 : current / total;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.backgroundContrastBlueFrance(context),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Margins.spacing_base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: DsfrColorDecisions.backgroundDefaultGrey(context),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text('🚀', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: Margins.spacing_base),
                Expanded(
                  child: Text(
                    Strings.inviteAccueilQuestionnaireTitle,
                    style: DsfrTextStyle.headline3(color: DsfrColorDecisions.textTitleBlueFrance(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Margins.spacing_base),
            Text(
              Strings.inviteAccueilQuestionnaireDescription,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleBlueFrance(context)),
            ),
            const SizedBox(height: Margins.spacing_base),
            Row(
              children: [
                Expanded(
                  child: Text(
                    Strings.inviteAccueilProfilComplete,
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleBlueFrance(context)),
                  ),
                ),
                Text(
                  Strings.inviteAccueilStepsCount(current, total),
                  style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleBlueFrance(context)),
                ),
              ],
            ),
            const SizedBox(height: Margins.spacing_base),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
                color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
              ),
            ),
            const SizedBox(height: Margins.spacing_xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0/$total',
                  style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textTitleBlueFrance(context)),
                ),
                Text(
                  '$total/$total',
                  style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textTitleBlueFrance(context)),
                ),
              ],
            ),
            const SizedBox(height: Margins.spacing_base),
            DsfrButton(
              label: Strings.inviteAccueilResumeQuestionnaire,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.lg,
              onPressed: onResume,
            ),
          ],
        ),
      ),
    );
  }
}
