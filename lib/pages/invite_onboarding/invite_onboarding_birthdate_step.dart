import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/invite_onboarding/invite_onboarding_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class InviteOnboardingBirthdateStep extends StatefulWidget {
  const InviteOnboardingBirthdateStep({super.key, required this.form});

  final InviteOnboardingFormChangeNotifier form;

  @override
  State<InviteOnboardingBirthdateStep> createState() => _InviteOnboardingBirthdateStepState();
}

class _InviteOnboardingBirthdateStepState extends State<InviteOnboardingBirthdateStep> {
  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();

  @override
  void dispose() {
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  void _onDayChanged(String value) {
    widget.form.updateBirthDay(value);
    if (value.length == 2) _monthFocus.requestFocus();
  }

  void _onMonthChanged(String value) {
    widget.form.updateBirthMonth(value);
    if (value.length == 2) _yearFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.inviteOnboardingBirthdateGreeting(form.draftPrenom),
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: Margins.spacing_s),
        Text(
          Strings.inviteOnboardingBirthdateSubtitle,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: Margins.spacing_base),
        Text(
          Strings.inviteOnboardingBirthdateLabel,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textLabelGrey(context)),
        ),
        const SizedBox(height: Margins.spacing_s),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: DsfrInput(
                label: Strings.inviteOnboardingBirthdateDayLabel,
                initialValue: form.draftBirthDay,
                focusNode: _dayFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                // Avoid maxLength: broken DSFR UI, see https://github.com/Octo-Open-Source/flutter-dsfr/issues/150
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                onChanged: _onDayChanged,
                onFieldSubmitted: (_) => _monthFocus.requestFocus(),
              ),
            ),
            const SizedBox(width: Margins.spacing_s),
            Expanded(
              flex: 2,
              child: DsfrInput(
                label: Strings.inviteOnboardingBirthdateMonthLabel,
                initialValue: form.draftBirthMonth,
                focusNode: _monthFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                onChanged: _onMonthChanged,
                onFieldSubmitted: (_) => _yearFocus.requestFocus(),
              ),
            ),
            const SizedBox(width: Margins.spacing_s),
            Expanded(
              flex: 3,
              child: DsfrInput(
                label: Strings.inviteOnboardingBirthdateYearLabel,
                initialValue: form.draftBirthYear,
                focusNode: _yearFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: form.updateBirthYear,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
