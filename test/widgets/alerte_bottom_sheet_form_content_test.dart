import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/bottom_sheets/alerte_bottom_sheet_form_content.dart';

void main() {
  testWidgets('A11y : le formulaire « Créer une alerte pour la recherche » n’est pas restitué comme une liste',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlerteBottomSheetFormContent(
            initialTitle: 'Boulanger - Paris',
            tags: [const AlerteFormTag('Boulanger'), AlerteFormTag.location('Paris')],
            savingFailure: false,
            onCreate: (_) {},
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel(RegExp(Strings.alerteTitle)), findsOneWidget);
    // Le moteur Android expose comme une liste (CollectionInfo) tout nœud qui déclare plus d'un élément.
    expect(
      find.semantics.byPredicate((node) => (node.getSemanticsData().scrollChildCount ?? 0) > 1),
      findsNothing,
    );
    semantics.dispose();
  });
}
