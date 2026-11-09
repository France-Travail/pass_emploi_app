import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/presentation/solutions_tabs_page_view_model.dart';

import '../dsl/app_state_dsl.dart';

void main() {
  test('create should set proper tabs', () {
    // Given
    final store = givenState().loggedInPoleEmploiUser().store();

    // When
    final viewModel = SolutionsTabPageViewModel.create(store);

    // Then
    expect(viewModel.tabs, [SolutionsTab.recherche, SolutionsTab.offresEnregistrees, SolutionsTab.alertes]);
    expect(viewModel.withTabBar, isTrue);
  });

  test('create should hide offre tracking and alerts tabs for a guest', () {
    // Given
    final store = givenState().loggedInUser(loginMode: LoginMode.INVITE).store();

    // When
    final viewModel = SolutionsTabPageViewModel.create(store);

    // Then
    expect(viewModel.tabs, [SolutionsTab.recherche]);
    expect(viewModel.withTabBar, isFalse);
  });
}
