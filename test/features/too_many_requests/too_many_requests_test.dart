import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/too_many_requests/too_many_requests_actions.dart';
import 'package:pass_emploi_app/features/too_many_requests/too_many_requests_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

import '../../dsl/app_state_dsl.dart';

void main() {
  final now = DateTime(2026, 11, 23, 10);

  bool isTooManyRequests(AppState state) => withClock(Clock.fixed(now), () => state.isTooManyRequests());

  test('pas de limite au démarrage', () {
    expect(isTooManyRequests(givenState()), isFalse);
  });

  test('la limite court jusqu\'à la fin signalée', () async {
    // Given
    final store = givenState().store();

    // When
    await store.dispatch(TooManyRequestsAction(now.add(Duration(seconds: 30))));

    // Then
    expect(isTooManyRequests(store.state), isTrue);
    expect(
      store.state.tooManyRequestsState.isActive(now.add(Duration(seconds: 30))),
      isFalse,
    );
  });

  test(
    'un refus plus court ne raccourcit pas une limite plus longue',
    () async {
      // Given
      final store = givenState().store();
      await store.dispatch(
        TooManyRequestsAction(now.add(Duration(minutes: 2))),
      );

      // When
      await store.dispatch(
        TooManyRequestsAction(now.add(Duration(seconds: 30))),
      );

      // Then
      expect(
        store.state.tooManyRequestsState.retryNotBefore,
        now.add(Duration(minutes: 2)),
      );
    },
  );

  test('un refus plus long prolonge la limite', () async {
    // Given
    final store = givenState().store();
    await store.dispatch(TooManyRequestsAction(now.add(Duration(seconds: 30))));

    // When
    await store.dispatch(TooManyRequestsAction(now.add(Duration(minutes: 2))));

    // Then
    expect(
      store.state.tooManyRequestsState.retryNotBefore,
      now.add(Duration(minutes: 2)),
    );
  });
}
