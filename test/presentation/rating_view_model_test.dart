import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/rating/rating_actions.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/presentation/rating_view_model.dart';
import 'package:pass_emploi_app/utils/platform.dart';

import '../doubles/fixtures.dart';
import '../doubles/spies.dart';
import '../dsl/app_state_dsl.dart';

void main() {
  test('should dispatch done action correctly', () {
    // Given
    final store = StoreSpy.withState(givenState().showRating());
    final viewModel = RatingViewModel.create(store, Platform.ANDROID);

    // When
    viewModel.onDone();

    // Then
    expect(store.dispatchedAction, isA<RatingDoneAction>());
  });

  test('should send email on negative rating when platform is Android', () {
    // Given
    final store = givenState().showRating().store();

    // When
    final viewModel = RatingViewModel.create(store, Platform.ANDROID);

    // Then
    expect(viewModel.shouldSendEmailOnNegativeRating, isTrue);
  });

  test('should send email on negative rating when platform is iOS and brand is CEJ', () {
    // Given
    final store = givenState(configuration(brand: Brand.cej)).showRating().store();

    // When
    final viewModel = RatingViewModel.create(store, Platform.IOS);

    // Then
    expect(viewModel.shouldSendEmailOnNegativeRating, isTrue);
  });

  test('should not send email on negative rating when platform is iOS and brand is BRSA', () {
    // Given
    final store = givenBrsaState().showRating().store();

    // When
    final viewModel = RatingViewModel.create(store, Platform.IOS);

    // Then
    expect(viewModel.shouldSendEmailOnNegativeRating, isFalse);
  });
}
