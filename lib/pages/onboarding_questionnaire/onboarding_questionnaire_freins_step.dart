import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_checkbox_rich.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_emoji_illustration.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';

class OnboardingQuestionnaireFreinsStep extends StatelessWidget {
  const OnboardingQuestionnaireFreinsStep({super.key, required this.form});

  final OnboardingQuestionnaireFormChangeNotifier form;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.onboardingQuestionnaireFreinsSubtitle,
          style: DsfrTextStyle.bodyMdBold(
            color: DsfrColorDecisions.textTitleGrey(context),
          ),
        ),
        const SizedBox(height: Margins.spacing_base),
        ...QuestionnaireFrein.values.map(
          (frein) => Padding(
            padding: const EdgeInsets.only(bottom: Margins.spacing_s),
            child: frein.isExclusive
                ? DsfrRadioRichButton<QuestionnaireFrein>(
                    title: frein.label,
                    value: frein,
                    groupValue: form.draftFreins.contains(frein) ? frein : null,
                    size: DsfrComponentSize.md,
                    isExpanded: true,
                    trailingIcon: OnboardingQuestionnaireEmojiIllustration(
                      emoji: frein.emoji,
                      backgroundColor: frein.illustrationColor,
                    ),
                    onChanged: (_) => _selectExclusiveFrein(form, frein),
                  )
                : OnboardingQuestionnaireCheckboxRich(
                    label: frein.label,
                    size: DsfrComponentSize.md,
                    value: form.draftFreins.contains(frein),
                    trailingIcon: OnboardingQuestionnaireEmojiIllustration(
                      emoji: frein.emoji,
                      backgroundColor: frein.illustrationColor,
                    ),
                    onChanged: (_) => form.toggleFrein(frein),
                  ),
          ),
        ),
      ],
    );
  }
}

void _selectExclusiveFrein(
  OnboardingQuestionnaireFormChangeNotifier form,
  QuestionnaireFrein frein,
) {
  final uncheckedLabels = QuestionnaireFrein.values
      .where((other) => !other.isExclusive && form.draftFreins.contains(other))
      .map((other) => other.label)
      .toList();
  form.toggleFrein(frein);
  if (uncheckedLabels.isNotEmpty && form.draftFreins.contains(frein)) {
    A11yUtils.announce(
      Strings.onboardingQuestionnaireFreinsUncheckedA11y(uncheckedLabels),
    );
  }
}
