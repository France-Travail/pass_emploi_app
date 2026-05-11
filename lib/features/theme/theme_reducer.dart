import 'package:pass_emploi_app/features/theme/theme_actions.dart';
import 'package:pass_emploi_app/features/theme/theme_state.dart';

ThemeState themeReducer(ThemeState current, dynamic action) {
  if (action is ThemeSuccessAction) return ThemeSuccessState(action.themeMode);
  return current;
}
