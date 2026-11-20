import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/presentation/checkbox_value_view_model.dart';
import 'package:pass_emploi_app/widgets/tag_group.dart';

void main() {
  testWidgets('A11y 9.6 : chaque étiquette de filtre reprend le titre du groupe après son libellé', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TagGroup<String>(
            title: 'Modalités d’accès',
            options: [
              CheckboxValueViewModel(label: 'En présentiel', value: 'physique', isInitiallyChecked: true),
              CheckboxValueViewModel(label: 'À distance', value: 'distance', isInitiallyChecked: false),
            ],
            onSelectedOptionsUpdated: (_) {},
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('En présentiel, Modalités d’accès')),
      isSemantics(hasCheckedState: true, isChecked: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('À distance, Modalités d’accès')),
      isSemantics(hasCheckedState: true, isChecked: false),
    );
    semantics.dispose();
  });
}
