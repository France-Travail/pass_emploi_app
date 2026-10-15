import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_step2.dart';
import 'package:pass_emploi_app/ui/strings.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required String text, required bool isInvalid}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UserActionDescriptionField(
            descriptionController: TextEditingController(text: text),
            onDescriptionChanged: (_) {},
            onClear: () {},
            hintText: 'Exemple',
            isInvalid: isInvalid,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  // Parcourt l'arbre sémantique dans l'ordre de lecture et renvoie les nœuds du champ et des boutons.
  List<SemanticsData> traversal(WidgetTester tester) {
    final result = <SemanticsData>[];
    void visit(SemanticsNode node) {
      final data = node.getSemanticsData();
      final isField = data.flagsCollection.isTextField;
      final isButton = data.flagsCollection.isButton;
      if (!node.isInvisible && !node.isMergedIntoParent && (isField || isButton)) result.add(data);
      node.visitChildren((child) {
        visit(child);
        return true;
      });
    }

    visit(tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!);
    return result;
  }

  testWidgets('A11y 5.1 / 9.9 : le champ est lu avec son erreur, puis Dicter', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, text: '', isInvalid: true);

    final nodes = traversal(tester);
    expect(nodes.length, 2);
    final field = nodes.first;
    expect(field.flagsCollection.isTextField, isTrue);
    expect(field.flagsCollection.isButton, isFalse);
    expect(field.label, contains(Strings.userActionDescriptionTextfieldStep2));
    expect(field.label, contains(Strings.descriptionMandatory));

    final dictate = nodes.last;
    expect(dictate.flagsCollection.isButton, isTrue);
    expect(dictate.label, Strings.dictationStart);
    handle.dispose();
  });

  testWidgets('A11y 5.1 : avec du texte, ordre champ, Effacer, Dicter', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, text: 'abc', isInvalid: false);

    final nodes = traversal(tester);
    expect(nodes.length, 3);
    expect(nodes[0].flagsCollection.isTextField, isTrue);
    expect(nodes[0].label, isNot(contains(Strings.descriptionMandatory)));
    expect(nodes[1].label, Strings.clear);
    expect(nodes[2].label, Strings.dictationStart);
    handle.dispose();
  });
}
