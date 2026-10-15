import 'package:pass_emploi_app/auth/auth_token_response.dart';
import 'package:pass_emploi_app/auth/authenticator.dart';
import 'package:pass_emploi_app/features/bootstrap/bootstrap_action.dart';
import 'package:pass_emploi_app/features/reprise_compte_invite/reprise_compte_invite_actions.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_repository.dart';
import 'package:pass_emploi_app/repositories/onboarding_questionnaire_repository.dart';
import 'package:pass_emploi_app/repositories/reprise_compte_invite_repository.dart';
import 'package:pass_emploi_app/repositories/tutorial_repository.dart';
import 'package:redux/redux.dart';

class RepriseCompteInviteMiddleware extends MiddlewareClass<AppState> {
  final RepriseCompteInviteRepository _repository;
  final Authenticator _authenticator;
  final ActionPlanRepository _actionPlanRepository;
  final OnboardingQuestionnaireRepository _onboardingQuestionnaireRepository;
  final TutorialRepository _tutorialRepository;

  RepriseCompteInviteMiddleware(
    this._repository,
    this._authenticator,
    this._actionPlanRepository,
    this._onboardingQuestionnaireRepository,
    this._tutorialRepository,
  );

  @override
  void call(Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    if (action is RepriseCompteInviteRequestAction && store.state.isInviteLoginMode()) {
      await _reprendre(store, action.mode);
    }
  }

  Future<void> _reprendre(Store<AppState> store, LoginMode mode) async {
    store.dispatch(RepriseCompteInviteLoadingAction());

    final response = await _authenticator.loginWithoutSaving(mode.toAuthenticationMode());
    switch (response) {
      case SuccessAuthenticatorResponse(:final tokens):
        await _rattacherInvite(store, tokens!);
      case CancelledAuthenticatorResponse():
        store.dispatch(RepriseCompteInviteResetAction());
      case WrongDeviceClockAuthenticatorResponse():
        store.dispatch(RepriseCompteInviteWrongDeviceClockAction());
      case FailureAuthenticatorResponse(:final message):
        store.dispatch(RepriseCompteInviteFailureAction(message));
    }
  }

  Future<void> _rattacherInvite(Store<AppState> store, AuthTokenResponse tokens) async {
    final idInvite = store.state.userId();
    if (idInvite == null) {
      store.dispatch(RepriseCompteInviteFailureAction(_echecReprise));
      return;
    }

    final planLocal = await _actionPlanRepository.getStoredPlan();
    final succeeded = await _repository.reprendre(
      idInvite: idInvite,
      jetonConnecte: tokens.accessToken,
      plan: planLocal?.toApiReprise(),
    );

    if (!succeeded) {
      store.dispatch(RepriseCompteInviteFailureAction(_echecReprise));
      return;
    }

    await _authenticator.saveTokens(tokens);
    await _oublierCompteInvite();
    store.dispatch(RepriseCompteInviteSuccessAction());
    store.dispatch(BootstrapAction());
  }

  Future<void> _oublierCompteInvite() async {
    await _onboardingQuestionnaireRepository.clear();
    await _actionPlanRepository.clear();
    await _tutorialRepository.setTutorialRead();
    await _tutorialRepository.setPlanActionTutorialRead();
  }
}

const _echecReprise = 'Reprise du compte invité échouée : connexion abandonnée';
