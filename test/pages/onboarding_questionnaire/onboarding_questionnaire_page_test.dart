import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/pages/onboarding_questionnaire/onboarding_questionnaire_page.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/spies.dart';

void main() {
  AppState state({required bool resumedFromApp, LoginMode loginMode = LoginMode.INVITE}) {
    return AppState.initialState().copyWith(
      loginState: LoginSuccessState(mockUser(loginMode: loginMode)),
      onboardingQuestionnaireState: OnboardingQuestionnaireSuccessState(
        finished: false,
        resumedFromApp: resumedFromApp,
        answers: const OnboardingQuestionnaireAnswers(),
      ),
    );
  }

  Future<StoreSpy> pump(WidgetTester tester, AppState appState) async {
    final store = StoreSpy.withState(appState);
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: const MaterialApp(home: OnboardingQuestionnairePage()),
      ),
    );
    await tester.pumpAndSettle();
    // Laisse passer le délai de l'annonce Android pour ne laisser aucun timer en attente.
    await tester.pump(const Duration(seconds: 1));
    return store;
  }

  List<String> captureAnnonces(WidgetTester tester) {
    final annonces = <String>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (message) async {
      final map = message as Map;
      if (map['type'] == 'announce') annonces.add((map['data'] as Map)['message'] as String);
      return null;
    });
    addTearDown(() => messenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, null));
    return annonces;
  }

  group('Retour à la première étape', () {
    testWidgets("ferme le questionnaire sans déconnexion quand il a été rouvert depuis l'app", (tester) async {
      final store = await pump(tester, state(resumedFromApp: true));

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      expect(store.dispatchedActions.whereType<OnboardingQuestionnaireCloseResumedAction>(), hasLength(1));
      expect(store.dispatchedActions.whereType<RequestLogoutAction>(), isEmpty);
    });

    testWidgets('demande confirmation avant de déconnecter quand le routeur impose le questionnaire', (tester) async {
      final store = await pump(tester, state(resumedFromApp: false));

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.text(Strings.onboardingQuestionnaireLogoutTitle), findsOneWidget);
      expect(find.text(Strings.onboardingQuestionnaireLogoutConfirm), findsOneWidget);
      expect(find.text(Strings.onboardingQuestionnaireLogoutCancel), findsOneWidget);
      expect(store.dispatchedActions.whereType<RequestLogoutAction>(), isEmpty);
      expect(store.dispatchedActions.whereType<OnboardingQuestionnaireCloseResumedAction>(), isEmpty);
    });

    testWidgets('déconnecte quand la confirmation est acceptée', (tester) async {
      final store = await pump(tester, state(resumedFromApp: false));

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.onboardingQuestionnaireLogoutConfirm));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(store.dispatchedActions.whereType<RequestLogoutAction>(), hasLength(1));
    });

    testWidgets('reste sur la première étape quand la confirmation est annulée', (tester) async {
      final store = await pump(tester, state(resumedFromApp: false));

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.onboardingQuestionnaireLogoutCancel));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(Strings.onboardingQuestionnaireLogoutTitle), findsNothing);
      expect(find.text(Strings.onboardingQuestionnairePrenomTitle), findsWidgets);
      expect(store.dispatchedActions.whereType<RequestLogoutAction>(), isEmpty);
    });

    testWidgets("n'affiche aucune confirmation quand le questionnaire a été rouvert depuis l'app", (tester) async {
      await pump(tester, state(resumedFromApp: true));

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.text(Strings.onboardingQuestionnaireLogoutTitle), findsNothing);
    });
  });

  group("annonces pour lecteur d'écran", () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    testWidgets("Android : annonce l'étape à l'ouverture, une seule fois", (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final annonces = captureAnnonces(tester);

      await pump(tester, state(resumedFromApp: true));
      await tester.pump(const Duration(seconds: 1));

      expect(annonces, [Strings.onboardingQuestionnaireStepA11y(1, 8, Strings.onboardingQuestionnairePrenomTitle)]);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets("Android : annonce la nouvelle étape quand on passe l'étape", (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final annonces = captureAnnonces(tester);

      await pump(tester, state(resumedFromApp: true));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text(Strings.onboardingQuestionnaireSkip));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      expect(annonces, hasLength(2));
      expect(annonces.last, startsWith('Étape 2 sur 8, '));
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets("Android : le jeune connecté, sans étape prénom, commence à l'étape 1 sur 7", (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final annonces = captureAnnonces(tester);

      await pump(tester, state(resumedFromApp: true, loginMode: LoginMode.MILO));
      await tester.pump(const Duration(seconds: 1));

      expect(annonces, [Strings.onboardingQuestionnaireStepA11y(1, 7, Strings.onboardingQuestionnaireBirthdateTitle)]);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets("iOS : n'annonce rien (le focus automatique s'en charge)", (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final annonces = captureAnnonces(tester);

      await pump(tester, state(resumedFromApp: true));
      await tester.pump(const Duration(seconds: 1));

      expect(annonces, isEmpty);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
