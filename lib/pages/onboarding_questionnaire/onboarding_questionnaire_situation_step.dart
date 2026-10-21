import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_emoji_illustration.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class OnboardingQuestionnaireSituationStep extends StatefulWidget {
  const OnboardingQuestionnaireSituationStep({super.key, required this.form});

  final OnboardingQuestionnaireFormChangeNotifier form;

  @override
  State<OnboardingQuestionnaireSituationStep> createState() => _OnboardingQuestionnaireSituationStepState();
}

class _OnboardingQuestionnaireSituationStepState extends State<OnboardingQuestionnaireSituationStep>
    with WidgetsBindingObserver {
  final _autreFieldKey = GlobalKey();
  late bool _wasAutreSelected = widget.form.draftSituation == QuestionnaireSituation.autre;

  OnboardingQuestionnaireFormChangeNotifier get form => widget.form;

  bool _wasKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // The page swaps its scroll view when the keyboard closes, so the scroll goes back to the top: scroll to the field
  // again. The keyboard is read from the view, as the page does (the root Scaffold may already remove it from MediaQuery).
  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final isKeyboardOpen = View.of(context).viewInsets.bottom > 0;
    final hasKeyboardJustClosed = _wasKeyboardOpen && !isKeyboardOpen;
    _wasKeyboardOpen = isKeyboardOpen;
    if (hasKeyboardJustClosed && _wasAutreSelected) _scrollToAutreField();
  }

  @override
  void didUpdateWidget(covariant OnboardingQuestionnaireSituationStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isAutreSelected = form.draftSituation == QuestionnaireSituation.autre;
    if (isAutreSelected && !_wasAutreSelected) _scrollToAutreField();
    _wasAutreSelected = isAutreSelected;
  }

  // The field appears below the fold: bring it into view once it is laid out, then again once the keyboard animation
  // (which keeps resizing the viewport) is over. Scrolling to a field that is already visible does nothing.
  void _scrollToAutreField() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAutreFieldVisible());
    Future<void>.delayed(const Duration(milliseconds: 400), _ensureAutreFieldVisible);
  }

  void _ensureAutreFieldVisible() {
    final fieldContext = _autreFieldKey.currentContext;
    if (!mounted || fieldContext == null || !fieldContext.mounted) return;
    Scrollable.ensureVisible(
      fieldContext,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          Strings.onboardingQuestionnaireSituationSubtitle,
          style: DsfrTextStyle.bodyMdBold(
            color: DsfrColorDecisions.textTitleGrey(context),
          ),
        ),
        const SizedBox(height: Margins.spacing_base),
        ...QuestionnaireSituation.values.map(
          (situation) => Padding(
            padding: const EdgeInsets.only(bottom: Margins.spacing_s),
            child: DsfrRadioRichButton<QuestionnaireSituation>(
              title: situation.label,
              value: situation,
              groupValue: form.draftSituation,
              size: DsfrComponentSize.md,
              isExpanded: true,
              trailingIcon: OnboardingQuestionnaireEmojiIllustration(
                emoji: situation.emoji,
                backgroundColor: situation.illustrationColor,
              ),
              // A11y 5.3 : choisir une réponse la sélectionne seulement ; on passe à la suite avec « Continuer ».
              onChanged: (value) {
                if (value != null) form.updateSituation(value);
              },
            ),
          ),
        ),
        if (form.draftSituation == QuestionnaireSituation.autre) ...[
          const SizedBox(height: Margins.spacing_s),
          DsfrInput(
            key: _autreFieldKey,
            label: Strings.onboardingQuestionnaireSituationAutreLabel,
            hintText: Strings.onboardingQuestionnaireSituationAutreHint,
            initialValue: form.draftSituationAutre,
            // Avoid maxLength: broken DSFR UI, see https://github.com/Octo-Open-Source/flutter-dsfr/issues/150
            inputFormatters: [LengthLimitingTextInputFormatter(256)],
            onChanged: form.updateSituationAutre,
          ),
        ],
      ],
    );
  }
}
