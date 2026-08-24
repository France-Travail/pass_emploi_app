import 'package:clock/clock.dart';
import 'package:pass_emploi_app/configuration/configuration.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/push_notification/register/register_push_notification_token_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/configuration_application_repository.dart';
import 'package:redux/redux.dart';

class PushNotificationRegisterTokenMiddleware
    extends MiddlewareClass<AppState> {
  static const Duration _refreshInterval = Duration(hours: 24);

  final ConfigurationApplicationRepository _repository;
  final Configuration _configuration;
  DateTime? _lastSuccessfulCallAt;

  PushNotificationRegisterTokenMiddleware(
    this._repository,
    this._configuration,
  );

  @override
  Future<void> call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    if (action is LoginSuccessAction) {
      await _configureApplication(action.user.id);
    } else if (action is ConfigureApplicationOnForegroundAction) {
      final userId = store.state.userId();
      if (userId != null && _shouldRefreshOnForeground()) {
        await _configureApplication(userId);
      }
    }
  }

  bool _shouldRefreshOnForeground() {
    final lastSuccessfulCallAt = _lastSuccessfulCallAt;
    if (lastSuccessfulCallAt == null) return true;
    return clock.now().difference(lastSuccessfulCallAt) >= _refreshInterval;
  }

  Future<void> _configureApplication(String userId) async {
    final success = await _repository.configureApplication(
      userId,
      _configuration.fuseauHoraire,
    );
    if (success) _lastSuccessfulCallAt = clock.now();
  }
}
