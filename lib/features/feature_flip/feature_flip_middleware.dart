import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';
import 'package:pass_emploi_app/features/feature_flip/feature_flip_actions.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/remote_config_repository.dart';
import 'package:redux/redux.dart';

class FeatureFlipMiddleware extends MiddlewareClass<AppState> {
  final RemoteConfigRepository _remoteConfigRepository;

  FeatureFlipMiddleware(this._remoteConfigRepository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    if (action is BootstrapAction) {
      _handleLogiPageFeatureFlip(store);
    }
    final userId = store.state.userId();
    if (userId == null) return;
    if (action is LoginSuccessAction) {
      if (action.user.loginMode.isPe()) {
        _handleMonSuiviDemarchesKoMessageFeatureFlip(store, action.user.id);
      } else if (action.user.loginMode.isMiLo()) {
        _handleAccueilZenithMessageFeatureFlip(store, action.user.id);
      }
    }
  }

  Future<void> _handleMonSuiviDemarchesKoMessageFeatureFlip(Store<AppState> store, String userId) async {
    final monSuiviDemarchesKoMessage = _remoteConfigRepository.monSuiviDemarchesKoMessage();
    if (monSuiviDemarchesKoMessage != null) {
      store.dispatch(FeatureFlipMonSuiviDemarchesKoMessageAction(monSuiviDemarchesKoMessage));
    }
  }

  Future<void> _handleLogiPageFeatureFlip(Store<AppState> store) async {
    final loginPageMessage = _remoteConfigRepository.loginPageMessage();
    if (loginPageMessage != null) {
      store.dispatch(FeatureFlipLoginPageMessageAction(loginPageMessage));
    }
  }

  Future<void> _handleAccueilZenithMessageFeatureFlip(Store<AppState> store, String userId) async {
    final accueilZenithMessage = _remoteConfigRepository.accueilZenithMessage();
    if (accueilZenithMessage != null) {
      store.dispatch(FeatureFlipAccueilZenithMessageAction(accueilZenithMessage));
    }
  }
}
