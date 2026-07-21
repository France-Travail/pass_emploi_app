import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/invite_onboarding/invite_onboarding_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class InviteOnboardingPrenomStep extends StatelessWidget {
  const InviteOnboardingPrenomStep({super.key, required this.form});

  final InviteOnboardingFormChangeNotifier form;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.inviteOnboardingPrenomSubtitle,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: Margins.spacing_base),
        DsfrInput(
          label: Strings.inviteOnboardingPrenomLabel,
          initialValue: form.draftPrenom,
          // Avoid maxLength: broken DSFR UI, see https://github.com/Octo-Open-Source/flutter-dsfr/issues/150
          inputFormatters: [LengthLimitingTextInputFormatter(256)],
          onChanged: form.updatePrenom,
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }
}
