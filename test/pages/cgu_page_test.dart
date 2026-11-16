import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/pages/cgu_page.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_accessible_toggle_switch.dart';

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
}
