import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_freins_step.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';
import 'package:pass_emploi_app/ui/strings.dart';

void main() {
  late OnboardingQuestionnaireFormChangeNotifier form;

  setUp(() {
    form = OnboardingQuestionnaireFormChangeNotifier(
      loadAnswers: () async => const OnboardingQuestionnaireAnswers(),
      saveAnswers: (_) async {},
    );
  });

  Future<List<String>> pumpEtCapteAnnonces(WidgetTester tester) async {
    final annonces = <String>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (message) async {
      final map = message as Map;
      if (map['type'] == 'announce') annonces.add((map['data'] as Map)['message'] as String);
      return null;
    });
    addTearDown(() => messenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListenableBuilder(
            listenable: form,
            builder: (context, _) => SingleChildScrollView(child: OnboardingQuestionnaireFreinsStep(form: form)),
          ),
        ),
      ),
    );
    return annonces;
  }

  Future<void> tapFrein(WidgetTester tester, String label) async {
    final finder = find.text(label);
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('choisir « Rien ne me bloque » annonce que les autres cases sont décochées', (tester) async {
    form.draftFreins = {QuestionnaireFrein.pasDePermis, QuestionnaireFrein.manqueConfiance};
    final annonces = await pumpEtCapteAnnonces(tester);

    await tapFrein(tester, Strings.onboardingQuestionnaireFreinRienNeMeBloque);

    expect(form.draftFreins, {QuestionnaireFrein.rienNeMeBloque});
    expect(annonces, [
      Strings.onboardingQuestionnaireFreinsUncheckedA11y([
        Strings.onboardingQuestionnaireFreinPasDePermis,
        Strings.onboardingQuestionnaireFreinManqueConfiance,
      ]),
    ]);
    expect(
      tester.getSemantics(find.byKey(ValueKey(Strings.onboardingQuestionnaireFreinRienNeMeBloque))),
      containsSemantics(isInMutuallyExclusiveGroup: true, isChecked: true),
    );
  });

  testWidgets('choisir « Rien ne me bloque » seul n’annonce rien', (tester) async {
    final annonces = await pumpEtCapteAnnonces(tester);

    await tapFrein(tester, Strings.onboardingQuestionnaireFreinRienNeMeBloque);

    expect(form.draftFreins, {QuestionnaireFrein.rienNeMeBloque});
    expect(annonces, isEmpty);
  });
}
