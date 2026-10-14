import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_navigation.dart';

void main() {
  Future<void> pumpAt200Percent(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
          child: app!,
        ),
        home: child,
      ),
    );
  }

  RenderParagraph paragraphOf(WidgetTester tester, String text) {
    return tester.renderObject<RenderParagraph>(find.text(text));
  }

  testWidgets('A11y 8.2 : à 200 %, les libellés de la barre de navigation ne sont pas tronqués', (tester) async {
    final labels = [
      Strings.menuAccueil,
      Strings.menuMonSuivi,
      Strings.menuSolutions,
      Strings.menuEvenements,
      Strings.menuChat,
    ];
    await pumpAt200Percent(
      tester,
      Scaffold(
        bottomNavigationBar: DsfrBottomNavigation(
          currentIndex: 0,
          onTap: (_) {},
          items: [
            for (final label in labels)
              DsfrBottomNavigationItem(
                icon: DsfrIcons.buildingsHome4Line,
                activeIcon: DsfrIcons.buildingsHome4Fill,
                label: label,
              ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    for (final label in labels) {
      expect(paragraphOf(tester, label).didExceedMaxLines, isFalse, reason: label);
    }
  });

  testWidgets('A11y 8.2 : à 200 %, « Retour » tient sur une ligne', (tester) async {
    await pumpAt200Percent(tester, const Scaffold(appBar: BackAppBar()));

    final retour = paragraphOf(tester, Strings.back);
    expect(retour.getMaxIntrinsicWidth(double.infinity), lessThanOrEqualTo(retour.size.width));
  });
}
