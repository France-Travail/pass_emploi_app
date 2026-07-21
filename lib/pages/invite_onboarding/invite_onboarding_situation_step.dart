import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/invite_onboarding_answers.dart';
import 'package:pass_emploi_app/pages/invite_onboarding/invite_onboarding_emoji_illustration.dart';
import 'package:pass_emploi_app/presentation/invite_onboarding/invite_onboarding_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class InviteOnboardingSituationStep extends StatelessWidget {
  const InviteOnboardingSituationStep({super.key, required this.form});

  final InviteOnboardingFormChangeNotifier form;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.inviteOnboardingSituationSubtitle,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: Margins.spacing_base),
        ...InviteSituation.values.map(
          (situation) => Padding(
            padding: const EdgeInsets.only(bottom: Margins.spacing_s),
            child: DsfrRadioRichButton<InviteSituation>(
              title: situation.label,
              value: situation,
              groupValue: form.draftSituation,
              size: DsfrComponentSize.md,
              isExpanded: true,
              trailingIcon: InviteOnboardingEmojiIllustration(
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
