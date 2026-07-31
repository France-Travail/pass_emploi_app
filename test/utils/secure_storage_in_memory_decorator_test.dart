import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/utils/secure_storage_in_memory_decorator.dart';

import '../doubles/spies.dart';

void main() {
  test('write persists to disk then updates memory', () async {
    final disk = FlutterSecureStorageSpy(delay: Duration.zero);
    final storage = SecureStorageInMemoryDecorator(disk);

    await storage.write(key: 'idToken', value: 'token');

    expect(await disk.read(key: 'idToken'), 'token');
    expect(await storage.read(key: 'idToken'), 'token');
  });

  test('write failure must not leave a RAM-only value', () async {
    final storage = SecureStorageInMemoryDecorator(_FailingWriteSecureStorage());

    await expectLater(
      storage.write(key: 'idToken', value: 'token'),
      throwsA(isA<PlatformException>()),
    );

    expect(await storage.read(key: 'idToken'), isNull);
  });

  test('delete awaits disk and clears memory', () async {
    final disk = FlutterSecureStorageSpy(delay: Duration.zero);
    final storage = SecureStorageInMemoryDecorator(disk);
    await storage.write(key: 'idToken', value: 'token');

    await storage.delete(key: 'idToken');

    expect(await disk.read(key: 'idToken'), isNull);
    expect(await storage.read(key: 'idToken'), isNull);
  });

  test('cold start loads existing disk values into memory', () async {
    final disk = FlutterSecureStorageSpy(delay: Duration.zero);
    await disk.write(key: 'idToken', value: 'persisted');

    final storage = SecureStorageInMemoryDecorator(disk);

    expect(await storage.read(key: 'idToken'), 'persisted');
  });
}

class _FailingWriteSecureStorage extends FlutterSecureStorage {
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
    throw PlatformException(code: 'KeyStoreError');
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
    return {};
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
    return null;
  }
}
