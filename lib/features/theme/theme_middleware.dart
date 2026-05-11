import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';
import 'package:pass_emploi_app/features/theme/theme_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/theme_repository.dart';
import 'package:redux/redux.dart';

class ThemeMiddleware extends MiddlewareClass<AppState> {
  final ThemeRepository _repository;

  ThemeMiddleware(this._repository);

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    if (action is BootstrapAction) {
      final themeMode = await _repository.getThemeMode();
      store.dispatch(ThemeSuccessAction(themeMode));
    } else if (action is ThemeSaveAction) {
      await _repository.setThemeMode(action.themeMode);
      store.dispatch(ThemeSuccessAction(action.themeMode));
    }
  }
}
