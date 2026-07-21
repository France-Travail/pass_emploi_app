import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/invite_onboarding_answers.dart';
import 'package:pass_emploi_app/pages/invite_onboarding/invite_onboarding_checkbox_rich.dart';
import 'package:pass_emploi_app/pages/invite_onboarding/invite_onboarding_emoji_illustration.dart';
import 'package:pass_emploi_app/presentation/invite_onboarding/invite_onboarding_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class InviteOnboardingObjectifsStep extends StatelessWidget {
  const InviteOnboardingObjectifsStep({super.key, required this.form});

  final InviteOnboardingFormChangeNotifier form;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.inviteOnboardingObjectifsSubtitle,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: Margins.spacing_base),
        ...InviteObjectif.values.map(
          (objectif) => Padding(
            padding: const EdgeInsets.only(bottom: Margins.spacing_s),
            child: InviteOnboardingCheckboxRich(
              label: objectif.label,
              size: DsfrComponentSize.md,
              value: form.draftObjectifs.contains(objectif),
              trailingIcon: InviteOnboardingEmojiIllustration(
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
