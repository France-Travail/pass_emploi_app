import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_emoji_illustration.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class OnboardingQuestionnaireSituationStep extends StatelessWidget {
  const OnboardingQuestionnaireSituationStep({super.key, required this.form});

  final OnboardingQuestionnaireFormChangeNotifier form;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.onboardingQuestionnaireSituationSubtitle,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: Margins.spacing_base),
        ...QuestionnaireSituation.values.map(
          (situation) => Padding(
            padding: const EdgeInsets.only(bottom: Margins.spacing_s),
            child: DsfrRadioRichButton<QuestionnaireSituation>(
              title: situation.label,
              value: situation,
              groupValue: form.draftSituation,
              size: DsfrComponentSize.md,
              isExpanded: true,
              trailingIcon: OnboardingQuestionnaireEmojiIllustration(
                emoji: situation.emoji,
                backgroundColor: situation.illustrationColor,
              ),
              onChanged: (value) {
                if (value != null) form.selectSituationAndContinue(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
