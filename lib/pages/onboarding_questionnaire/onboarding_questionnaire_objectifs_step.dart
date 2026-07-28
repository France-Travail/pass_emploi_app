import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_checkbox_rich.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_emoji_illustration.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class OnboardingQuestionnaireObjectifsStep extends StatelessWidget {
  const OnboardingQuestionnaireObjectifsStep({super.key, required this.form});

  final OnboardingQuestionnaireFormChangeNotifier form;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.onboardingQuestionnaireObjectifsSubtitle,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: Margins.spacing_base),
        ...QuestionnaireObjectif.values.map(
          (objectif) => Padding(
            padding: const EdgeInsets.only(bottom: Margins.spacing_s),
            child: OnboardingQuestionnaireCheckboxRich(
              label: objectif.label,
              size: DsfrComponentSize.md,
              value: form.draftObjectifs.contains(objectif),
              trailingIcon: OnboardingQuestionnaireEmojiIllustration(
                emoji: objectif.emoji,
                backgroundColor: objectif.illustrationColor,
              ),
              onChanged: (_) => form.toggleObjectif(objectif),
            ),
          ),
        ),
      ],
    );
  }
}
