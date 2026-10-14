import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form.dart';
import 'package:pass_emploi_app/ui/strings.dart';

void main() {
  testWidgets('A11y 8.5 : le formulaire s\'arrête au-dessus des boutons de navigation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CreateUserActionForm(onSubmit: (_) {}, onAbort: () {}),
      ),
    );
    await tester.pump();
    // Étape 1 : choix du type d'action, qui mène à l'étape 2 où les boutons de navigation sont affichés.
    await tester.tap(find.text(UserActionReferentielType.emploi.label));
    await tester.pumpAndSettle();

    final scrollable = find.byType(SingleChildScrollView).first;
    final backButton = find.widgetWithText(DsfrButton, Strings.back);
    expect(backButton, findsOneWidget);

    // Le contenu défilant s'arrête au-dessus des boutons : le focus ne peut pas passer dessous.
    expect(tester.getBottomLeft(scrollable).dy, lessThanOrEqualTo(tester.getTopLeft(backButton).dy));
  });
}
