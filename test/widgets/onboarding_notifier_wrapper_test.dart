import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/onboarding.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/onboarding_notifier_wrapper.dart';
import 'package:redux/redux.dart';

import '../dsl/app_state_dsl.dart';

void main() {
  group('Bandeau « étape du tutoriel validée »', () {
    AppState etat({required bool messageCompleted}) => givenState().withOnboardingSuccessState(
      Onboarding(showOnboarding: true, messageCompleted: messageCompleted),
    );

    // A11y 5.4 : le bandeau du haut n'est pas une région annoncée, contrairement à l'ancienne SnackBar du bas.
    testWidgets('annonce le message, sans émoji, quand une étape est validée', (tester) async {
      final annonces = <String>[];
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (message) async {
        final map = message as Map;
        if (map['type'] == 'announce') annonces.add((map['data'] as Map)['message'] as String);
        return null;
      });
      addTearDown(() => messenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, null));
      final store = Store<AppState>(
        (state, action) => action is AppState ? action : state,
        initialState: etat(messageCompleted: false),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            home: Scaffold(body: OnboardingNotifierWrapper(child: SizedBox.expand())),
          ),
        ),
      );
      store.dispatch(etat(messageCompleted: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text(Strings.onboardingStepFinished), findsOneWidget);
      expect(annonces, ['Bravo, tu as validé une étape du tutoriel !']);

      // Les confettis jouent une seconde.
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
