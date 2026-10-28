import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/features/thematiques_demarche/thematiques_demarche_state.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/widgets/create_demarche_form.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_page.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_step2.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';

import '../doubles/fixtures.dart';
import '../doubles/spies.dart';

// A11y 8.2 et 11.9 : clavier ouvert, ces écrans passent en défilement d'un bloc. Le champ touché doit garder le focus
// pendant ce changement de mise en page, sinon le clavier se referme aussitôt ouvert.
void main() {
  void phoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  Finder editableOf(Finder field) => find.descendant(of: field, matching: find.byType(EditableText));

  Future<void> tapField(WidgetTester tester, Finder field) async {
    await tester.ensureVisible(editableOf(field));
    await tester.pumpAndSettle();
    await tester.tap(editableOf(field));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue, reason: 'le clavier doit être demandé au toucher du champ');
  }

  // Le système affiche le clavier : la vue perd 300 dp en bas. Les minuteurs (défilement vers le champ) s'écoulent.
  Future<void> openKeyboard(WidgetTester tester) async {
    tester.view.viewInsets = FakeViewPadding(bottom: 300 * tester.view.devicePixelRatio);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  Future<void> type(WidgetTester tester, String text) async {
    tester.testTextInput.enterText(text);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  void expectKeyboardStillOpen(WidgetTester tester, Finder field) {
    final editable = tester.widget<EditableText>(editableOf(field));
    expect(editable.focusNode.hasPrimaryFocus, isTrue, reason: 'le champ a perdu le focus');
    expect(tester.testTextInput.isVisible, isTrue, reason: 'le clavier a été refermé');
  }

  Future<void> expectFieldKeepsFocus(WidgetTester tester, Finder field, {String text = 'a'}) async {
    await tapField(tester, field);
    await openKeyboard(tester);
    expectKeyboardStillOpen(tester, field);

    await type(tester, text);
    expectKeyboardStillOpen(tester, field);
    expect(tester.widget<EditableText>(editableOf(field)).controller.text, text);
  }

  group('Créer une action', () {
    Future<void> goToStep2(WidgetTester tester) async {
      phoneSize(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: CreateUserActionForm(onSubmit: (_) {}, onAbort: () {}),
        ),
      );
      await tester.pump();
      await tester.tap(find.text(UserActionReferentielType.emploi.label));
      await tester.pumpAndSettle();
    }

    testWidgets('étape 2 : titre de « Autre »', (tester) async {
      await goToStep2(tester);
      await tester.tap(find.text(Strings.userActionOther));
      await tester.pumpAndSettle();

      await expectFieldKeepsFocus(tester, find.widgetWithText(DsfrInput, Strings.userActionTitleTextfieldStep2));
    });

    testWidgets('étape 3 : description', (tester) async {
      await goToStep2(tester);
      await tester.tap(find.text(UserActionReferentielType.emploi.suggestionList.first.value));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.userActionNextButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.dateSuggestionAujourdhui));
      await tester.pumpAndSettle();

      await expectFieldKeepsFocus(tester, find.byType(UserActionDescriptionField));
    });
  });

  group('Créer une démarche', () {
    Future<void> pumpForm(WidgetTester tester, {required bool hasDemarcheIa}) async {
      phoneSize(tester);
      final store = StoreSpy.withState(
        AppState.initialState().copyWith(thematiquesDemarcheState: ThematiqueDemarcheFailureState()),
      );
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            home: CreateDemarcheForm(
              hasDemarcheIa: hasDemarcheIa,
              onCreateDemarchePersonnalisee: (_) {},
              onCreateDemarcheFromReferentiel: (_) {},
              onCreateDemarcheIaFt: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('IA France Travail : « Décris tes démarches »', (tester) async {
      await pumpForm(tester, hasDemarcheIa: true);

      await expectFieldKeepsFocus(tester, find.widgetWithText(DsfrInput, Strings.iaFtStep2Title));
    });

    testWidgets('démarche personnalisée : description', (tester) async {
      await pumpForm(tester, hasDemarcheIa: false);
      await tester.ensureVisible(find.text(Strings.customDemarcheTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.customDemarcheTitle));
      await tester.pumpAndSettle();

      await expectFieldKeepsFocus(
        tester,
        find.widgetWithText(DsfrInput, Strings.descriptionDemarchePersonnaliseeLabel),
      );
    });
  });

  // Au premier lancement, le questionnaire est affiché sous le Scaffold racine, qui retire déjà le clavier de MediaQuery.
  for (final underRootScaffold in [false, true]) {
    group(underRootScaffold ? 'Questionnaire au premier lancement' : 'Questionnaire', () {
      Future<void> pumpQuestionnaire(WidgetTester tester, {int skippedSteps = 0}) async {
        phoneSize(tester);
        // Invité : seul parcours avec l'étape prénom.
        final store = StoreSpy.withState(
          AppState.initialState().copyWith(
            loginState: LoginSuccessState(mockUser(loginMode: LoginMode.INVITE)),
            onboardingQuestionnaireState: OnboardingQuestionnaireSuccessState(
              finished: false,
              resumedFromApp: false,
              answers: const OnboardingQuestionnaireAnswers(),
            ),
          ),
        );
        const page = OnboardingQuestionnairePage();
        await tester.pumpWidget(
          StoreProvider<AppState>(
            store: store,
            child: MaterialApp(home: underRootScaffold ? const Scaffold(body: page) : page),
          ),
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < skippedSteps; i++) {
          await tester.tap(find.text(Strings.onboardingQuestionnaireSkip));
          await tester.pumpAndSettle();
        }
        // Laisse passer le délai de l'annonce Android pour ne laisser aucun minuteur en attente.
        await tester.pump(const Duration(seconds: 1));
      }

      testWidgets('prénom', (tester) async {
        await pumpQuestionnaire(tester);

        await expectFieldKeepsFocus(tester, find.widgetWithText(DsfrInput, Strings.onboardingQuestionnairePrenomLabel));
      });

      for (final label in [
        Strings.onboardingQuestionnaireBirthdateDayLabel,
        Strings.onboardingQuestionnaireBirthdateMonthLabel,
        Strings.onboardingQuestionnaireBirthdateYearLabel,
      ]) {
        testWidgets('date de naissance : $label', (tester) async {
          await pumpQuestionnaire(tester, skippedSteps: 1);

          await expectFieldKeepsFocus(tester, find.widgetWithText(DsfrInput, label), text: '1');
        });
      }

      testWidgets('commune d\'habitation', (tester) async {
        await pumpQuestionnaire(tester, skippedSteps: 2);

        await expectFieldKeepsFocus(tester, find.byKey(const ValueKey('habitation')));
      });

      testWidgets('domaine', (tester) async {
        await pumpQuestionnaire(tester, skippedSteps: 5);

        await expectFieldKeepsFocus(
          tester,
          find.widgetWithText(DsfrInput, Strings.onboardingQuestionnaireDomaineLabel),
        );
      });

      testWidgets('ville de recherche', (tester) async {
        await pumpQuestionnaire(tester, skippedSteps: 6);

        await expectFieldKeepsFocus(tester, find.byKey(const ValueKey('ville')));
      });
    });
  }
}
