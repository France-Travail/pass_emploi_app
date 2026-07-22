import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/invite_onboarding_answers.dart';
import 'package:pass_emploi_app/pages/invite_onboarding/invite_onboarding_checkbox_rich.dart';
import 'package:pass_emploi_app/pages/invite_onboarding/invite_onboarding_emoji_illustration.dart';
import 'package:pass_emploi_app/presentation/invite_onboarding/invite_onboarding_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class InviteOnboardingFreinsStep extends StatelessWidget {
  const InviteOnboardingFreinsStep({super.key, required this.form});

  final InviteOnboardingFormChangeNotifier form;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.inviteOnboardingFreinsSubtitle,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: Margins.spacing_base),
        ...InviteFrein.values.map(
          (frein) => Padding(
            padding: const EdgeInsets.only(bottom: Margins.spacing_s),
            child: frein.isExclusive
                ? DsfrRadioRichButton<InviteFrein>(
                    title: frein.label,
                    value: frein,
                    groupValue: form.draftFreins.contains(frein) ? frein : null,
                    size: DsfrComponentSize.md,
                    isExpanded: true,
                    trailingIcon: InviteOnboardingEmojiIllustration(
                      emoji: frein.emoji,
                      backgroundColor: frein.illustrationColor,
                    ),
                    onChanged: (_) => form.toggleFrein(frein),
                  )
                : InviteOnboardingCheckboxRich(
                    label: frein.label,
                    size: DsfrComponentSize.md,
                    value: form.draftFreins.contains(frein),
                    trailingIcon: InviteOnboardingEmojiIllustration(
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
