import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/cgu/cgu_actions.dart';
import 'package:pass_emploi_app/features/too_many_requests/too_many_requests_state.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/pages/cgu_page.dart';
import 'package:pass_emploi_app/redux/app_reducer.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_accessible_toggle_switch.dart';
import 'package:redux/redux.dart';

import '../doubles/fixtures.dart';
import '../doubles/spies.dart';
import '../dsl/app_state_dsl.dart';

void main() {
  Future<void> pumpCguPage(WidgetTester tester, {required LoginMode loginMode}) async {
    final store = StoreSpy.withState(
      givenState(configuration()).loggedInUser(loginMode: loginMode).withCguNeverAccepted(),
    );
    await tester.pumpWidget(StoreProvider<AppState>(store: store, child: MaterialApp(home: CguPage())));
    // Laisse passer la minuterie de mise au point du titre (AutoFocusA11y).
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('invité : l’encart d’information sur le refus est affiché', (tester) async {
    await pumpCguPage(tester, loginMode: LoginMode.INVITE);

    expect(find.text(Strings.cguInviteRefusalNotice), findsOneWidget);
  });

  testWidgets('Mission Locale et France Travail : pas d’encart d’information sur le refus', (tester) async {
    for (final loginMode in [LoginMode.MILO, LoginMode.POLE_EMPLOI]) {
      await pumpCguPage(tester, loginMode: loginMode);

      expect(find.text(Strings.cguInviteRefusalNotice), findsNothing, reason: loginMode.name);
    }
  });

  testWidgets('l’interrupteur est à gauche de la phrase, qui contient un lien vers les CGU', (tester) async {
    await pumpCguPage(tester, loginMode: LoginMode.MILO);

    final switchRight = tester.getTopRight(find.byType(DsfrToggleSwitch)).dx;
    final labelLeft = tester.getTopLeft(find.text(Strings.cguNeverAcceptedSwitch)).dx;
    expect(switchRight, lessThanOrEqualTo(labelLeft));
    final linkNextToSwitch = find.descendant(
      of: find.byWidgetPredicate((w) => w is DsfrGroup),
      matching: find.byWidgetPredicate((w) => w is DsfrLink && w.label == Strings.cguSwitchLink),
    );
    expect(linkNextToSwitch, findsOneWidget);
  });

  testWidgets('le lecteur d’écran annonce l’interrupteur avec la phrase entière et son état', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCguPage(tester, loginMode: LoginMode.MILO);

    final data = tester.getSemantics(find.byType(DsfrAccessibleToggleSwitch)).getSemanticsData();
    expect(data.label, contains("J’ai lu et j’accepte les Conditions Générales d’Utilisation"));
    expect(data.label, contains(Strings.notificationsToggleDisabled));
    handle.dispose();
  });

  group('échec de l’acceptation', () {
    // Store réel (reducer de l'app, sans middleware) : l'échec doit changer l'état pour afficher le message.
    Future<Store<AppState>> pumpCguPageWithStore(WidgetTester tester, AppState state) async {
      final store = Store<AppState>(reducer, initialState: state);
      await tester.pumpWidget(StoreProvider<AppState>(store: store, child: MaterialApp(home: CguPage())));
      await tester.pump(const Duration(seconds: 1));
      return store;
    }

    Future<void> failAccept(WidgetTester tester, Store<AppState> store) async {
      store.dispatch(CguAcceptFailureAction());
      // Le store prévient la page de façon asynchrone : l'alerte n'est construite qu'à la deuxième image.
      await tester.pump();
      await tester.pump();
      // Laisse finir le défilement jusqu'à l'alerte, puis passer la minuterie de son focus lecteur d'écran.
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
    }

    AppState cguToAccept() => givenState(configuration()).loggedInUser(loginMode: LoginMode.MILO).withCguNeverAccepted();

    Finder errorAlert(String message) => find.ancestor(
          of: find.text(message),
          matching: find.byWidgetPredicate((w) => w is DsfrAlert && w.type == DsfrAlertType.error),
        );

    testWidgets('affiche une alerte d’erreur dans la page, pas une snackbar', (tester) async {
      final store = await pumpCguPageWithStore(tester, cguToAccept());

      await failAccept(tester, store);

      expect(errorAlert(Strings.miscellaneousErrorRetry), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('affiche « trop de requêtes » pendant la limite de débit', (tester) async {
      final rateLimited = TooManyRequestsState(retryNotBefore: DateTime.now().add(Duration(minutes: 1)));
      final store = await pumpCguPageWithStore(tester, cguToAccept().copyWith(tooManyRequestsState: rateLimited));

      await failAccept(tester, store);

      expect(errorAlert(Strings.tooManyRequestsError), findsOneWidget);
      expect(find.text(Strings.miscellaneousErrorRetry), findsNothing);
    });

    testWidgets('l’alerte est annoncée par le lecteur d’écran à son apparition', (tester) async {
      final store = await pumpCguPageWithStore(tester, cguToAccept());

      await failAccept(tester, store);

      final liveRegion = find.ancestor(
        of: errorAlert(Strings.miscellaneousErrorRetry),
        matching: find.byWidgetPredicate((w) => w is Semantics && w.properties.liveRegion == true),
      );
      expect(liveRegion, findsOneWidget);
    });

    testWidgets('la page défile jusqu’à l’alerte quand elle apparaît sous le bord de l’écran', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final store = await pumpCguPageWithStore(tester, cguToAccept());

      await failAccept(tester, store);

      final viewportBottom = tester.getRect(find.byType(SingleChildScrollView)).bottom;
      expect(tester.getRect(errorAlert(Strings.miscellaneousErrorRetry)).bottom, lessThanOrEqualTo(viewportBottom));
    });

    testWidgets('l’erreur de l’interrupteur remplace celle de l’enregistrement', (tester) async {
      final store = await pumpCguPageWithStore(tester, cguToAccept());
      await failAccept(tester, store);

      await tester.tap(find.text(Strings.cguAccept));
      await tester.pump(const Duration(seconds: 1));

      expect(errorAlert(Strings.cguSwitchError), findsOneWidget);
      expect(find.text(Strings.miscellaneousErrorRetry), findsNothing);
    });
  });
}
