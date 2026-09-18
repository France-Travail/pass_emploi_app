import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/accueil/accueil_actions.dart';
import 'package:pass_emploi_app/features/communications/communications_actions.dart';
import 'package:pass_emploi_app/features/communications/communications_state.dart';
import 'package:pass_emploi_app/models/communications.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

void main() {
  group('Communications', () {
    final sut = StoreSut();
    final repository = MockCommunicationsRepository();

    group("when requesting", () {
      sut.whenDispatchingAction(() => CommunicationsRequestAction());

      test('should load then succeed when request succeeds', () {
        when(
          () => repository.get(""),
        ).thenAnswer((_) async => Communications(messageInformatif: mockMessageInformatif()));

        sut.givenStore =
            givenState() //
                .loggedInUser()
                .store((f) => {f.communicationsRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldSucceed()]);
      });

      test('should load then succeed without message when none is returned', () {
        when(() => repository.get("")).thenAnswer((_) async => Communications());

        sut.givenStore =
            givenState() //
                .loggedInUser()
                .store((f) => {f.communicationsRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldSucceedWithoutMessage()]);
      });

      test('should load then fail when request fails', () {
        when(() => repository.get("")).thenAnswer((_) async => null);

        sut.givenStore =
            givenState() //
                .loggedInUser()
                .store((f) => {f.communicationsRepository = repository});

        sut.thenExpectChangingStatesThroughOrder([_shouldLoad(), _shouldFail()]);
      });
    });

    group("when requesting accueil", () {
      sut.whenDispatchingAction(() => AccueilRequestAction());

      test('should fetch communications', () {
        when(
          () => repository.get(""),
        ).thenAnswer((_) async => Communications(messageInformatif: mockMessageInformatif()));

        sut.givenStore =
            givenState() //
                .loggedInUser()
                .store((f) => {f.communicationsRepository = repository});

        sut.thenExpectAtSomePoint(_shouldSucceed());
      });
    });
  });
}

Matcher _shouldLoad() => StateIs<CommunicationsLoadingState>((state) => state.communicationsState);

Matcher _shouldFail() => StateIs<CommunicationsFailureState>((state) => state.communicationsState);

Matcher _shouldSucceed() {
  return StateIs<CommunicationsSuccessState>(
    (state) => state.communicationsState,
    (state) {
      expect(state.messageInformatif, mockMessageInformatif());
    },
  );
}

Matcher _shouldSucceedWithoutMessage() {
  return StateIs<CommunicationsSuccessState>(
    (state) => state.communicationsState,
    (state) {
      expect(state.messageInformatif, isNull);
    },
  );
}
