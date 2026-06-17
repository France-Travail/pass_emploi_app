import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/tech/crashlytics_middleware.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

class MockCrashlytics extends Mock implements Crashlytics {}

class MockStore extends Mock implements Store<AppState> {}

void main() {
  setUpAll(() {
    registerFallbackValue(StackTrace.empty);
  });

  late MockCrashlytics crashlytics;
  late MockStore store;
  late CrashlyticsMiddleware middleware;

  setUp(() {
    crashlytics = MockCrashlytics();
    store = MockStore();
    when(() => store.state).thenReturn(AppState.initialState());
    middleware = CrashlyticsMiddleware(crashlytics);
  });

  void dispatch(dynamic action) => middleware.call(store, action, (_) {});

  group('Logout tracking', () {
    test(
      'records a non-fatal + custom key for an UNEXPECTED (subi) logout',
      () {
        dispatch(RequestLogoutAction(LogoutReason.tooManyRefreshGenericErrors));

        verify(
          () => crashlytics.setCustomKey(
            'last_logout_reason',
            'tooManyRefreshGenericErrors',
          ),
        ).called(1);
        verify(
          () => crashlytics.recordNonNetworkException(any(), any()),
        ).called(1);
      },
    );

    test(
      'does NOT record a non-fatal for a voluntary logout (custom key + log only)',
      () {
        dispatch(RequestLogoutAction(LogoutReason.userLogout));

        verify(
          () => crashlytics.setCustomKey('last_logout_reason', 'userLogout'),
        ).called(1);
        verifyNever(() => crashlytics.recordNonNetworkException(any(), any()));
      },
    );
  });

  group('Zombie tracking', () {
    test(
      'records a zombie non-fatal on the FIRST consecutive refresh failure',
      () {
        dispatch(TokenRefreshGenericErrorAction(1));

        verify(
          () => crashlytics.setCustomKey('consecutive_refresh_failures', '1'),
        ).called(1);
        verify(
          () => crashlytics.recordNonNetworkException(any(), any()),
        ).called(1);
      },
    );

    test(
      'does NOT record a non-fatal on subsequent failures (only custom key + log)',
      () {
        dispatch(TokenRefreshGenericErrorAction(3));

        verify(
          () => crashlytics.setCustomKey('consecutive_refresh_failures', '3'),
        ).called(1);
        verifyNever(() => crashlytics.recordNonNetworkException(any(), any()));
      },
    );
  });
}
