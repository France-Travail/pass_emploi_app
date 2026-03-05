import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/auto_desinscription/auto_desinscription_actions.dart';
import 'package:pass_emploi_app/features/auto_desinscription/auto_desinscription_state.dart';

import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

void main() {
  group('AutoDesinscription', () {
    final sut = StoreSut();
    final repository = MockAutoDesinscriptionRepository();

    group("when requesting", () {
      sut.whenDispatchingAction(() => AutoDesinscriptionRequestAction(eventId: "event-1", motif: "test-motif"));

      test('should load then succeed when request succeeds', () {
        when(() => repository.desinscrire(any(), any(), any())).thenAnswer((_) async => true);

        sut.givenStore = givenState() //
            .loggedInUser()
            .store((f) => {f.autoDesinscriptionRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldSucceed()]);
      });

      test('should load then fail when request fails', () {
        when(() => repository.desinscrire(any(), any(), any())).thenAnswer((_) async => null);

        sut.givenStore = givenState() //
            .loggedInUser()
            .store((f) => {f.autoDesinscriptionRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldFail()]);
      });
    });

    group("when user is not logged in", () {
      sut.whenDispatchingAction(() => AutoDesinscriptionRequestAction(eventId: "event-1", motif: "test-motif"));

      test('should not dispatch loading when userId is null', () {
        when(() => repository.desinscrire(any(), any(), any())).thenAnswer((_) async => true);

        sut.givenStore = givenState() //
            .store((f) => {f.autoDesinscriptionRepository = repository});

        sut.thenExpectNever(_shouldLoad());
      });
    });
  });
}

Matcher _shouldLoad() => StateIs<AutoDesinscriptionLoadingState>((state) => state.autoDesinscriptionState);

Matcher _shouldFail() => StateIs<AutoDesinscriptionFailureState>((state) => state.autoDesinscriptionState);

Matcher _shouldSucceed() {
  return StateIs<AutoDesinscriptionSuccessState>(
    (state) => state.autoDesinscriptionState,
    (state) {
      expect(state.result, true);
    },
  );
}
