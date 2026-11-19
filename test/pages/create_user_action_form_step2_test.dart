import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/user_action_type.dart';
import 'package:pass_emploi_app/pages/user_action/create/create_user_action_form_step2.dart';
import 'package:pass_emploi_app/presentation/user_action/creation_form/create_user_action_form_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';

void main() {
  testWidgets('A11y 9.6 : chaque suggestion d’action reprend la consigne du groupe après son libellé', (tester) async {
    final semantics = tester.ensureSemantics();
    const type = UserActionReferentielType.emploi;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreateUserActionFormStep2(
            actionType: type,
            viewModel: CreateUserActionStep2ViewModel(),
            onTitleChanged: (_) {},
            onDescriptionChanged: (_) {},
          ),
        ),
      ),
    );

    for (final libelle in [...type.suggestionList.map((s) => s.value), Strings.userActionOther]) {
      expect(
        tester.getSemantics(find.bySemanticsLabel('$libelle, ${Strings.userActionSubtitleStep2}')),
        isSemantics(hasCheckedState: true, isChecked: false, isInMutuallyExclusiveGroup: true, hasTapAction: true),
      );
    }
    semantics.dispose();
  });
}
