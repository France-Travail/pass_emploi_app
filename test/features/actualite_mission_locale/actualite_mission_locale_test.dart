import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_actions.dart';
import 'package:pass_emploi_app/features/actualite_mission_locale/actualite_mission_locale_state.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

void main() {
  group('ActualiteMissionLocale', () {
    final sut = StoreSut();
    final repository = MockActualiteMissionLocaleRepository();

    group("when requesting", () {
      sut.whenDispatchingAction(() => ActualiteMissionLocaleRequestAction());

      test('should load then succeed when request succeeds', () {
        when(() => repository.get(any())).thenAnswer((_) async => [mockActualiteMissionLocale()]);

        sut.givenStore =
            givenState() //
                .loggedInUser()
                .withFeatureFlip(isActualiteMissionLocaleEnabled: true)
                .store((f) => {f.actualiteMissionLocaleRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldSucceed()]);
      });

      test('should load then fail when request fails', () {
        when(() => repository.get(any())).thenAnswer((_) async => null);

        sut.givenStore =
            givenState() //
                .loggedInUser()
                .withFeatureFlip(isActualiteMissionLocaleEnabled: true)
                .store((f) => {f.actualiteMissionLocaleRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldFail()]);
      });

      test('should not call repository when feature is disabled', () {
        final freshRepository = MockActualiteMissionLocaleRepository();

        sut.givenStore =
            givenState() //
                .loggedInUser()
                .withFeatureFlip(isActualiteMissionLocaleEnabled: false)
                .store((f) => {f.actualiteMissionLocaleRepository = freshRepository});

        sut.then(() {
          verifyNever(() => freshRepository.get(any()));
        });
      });
    });
  });
}

Matcher _shouldLoad() => StateIs<ActualiteMissionLocaleLoadingState>((state) => state.actualiteMissionLocaleState);

Matcher _shouldFail() => StateIs<ActualiteMissionLocaleFailureState>((state) => state.actualiteMissionLocaleState);

Matcher _shouldSucceed() {
  return StateIs<ActualiteMissionLocaleSuccessState>(
    (state) => state.actualiteMissionLocaleState,
    (state) {
      expect(state.result, [mockActualiteMissionLocale()]);
    },
  );
}
