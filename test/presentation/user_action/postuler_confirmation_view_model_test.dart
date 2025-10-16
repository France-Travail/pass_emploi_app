import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/presentation/user_action/postuler_confirmation_view_model.dart';

import '../../dsl/app_state_dsl.dart';

void main() {
  test('should return null when user is in avenir pro', () {
    // Given
    final store = givenState() //
        .loggedInUser(accompagnement: Accompagnement.avenirPro)
        .store();

    // When
    final viewModel = PostulerConfirmationViewModel.create(store, "offreId");

    // Then
    expect(viewModel.onCreateActionOrDemarche, isNull);
  });
}
