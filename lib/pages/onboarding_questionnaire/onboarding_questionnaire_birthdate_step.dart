import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';

class OnboardingQuestionnaireBirthdateStep extends StatefulWidget {
  const OnboardingQuestionnaireBirthdateStep({super.key, required this.form});

  final OnboardingQuestionnaireFormChangeNotifier form;

  @override
  State<OnboardingQuestionnaireBirthdateStep> createState() => _OnboardingQuestionnaireBirthdateStepState();
}

class _OnboardingQuestionnaireBirthdateStepState extends State<OnboardingQuestionnaireBirthdateStep> {
  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();
  bool _invalidAnnounced = false;

  @override
  void dispose() {
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  // A11y 9.9 : une date impossible affiche un message, annoncé une fois à son apparition.
  void _announceInvalidDate(bool invalid) {
    if (invalid && !_invalidAnnounced) A11yUtils.announce(Strings.onboardingQuestionnaireBirthdateInvalid);
    _invalidAnnounced = invalid;
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    final invalid = form.isBirthDateInvalid;
    _announceInvalidDate(invalid);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.onboardingQuestionnaireBirthdateGreeting(form.draftPrenom),
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: Margins.spacing_s),
        Text(
          Strings.onboardingQuestionnaireBirthdateSubtitle,
          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
        const SizedBox(height: Margins.spacing_base),
        ExcludeSemantics(
          child: Text(
            Strings.onboardingQuestionnaireBirthdateLabel,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textLabelGrey(context)),
          ),
        ),
        const SizedBox(height: DsfrSpacings.s1v),
        // A11y 9.8 : format attendu, en texte d'aide DSFR, lu avec le libellé du groupe.
        ExcludeSemantics(
          child: Text(
            Strings.onboardingQuestionnaireBirthdateHint,
            style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
          ),
        ),
        const SizedBox(height: Margins.spacing_s),
        Semantics(
          label: '${Strings.onboardingQuestionnaireBirthdateLabel}, ${Strings.onboardingQuestionnaireBirthdateHint}',
          container: true,
          explicitChildNodes: true,
          // A11y 5.3 : le curseur ne passe pas seul au champ suivant ; la touche « suivant » du clavier le fait.
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: DsfrInput(
                  label: Strings.onboardingQuestionnaireBirthdateDayLabel,
                  initialValue: form.draftBirthDay,
                  focusNode: _dayFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.birthdayDay],
                  // Avoid maxLength: broken DSFR UI, see https://github.com/Octo-Open-Source/flutter-dsfr/issues/150
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onChanged: form.updateBirthDay,
                  onFieldSubmitted: (_) => _monthFocus.requestFocusWithA11y(),
                ),
              ),
              const SizedBox(width: Margins.spacing_s),
              Expanded(
                flex: 2,
                child: DsfrInput(
                  label: Strings.onboardingQuestionnaireBirthdateMonthLabel,
                  initialValue: form.draftBirthMonth,
                  focusNode: _monthFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.birthdayMonth],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onChanged: form.updateBirthMonth,
                  onFieldSubmitted: (_) => _yearFocus.requestFocusWithA11y(),
                ),
              ),
              const SizedBox(width: Margins.spacing_s),
              Expanded(
                flex: 3,
                child: DsfrInput(
                  label: Strings.onboardingQuestionnaireBirthdateYearLabel,
                  initialValue: form.draftBirthYear,
                  focusNode: _yearFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.birthdayYear],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: form.updateBirthYear,
                ),
              ),
            ],
          ),
        ),
        if (invalid) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          DsfrComponentStateWidget(
            componentState: DsfrComponentState.error(errorMessage: Strings.onboardingQuestionnaireBirthdateInvalid),
          ),
        ],
      ],
    );
  }
}
