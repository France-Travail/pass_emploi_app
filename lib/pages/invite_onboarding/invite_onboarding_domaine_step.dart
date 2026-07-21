import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/invite_onboarding/invite_onboarding_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class InviteOnboardingDomaineStep extends StatelessWidget {
  const InviteOnboardingDomaineStep({super.key, required this.form});

  final InviteOnboardingFormChangeNotifier form;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.inviteOnboardingDomaineSubtitle,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: Margins.spacing_base),
        DsfrInput(
          label: Strings.inviteOnboardingDomaineLabel,
          initialValue: form.draftDomaine,
          // Avoid maxLength: broken DSFR UI, see https://github.com/Octo-Open-Source/flutter-dsfr/issues/150
          inputFormatters: [LengthLimitingTextInputFormatter(256)],
          onChanged: form.updateDomaine,
        ),
        const SizedBox(height: Margins.spacing_base),
        DsfrButton(
          label: Strings.inviteOnboardingDomaineUnknown,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.lg,
          onPressed: () => form.markDomaineUnknownAndContinue(),
        ),
      ],
    );
  }
}
