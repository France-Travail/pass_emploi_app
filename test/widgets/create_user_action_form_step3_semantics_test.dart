import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_step3.dart';
import 'package:pass_emploi_app/presentation/user_action/creation_form/create_user_action_form_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required bool errorsVisible}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreateUserActionFormStep3(
            actionType: UserActionReferentielType.emploi,
            titleSource: CreateActionTitleFromUserInput('Mon action'),
            viewModel: CreateUserActionStep3ViewModel(errorsVisible: errorsVisible),
            onDateChanged: (_, __) {},
            onDescriptionChanged: (_, __) {},
            onDelete: (_) {},
            onAddDuplicatedUserAction: () {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  // Données sémantiques des nœuds visibles, non fusionnés dans leur parent, dans l'ordre de lecture.
  List<SemanticsData> readableNodes(WidgetTester tester) {
    final result = <SemanticsData>[];
    void visit(SemanticsNode node) {
      if (!node.isInvisible && !node.isMergedIntoParent) result.add(node.getSemanticsData());
      node.visitChildren((child) {
        visit(child);
        return true;
      });
    }

    visit(tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!);
    return result;
  }

  testWidgets('A11y 9.9 : l\'erreur de la date est annoncée avec le champ, sans nœud séparé', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, errorsVisible: true);

    final nodes = readableNodes(tester);
    final withDateLabel = nodes.where((n) => n.label.contains(Strings.datePickerTitle)).toList();
    expect(withDateLabel, isNotEmpty);
    expect(withDateLabel.any((n) => n.label.contains(Strings.dateMandatory)), isTrue);
    // Aucun nœud ne porte l'erreur seule.
    expect(nodes.where((n) => n.label == Strings.dateMandatory), isEmpty);
    handle.dispose();
  });

  testWidgets('A11y 9.9 : sans erreur, la date ne mentionne pas d\'erreur', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, errorsVisible: false);

    final nodes = readableNodes(tester);
    expect(nodes.any((n) => n.label.contains(Strings.dateMandatory)), isFalse);
    handle.dispose();
  });
}
