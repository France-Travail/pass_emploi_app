import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/network/cache_manager.dart';
import 'package:pass_emploi_app/redux/app_reducer.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

import 'fixtures.dart';

class NextDispatcherSpy {
  bool wasCalled = false;
  late final dynamic _expectedAction;

  NextDispatcherSpy({dynamic expectedAction}) {
    _expectedAction = expectedAction;
  }

  dynamic performAction(dynamic action) {
    expect(action, _expectedAction);
    wasCalled = true;
  }
}

class StoreSpy extends Store<AppState> {
  dynamic dispatchedAction;

  StoreSpy() : super(reducer, initialState: AppState.initialState(configuration: configuration()));

  StoreSpy.withState(AppState appState) : super(reducer, initialState: appState);

  @override
  void dispatch(dynamic action) => dispatchedAction = action;
}

class SharedPreferencesSpy extends FlutterSecureStorage {
  final Map<String, String> _storedValues = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    await simulateIoOperation();
    _storedValues[key] = value!;
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    await simulateIoOperation();
    return _storedValues[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    await simulateIoOperation();
    _storedValues.remove(key);
  }

  Future<void> simulateIoOperation() async => await Future.delayed(Duration(milliseconds: 10));
}

class SpyPassEmploiCacheManager extends PassEmploiCacheManager {
  SpyPassEmploiCacheManager() : super(MemCacheStore(maxSize: 0, maxEntrySize: 0), '');

  CachedResource? removeResourceParams;
  bool removeSuggestionsRechercheResourceWasCalled = false;

  @override
  Future<void> removeResource(CachedResource resourceToRemove, String userId) async {
    removeResourceParams = resourceToRemove;
  }

  @override
  Future<void> removeActionCommentaireResource(String actionId) async {}

  @override
  Future<void> removeSuggestionsRechercheResource({required String userId}) async {
    removeSuggestionsRechercheResourceWasCalled = true;
  }

  @override
  Future<void> emptyCache() => Future<void>.value();
}
