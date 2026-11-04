import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';

class OnboardingQuestionnairePrenomStep extends StatelessWidget {
  const OnboardingQuestionnairePrenomStep({super.key, required this.form});

  final OnboardingQuestionnaireFormChangeNotifier form;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.onboardingQuestionnairePrenomSubtitle,
          // A11y 1.1 : l'emoji « 🙂 » est décoratif.
          semanticsLabel: Strings.onboardingQuestionnairePrenomSubtitle.removeEmojisForScreenReaders(),
          style: DsfrTextStyle.bodyMdBold(
            color: DsfrColorDecisions.textTitleGrey(context),
          ),
        ),
        const SizedBox(height: Margins.spacing_base),
        DsfrInput(
          label: Strings.onboardingQuestionnairePrenomLabel,
          initialValue: form.draftPrenom,
          // Avoid maxLength: broken DSFR UI, see https://github.com/Octo-Open-Source/flutter-dsfr/issues/150
          inputFormatters: [LengthLimitingTextInputFormatter(256)],
          onChanged: form.updatePrenom,
          textCapitalization: TextCapitalization.words,
          // A11y 9.12 : nature de la saisie identifiée : type « nom de personne » (inputType Android) et prénom
          // proposé par le remplissage automatique (textContentType iOS).
          keyboardType: TextInputType.name,
          autofillHints: const [AutofillHints.givenName],
        ),
      ],
    );
  }
}
