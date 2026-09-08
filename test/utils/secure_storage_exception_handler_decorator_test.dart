import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/utils/secure_storage_exception_handler_decorator.dart';

import '../doubles/dummies.dart';

void main() {
  late SecureStorageExceptionHandlerDecorator secureStorage;

  setUp(() {
    secureStorage = SecureStorageExceptionHandlerDecorator(_ExceptionThrowerSecureStorage());
  });

  test('write should propagate exception after logging', () {
    expect(
      () => secureStorage.write(key: 'key', value: 'value'),
      throwsA(isA<PlatformException>()),
    );
  });

  test('read should not propagate exception and return null', () async {
    expect(await secureStorage.read(key: 'key'), isNull);
  });

  test('delete should not propagate exception', () {
    expect(() => secureStorage.delete(key: 'key'), returnsNormally);
  });

  test('readAll should not propagate exception and return empty map', () async {
    expect(await secureStorage.readAll(), isEmpty);
  });

  group('unrecoverable migration error', () {
    test('write wipes the corrupted store then retries successfully', () async {
      final disk = _FailingUntilWipedSecureStorage();
      final storage = SecureStorageExceptionHandlerDecorator(disk, DummyCrashlytics());

      await storage.write(key: 'firstLaunchOnboarding', value: 'seen');

      expect(disk.deleteAllCallCount, 1);
      expect(disk.values['firstLaunchOnboarding'], 'seen');
    });

    test('read wipes the corrupted store then retries', () async {
      final disk = _FailingUntilWipedSecureStorage();
      final storage = SecureStorageExceptionHandlerDecorator(disk, DummyCrashlytics());

      expect(await storage.read(key: 'anyKey'), isNull);
      expect(disk.deleteAllCallCount, 1);
    });

    test('store is wiped at most once per instance', () async {
      final disk = _FailingUntilWipedSecureStorage();
      final storage = SecureStorageExceptionHandlerDecorator(disk, DummyCrashlytics());

      await storage.write(key: 'a', value: '1');
      disk.failAgain();
      await expectLater(storage.write(key: 'b', value: '2'), throwsA(isA<PlatformException>()));

      expect(disk.deleteAllCallCount, 1);
    });

    test('a non-migration error is never treated as recoverable', () async {
      final disk = _FailingUntilWipedSecureStorage(message: 'some other keystore error');
      final storage = SecureStorageExceptionHandlerDecorator(disk, DummyCrashlytics());

      await expectLater(storage.write(key: 'a', value: '1'), throwsA(isA<PlatformException>()));
      expect(disk.deleteAllCallCount, 0);
    });
  });
}

class _ExceptionThrowerSecureStorage extends FlutterSecureStorage {
  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw PlatformException(code: 'code');
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw PlatformException(code: 'code');
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw PlatformException(code: 'code');
  }

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw PlatformException(code: 'code');
  }
}

/// Reproduces the `flutter_secure_storage` v10 migration failure: every
/// read/write throws until [deleteAll] clears the (unrecoverable) legacy data.
class _FailingUntilWipedSecureStorage extends FlutterSecureStorage {
  _FailingUntilWipedSecureStorage({
    this.message = 'Migration failed after algorithm change (Invalid key). Enable resetOnError=true or call deleteAll().',
  });

  final String message;
  final Map<String, String> values = {};
  int deleteAllCallCount = 0;
  bool _corrupted = true;

  void failAgain() => _corrupted = true;

  PlatformException get _migrationException => PlatformException(code: 'Exception', message: message);

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (_corrupted) throw _migrationException;
    values[key] = value!;
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (_corrupted) throw _migrationException;
    return values[key];
  }

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (_corrupted) throw _migrationException;
    return values;
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    deleteAllCallCount++;
    _corrupted = false;
    values.clear();
  }
}
