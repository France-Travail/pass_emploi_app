import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/features/push_notification/register/register_push_notification_token_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/configuration_application_repository.dart';
import 'package:redux/src/store.dart';

import '../../doubles/dio_mock.dart';
import '../../doubles/dummies.dart';
import '../../doubles/fixtures.dart';
import '../../doubles/mocks.dart';
import '../../utils/test_setup.dart';
import '../favoris/offre_emploi_favoris_test.dart';

void main() {
  late _RegisterTokenRepositorySpy tokenRepositorySpy;
  late Store<AppState> store;

  final loginTime = DateTime(2024, 1, 1, 12);

  Future<void> dispatch(dynamic action) async {
    await store.dispatch(action);
    await pumpEventQueue();
  }

  setUp(() {
    tokenRepositorySpy = _RegisterTokenRepositorySpy();
    final testStoreFactory = TestStoreFactory();
    testStoreFactory.offreEmploiFavorisRepository =
        OffreEmploiFavorisRepositorySuccessStub();
    testStoreFactory.registerTokenRepository = tokenRepositorySpy;
    store = testStoreFactory.initializeReduxStore(
      initialState: AppState.initialState().copyWith(
        loginState: LoginGenericFailureState(''),
      ),
    );
  });

  test("push notification token should be registered", () async {
    // When
    await withClock(Clock.fixed(loginTime), () async {
      await dispatch(LoginSuccessAction(mockUser(id: "1")));
    });

    // Then
    expect(tokenRepositorySpy.callCount, 1);
  });

  test(
    "should not call configuration-application on foreground when last call is less than 24 hours ago",
    () async {
      // Given
      await withClock(Clock.fixed(loginTime), () async {
        await dispatch(LoginSuccessAction(mockUser(id: "1")));
      });

      // When
      await withClock(
        Clock.fixed(loginTime.add(const Duration(hours: 23))),
        () async {
          await dispatch(ConfigureApplicationOnForegroundAction());
        },
      );

      // Then
      expect(tokenRepositorySpy.callCount, 1);
    },
  );

  test(
    "should call configuration-application on foreground when last call is at least 24 hours ago",
    () async {
      // Given
      await withClock(Clock.fixed(loginTime), () async {
        await dispatch(LoginSuccessAction(mockUser(id: "1")));
      });

      // When
      await withClock(
        Clock.fixed(loginTime.add(const Duration(hours: 24))),
        () async {
          await dispatch(ConfigureApplicationOnForegroundAction());
        },
      );

      // Then
      expect(tokenRepositorySpy.callCount, 2);
    },
  );

  test(
    "should not call configuration-application on foreground when user is not logged in",
    () async {
      // When
      await dispatch(ConfigureApplicationOnForegroundAction());

      // Then
      expect(tokenRepositorySpy.callCount, 0);
    },
  );

  test(
    "should retry configuration-application on foreground when previous PUT failed",
    () async {
      // Given
      tokenRepositorySpy.shouldSucceed = false;
      await withClock(Clock.fixed(loginTime), () async {
        await dispatch(LoginSuccessAction(mockUser(id: "1")));
      });
      expect(tokenRepositorySpy.callCount, 1);

      // When
      tokenRepositorySpy.shouldSucceed = true;
      await withClock(Clock.fixed(loginTime), () async {
        await dispatch(ConfigureApplicationOnForegroundAction());
      });

      // Then
      expect(tokenRepositorySpy.callCount, 2);
    },
  );
}

class _RegisterTokenRepositorySpy extends ConfigurationApplicationRepository {
  int callCount = 0;
  bool shouldSucceed = true;

  _RegisterTokenRepositorySpy()
    : super(
        DioMock(),
        DummyFirebaseInstanceIdGetter(),
        MockPushNotificationManager(),
      );

  @override
  Future<bool> configureApplication(String userId, String fuseauHoraire) async {
    expect(userId, "1");
    callCount++;
    return shouldSucceed;
  }
}
