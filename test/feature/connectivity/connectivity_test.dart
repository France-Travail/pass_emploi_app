import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/connectivity/connectivity_actions.dart';
import 'package:pass_emploi_app/features/connectivity/connectivity_state.dart';
import 'package:pass_emploi_app/wrappers/connectivity_wrapper.dart';

import '../../dsl/app_state_dsl.dart';
import '../../dsl/matchers.dart';
import '../../dsl/sut_redux.dart';

void main() {
  group('Connectivity', () {
    final sut = StoreSut();

    group("when subscribing to connectivity updates", () {
      sut.when(() => SubscribeToConnectivityUpdatesAction());

      test('should receive connectivity updates and change state accordingly', () async {
        // Given
        final controller = StreamController<ConnectivityResult>();
        sut.givenStore = givenState() //
            .loggedInUser()
            .store((f) => {f.connectivityWrapper = ConnectivityWrapper(controller.stream)});

        // When
        controller.sink.add(ConnectivityResult.wifi);

        // Then
        sut.thenExpectChangingStatesThroughOrder([
          _shouldHaveConnectivity(ConnectivityResult.none),
          _shouldHaveConnectivity(ConnectivityResult.wifi),
        ]);
      });
    });

    group("when subscribing to connectivity updates", () {
      test('should receive connectivity updates and change state accordingly', () async {
        // Given
        final wrapper = SpyConnectivityWrapper();
        final store = givenState() //
            .loggedInUser()
            .store((f) => {f.connectivityWrapper = wrapper});

        // When
        await store.dispatch(UnsubscribeFromConnectivityUpdatesAction());

        // Then
        verify(() => wrapper.unsubscribeFromUpdates()).called(1);
      });
    });
  });
}

Matcher _shouldHaveConnectivity(ConnectivityResult result) {
  return StateIs<ConnectivityState>(
    (state) => state.connectivityState,
    (state) => expect(state.result, result),
  );
}

class SpyConnectivityWrapper extends Mock implements ConnectivityWrapper {}
