import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/utils/secure_storage_exception_handler_decorator.dart';

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
