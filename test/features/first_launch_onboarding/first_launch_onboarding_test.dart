import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';
import 'package:pass_emploi_app/features/first_launch_onboarding/first_launch_onboarding_actions.dart';
import 'package:pass_emploi_app/features/first_launch_onboarding/first_launch_onboarding_state.dart';

import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

void main() {
  group('FirstLaunchOnboarding', () {
    final sut = StoreSut();
    final repository = MockFirstLaunchOnboardingRepository();

    group("when requesting", () {
      sut.whenDispatchingAction(() => BootstrapAction());

      test('should load then succeed when request succeeds', () {
        when(() => repository.showFirstLaunchOnboarding()).thenAnswer((_) async => true);

        sut.givenStore = givenState() //
            .loggedIn()
            .store((f) => {f.firstLaunchOnboardingRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldSucceed(showOnboarding: true)]);
      });
    });

    group("when finishing", () {
      sut.whenDispatchingAction(() => FirstLaunchOnboardingFinishAction());

      test('should mark as seen and stop showing onboarding', () {
        when(() => repository.seen()).thenAnswer((_) async {});

        sut.givenStore = givenState().store((f) => {f.firstLaunchOnboardingRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldSucceed(showOnboarding: false)]);
      });

      test('should stop showing onboarding even when persisting "seen" fails', () {
        when(() => repository.seen()).thenThrow(Exception('secure storage unavailable'));

        sut.givenStore = givenState().store((f) => {f.firstLaunchOnboardingRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldSucceed(showOnboarding: false)]);
      });
    });
  });
}

Matcher _shouldSucceed({required bool showOnboarding}) {
  return StateIs<FirstLaunchOnboardingSuccessState>(
    (state) => state.firstLaunchOnboardingState,
    (state) {
      expect(state.showOnboarding, showOnboarding);
    },
  );
}
