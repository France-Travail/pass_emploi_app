import 'package:pass_emploi_app/features/fonctionnalites/fonctionnalites_actions.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/features/login/login_state.dart';
import 'package:pass_emploi_app/features/tutorial/tutorial_actions.dart';
import 'package:pass_emploi_app/features/tutorial/tutorial_state.dart';
import 'package:pass_emploi_app/models/accompagnement.dart';
import 'package:pass_emploi_app/models/brand.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/tutorial/tutorial_page.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/tutorial_repository.dart';
import 'package:redux/redux.dart';

class TutorialMiddleware extends MiddlewareClass<AppState> {
  final TutorialRepository _repository;

  TutorialMiddleware(this._repository);

  var _waitingForFonctionnalites = false;

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    final shownKind = store.state.tutorialState is ShowTutorialState
        ? (store.state.tutorialState as ShowTutorialState).kind
        : null;
    next(action);
    if (action is LoginSuccessAction) {
      if (_isPlanActionTutorialCandidate(store.state)) {
        _waitingForFonctionnalites = true;
      } else {
        _waitingForFonctionnalites = false;
        await _showGenericTutorial(store);
      }
    }
    if ((action is FonctionnalitesSuccessAction ||
            action is FonctionnalitesFailureAction) &&
        _waitingForFonctionnalites) {
      _waitingForFonctionnalites = false;
      if (store.state.loginState is LoginSuccessState) {
        await _showPlanActionOrGenericTutorial(store);
      }
    }
    if (action is TutorialDoneAction) {
      try {
        if (shownKind == TutorialKind.planAction) {
          await _repository.setPlanActionTutorialRead();
        } else {
          await _repository.setTutorialRead();
        }
      } catch (_) {}
    }
  }

  Future<void> _showPlanActionOrGenericTutorial(Store<AppState> store) async {
    if (store.state.hasPlanAction() &&
        await _repository.shouldShowPlanActionTutorial()) {
      final pages = _repository.getPlanActionTutorial();
      if (pages.isNotEmpty) {
        store.dispatch(
          TutorialSuccessAction(pages, kind: TutorialKind.planAction),
        );
      }
      return;
    }
    await _showGenericTutorial(store);
  }

  Future<void> _showGenericTutorial(Store<AppState> store) async {
    final loginState = store.state.loginState;
    if (loginState is! LoginSuccessState ||
        !await _repository.shouldShowTutorial()) {
      return;
    }
    final loginMode = loginState.user.loginMode;
    List<TutorialPage> pages = [];
    if (_requestMiloTutorial(loginMode)) pages = _repository.getMiloTutorial();
    if (_requestPoleEmploiTutorial(loginMode)) {
      pages = _repository.getPoleEmploiTutorial();
    }
    if (pages.isNotEmpty) store.dispatch(TutorialSuccessAction(pages));
  }

  bool _isPlanActionTutorialCandidate(AppState state) {
    if (!Brand.isCej()) return false;
    final user = state.user();
    if (user == null) return false;
    return switch (user.loginMode) {
      LoginMode.MILO => true,
      LoginMode.POLE_EMPLOI => user.accompagnement == Accompagnement.cej,
      _ => false,
    };
  }

  bool _requestPoleEmploiTutorial(LoginMode loginMode) {
    return [LoginMode.POLE_EMPLOI, LoginMode.DEMO_PE].contains(loginMode) ||
        (loginMode.isInvite() && Brand.isPassEmploi());
  }

  bool _requestMiloTutorial(LoginMode loginMode) {
    return [LoginMode.MILO, LoginMode.DEMO_MILO].contains(loginMode) ||
        (loginMode.isInvite() && Brand.isCej());
  }
}
