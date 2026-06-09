import 'dart:io';

import 'package:pass_emploi_app/features/soft_update/soft_update_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/remote_config_repository.dart';
import 'package:pass_emploi_app/repositories/soft_update_repository.dart';
import 'package:redux/redux.dart';

class SoftUpdateMiddleware extends MiddlewareClass<AppState> {
  final SoftUpdateRepository _repository;
  final RemoteConfigRepository _remoteConfigRepository;

  SoftUpdateMiddleware(this._repository, this._remoteConfigRepository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    if (action is SoftUpdateCheckAction) {
      final softVersion = _remoteConfigRepository.softUpdateVersion(isAndroid: Platform.isAndroid);
      final shouldShow = await _repository.shouldShowSoftUpdate(softVersion);
      if (shouldShow) store.dispatch(ShowSoftUpdateAction());
    }
    if (action is SoftUpdateDismissAction) {
      await _repository.dismiss();
    }
  }
}
