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
    this.description,
  });

  final OnboardingQuestionnaireAnswers answers;
  final VoidCallback onResume;
  final String? description;

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
            Text(
              Strings.inviteAccueilQuestionnaireTitle,
              style: DsfrTextStyle.headline6(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
            const SizedBox(height: Margins.spacing_s),
            Text(
              description ?? Strings.inviteAccueilQuestionnaireDescription,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
            const SizedBox(height: Margins.spacing_base),
            Row(
              children: [
                Expanded(
                  child: Text(
                    Strings.inviteAccueilProfilComplete,
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                ),
                Text(
                  Strings.inviteAccueilStepsCount(current, total),
                  style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                ),
              ],
            ),
            const SizedBox(height: Margins.spacing_s),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: DsfrColorDecisions.borderActionHighBlueFrance(context)),
                ),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
                  color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
                ),
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
