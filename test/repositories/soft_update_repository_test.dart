import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/repositories/soft_update_repository.dart';

import '../doubles/spies.dart';

void main() {
  late FlutterSecureStorageSpy secureStorage;
  late SoftUpdateRepository repository;

  setUp(() {
    secureStorage = FlutterSecureStorageSpy(delay: Duration.zero);
    repository = SoftUpdateRepository(
      secureStorage,
      getCurrentVersion: () async => '4.11.3',
    );
  });

  group('SoftUpdateRepository', () {
    group('shouldShowSoftUpdate', () {
      test('should return false when soft update version is null', () async {
        expect(await repository.shouldShowSoftUpdate(null), false);
      });

      test('should return false when current version is up to date', () async {
        expect(await repository.shouldShowSoftUpdate('4.0.0'), false);
      });

      test('should return true when current version is outdated and never dismissed', () async {
        expect(await repository.shouldShowSoftUpdate('99.0.0'), true);
      });

      test('should return false when dismissed less than 24 hours ago', () {
        final now = DateTime(2024, 1, 2, 12);
        withClock(Clock.fixed(now), () async {
          final dismissedAt = now.subtract(const Duration(hours: 12));
          await secureStorage.write(
            key: 'soft-update-dismissed-at',
            value: dismissedAt.millisecondsSinceEpoch.toString(),
          );

          expect(await repository.shouldShowSoftUpdate('99.0.0'), false);
        });
      });

      test('should return true when dismissed more than 24 hours ago', () {
        final now = DateTime(2024, 1, 2, 12);
        withClock(Clock.fixed(now), () async {
          final dismissedAt = now.subtract(const Duration(hours: 25));
          await secureStorage.write(
            key: 'soft-update-dismissed-at',
            value: dismissedAt.millisecondsSinceEpoch.toString(),
          );

          expect(await repository.shouldShowSoftUpdate('99.0.0'), true);
        });
      });
    });

    group('dismiss', () {
      test('should persist dismiss timestamp', () {
        final now = DateTime(2024, 1, 2, 12);
        withClock(Clock.fixed(now), () async {
          await repository.dismiss();

          expect(
            await secureStorage.read(key: 'soft-update-dismissed-at'),
            now.millisecondsSinceEpoch.toString(),
          );
        });
      });
    });
  });
}
