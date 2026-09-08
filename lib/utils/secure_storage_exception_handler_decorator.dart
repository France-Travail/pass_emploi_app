import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';

class SecureStorageExceptionHandlerDecorator extends FlutterSecureStorage {
  final FlutterSecureStorage decorated;
  final Crashlytics? crashlytics;

  bool _storeReset = false;

  SecureStorageExceptionHandlerDecorator(this.decorated, [this.crashlytics]);

  bool _isUnrecoverableMigrationError(Object exception) {
    if (exception is! PlatformException) return false;
    final message = '${exception.message ?? ''} ${exception.details ?? ''}';
    return message.contains('Migration failed') ||
        message.contains('Failed to unwrap key') ||
        message.contains('resetOnError');
  }

  Future<bool> _resetUnrecoverableStore(Object exception, StackTrace stack) async {
    if (_storeReset || !_isUnrecoverableMigrationError(exception)) return false;
    _storeReset = true;
    crashlytics?.recordNonNetworkException(
      'SecureStorage unrecoverable migration error, wiping store: $exception',
      stack,
    );
    try {
      await decorated.deleteAll();
      return true;
    } catch (resetException, resetStack) {
      crashlytics?.recordNonNetworkException('SecureStorage wipe failed: $resetException', resetStack);
      return false;
    }
  }

  Future<void> _guardWrite(String key, Future<void> Function() operation) async {
    try {
      await operation();
    } catch (exception, stack) {
      if (await _resetUnrecoverableStore(exception, stack)) {
        try {
          await operation();
          return;
        } catch (retryException, retryStack) {
          crashlytics?.recordNonNetworkException(
            'SecureStorage write retry failed for key "$key": $retryException',
            retryStack,
          );
          rethrow;
        }
      }
      crashlytics?.recordNonNetworkException('SecureStorage write failed for key "$key": $exception', stack);

      rethrow;
    }
  }

  Future<T> _guardRead<T>(T fallback, String description, Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (exception, stack) {
      if (await _resetUnrecoverableStore(exception, stack)) {
        try {
          return await operation();
        } catch (retryException, retryStack) {
          crashlytics?.recordNonNetworkException(
            'SecureStorage $description retry failed: $retryException',
            retryStack,
          );
          return fallback;
        }
      }
      crashlytics?.recordNonNetworkException('SecureStorage $description failed: $exception', stack);
      return fallback;
    }
  }

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
  }) {
    return _guardWrite(
      key,
      () => decorated.write(
        key: key,
        value: value,
        iOptions: iOptions,
        aOptions: aOptions,
        lOptions: lOptions,
        webOptions: webOptions,
        mOptions: mOptions,
        wOptions: wOptions,
      ),
    );
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
  }) {
    return _guardRead<String?>(
      null,
      'read for key "$key"',
      () => decorated.read(
        key: key,
        iOptions: iOptions,
        aOptions: aOptions,
        lOptions: lOptions,
        webOptions: webOptions,
        mOptions: mOptions,
        wOptions: wOptions,
      ),
    );
  }

  @override
  Future<bool> containsKey({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) {
    return _guardRead<bool>(
      false,
      'containsKey for key "$key"',
      () => decorated.containsKey(
        key: key,
        iOptions: iOptions,
        aOptions: aOptions,
        lOptions: lOptions,
        webOptions: webOptions,
        mOptions: mOptions,
        wOptions: wOptions,
      ),
    );
  }

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) {
    return _guardRead<Map<String, String>>(
      {},
      'readAll',
      () => decorated.readAll(
        iOptions: iOptions,
        aOptions: aOptions,
        lOptions: lOptions,
        webOptions: webOptions,
        mOptions: mOptions,
        wOptions: wOptions,
      ),
    );
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
    try {
      await decorated.delete(
        key: key,
        iOptions: iOptions,
        aOptions: aOptions,
        lOptions: lOptions,
        webOptions: webOptions,
        mOptions: mOptions,
        wOptions: wOptions,
      );
    } catch (exception, stack) {
      crashlytics?.recordNonNetworkException('SecureStorage delete failed for key "$key": $exception', stack);
    }
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
    try {
      await decorated.deleteAll(
        iOptions: iOptions,
        aOptions: aOptions,
        lOptions: lOptions,
        webOptions: webOptions,
        mOptions: mOptions,
        wOptions: wOptions,
      );
    } catch (exception, stack) {
      crashlytics?.recordNonNetworkException('SecureStorage deleteAll failed: $exception', stack);
    }
  }
}
