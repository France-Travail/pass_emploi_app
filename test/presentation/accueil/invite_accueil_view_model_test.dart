import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_tracking.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/models/onboarding.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/presentation/accueil/invite_accueil_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';

import '../../doubles/spies.dart';
import '../../dsl/app_state_dsl.dart';

void main() {
  test('incomplet mode shows questionnaire without plan section', () {
    final store = givenState()
        .loggedInUser(loginMode: LoginMode.INVITE)
        .withOnboardingQuestionnaire(finished: true)
        .withActionPlanEmpty()
        .withOnboardingSuccessState(Onboarding())
        .store();

    final viewModel = InviteAccueilViewModel.create(store);

    expect(viewModel.mode, InviteAccueilMode.incomplet);
    expect(viewModel.showQuestionnaireCard, isTrue);
    expect(viewModel.showPlanSection, isFalse);
    expect(viewModel.showExplorerTip, isTrue);
    expect(viewModel.showDiscoveryTile, isTrue);
    expect(viewModel.discoveryProgressPercent, 25);
    expect(viewModel.showConseillerCta, isFalse);
    expect(viewModel.shouldShowAllowNotifications, isTrue);
    expect(viewModel.displayState, DisplayState.CONTENT);
    expect(viewModel.planDisplayEvent, isNull);
  });

  test('incomplet mode shows plan section when a plan was restored from server', () {
    final plan = ActionPlan(
      id: 'plan-1',
      greeting: 'Salut',
      objectives: [
        ActionPlanObjective(
          id: 'obj-1',
          title: 'Découvrir des métiers',
          theme: 'DECOUVRIR_METIERS',
          actions: [
            ActionPlanAction(id: 'a-1', label: 'Je consulte des fiches métiers', kind: ActionPlanActionKind.link),
          ],
        ),
      ],
    );
    final store = givenState()
        .loggedInUser(loginMode: LoginMode.INVITE)
        .withOnboardingQuestionnaire(finished: true)
        .withActionPlanSuccess(plan)
        .store();

    final viewModel = InviteAccueilViewModel.create(store);

    expect(viewModel.mode, InviteAccueilMode.incomplet);
    expect(viewModel.showQuestionnaireCard, isTrue);
    expect(viewModel.showPlanSection, isTrue);
    expect(viewModel.showPlanEmptyState, isFalse);
    expect(viewModel.plan?.objectives.first.title, 'Découvrir des métiers');
    expect(viewModel.displayState, DisplayState.CONTENT);
  });

  test('partiel mode shows plan and questionnaire', () {
    final answers = const OnboardingQuestionnaireAnswers(
      situation: QuestionnaireSituation.lycee,
      objectifs: {QuestionnaireObjectif.emploi},
      prenom: 'Léa',
    );
    final plan = ActionPlan(
      id: 'plan-1',
      greeting: 'Salut',
      objectives: [
        ActionPlanObjective(
          id: 'obj-1',
          title: 'Trouver un emploi',
          theme: 'job',
          actions: [
            ActionPlanAction(id: 'a-1', label: 'Je cherche', kind: ActionPlanActionKind.advice),
          ],
        ),
      ],
    );
    final store = givenState()
        .loggedInUser(loginMode: LoginMode.INVITE)
        .withOnboardingQuestionnaire(finished: true, answers: answers)
        .withActionPlanSuccess(plan)
        .store();

    final viewModel = InviteAccueilViewModel.create(store);

    expect(viewModel.mode, InviteAccueilMode.partiel);
    expect(viewModel.showQuestionnaireCard, isTrue);
    expect(viewModel.showPlanSection, isTrue);
    expect(viewModel.plan?.objectives.first.title, 'Trouver un emploi');
    expect(
      viewModel.planDisplayEvent,
      ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanDisplayedAction, value: 1),
    );
  });

  test('complet mode do not shows modifier and conseiller CTA because not implemented yet', () {
    final answers = OnboardingQuestionnaireAnswers(
      prenom: 'Léa',
      dateNaissance: DateTime(2005, 5, 5),
      habitation: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
      situation: QuestionnaireSituation.lycee,
      objectifs: {QuestionnaireObjectif.emploi},
      domaineInconnu: true,
      villeRecherche: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
      freins: {QuestionnaireFrein.rienNeMeBloque},
    );
    final store = givenState()
        .loggedInUser(loginMode: LoginMode.INVITE)
        .withOnboardingQuestionnaire(finished: true, answers: answers)
        .withActionPlanSuccess(
          ActionPlan(
            id: 'plan-1',
            greeting: 'Salut',
            objectives: [
              ActionPlanObjective(
                id: 'obj-1',
                title: 'Trouver un emploi',
                theme: 'job',
                actions: [
                  ActionPlanAction(id: 'a-1', label: 'Je cherche', kind: ActionPlanActionKind.advice),
                ],
              ),
            ],
          ),
        )
        .store();

    final viewModel = InviteAccueilViewModel.create(store);

    expect(viewModel.mode, InviteAccueilMode.complet);
    expect(viewModel.showQuestionnaireCard, isFalse);
    expect(viewModel.showModifierButton, isTrue);
    expect(viewModel.showConseillerCta, isFalse);
    expect(viewModel.showPlanEmptyState, isFalse);
  });

  test('complet mode hides conseiller CTA for a jeune of the pilot region, who already has one', () {
    final answers = OnboardingQuestionnaireAnswers(
      prenom: 'Léa',
      dateNaissance: DateTime(2005, 5, 5),
      habitation: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
      situation: QuestionnaireSituation.lycee,
      objectifs: {QuestionnaireObjectif.emploi},
      domaineInconnu: true,
      villeRecherche: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
      freins: {QuestionnaireFrein.rienNeMeBloque},
    );
    final store = givenState()
        .loggedInMiloUser()
        .withPlanActionFonctionnalite()
        .withOnboardingQuestionnaire(finished: true, answers: answers)
        .withActionPlanSuccess(
          ActionPlan(
            id: 'plan-1',
            greeting: 'Salut',
            objectives: [
              ActionPlanObjective(
                id: 'obj-1',
                title: 'Trouver un emploi',
                theme: 'job',
                actions: [
                  ActionPlanAction(id: 'a-1', label: 'Je cherche', kind: ActionPlanActionKind.advice),
                ],
              ),
            ],
          ),
        )
        .store();

    final viewModel = InviteAccueilViewModel.create(store);

    expect(viewModel.mode, InviteAccueilMode.complet);
    expect(viewModel.showConseillerCta, isFalse);
    expect(viewModel.showModifierButton, isTrue);
  });

  test('complet with empty objectives shows empty state with modifier only', () {
    final answers = OnboardingQuestionnaireAnswers(
      prenom: 'Léa',
      dateNaissance: DateTime(2005, 5, 5),
      habitation: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
      situation: QuestionnaireSituation.lycee,
      objectifs: {QuestionnaireObjectif.emploi},
      domaineInconnu: true,
      villeRecherche: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
      freins: {QuestionnaireFrein.rienNeMeBloque},
    );
    final store = givenState()
        .loggedInUser(loginMode: LoginMode.INVITE)
        .withOnboardingQuestionnaire(finished: true, answers: answers)
        .withActionPlanSuccess(
          const ActionPlan(id: 'plan-1', greeting: 'Salut', objectives: []),
        )
        .store();

    final viewModel = InviteAccueilViewModel.create(store);

    expect(viewModel.showPlanEmptyState, isTrue);
    expect(viewModel.planEmptyKind, InvitePlanEmptyKind.empty);
    expect(viewModel.planDisplayEvent, ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanEmptyAction));
    expect(viewModel.showRetry, isFalse);
    expect(viewModel.showModifierButton, isTrue);
    expect(viewModel.displayState, DisplayState.CONTENT);
  });

  test('partiel with action plan failure shows failure empty state with retry only', () {
    final answers = const OnboardingQuestionnaireAnswers(
      situation: QuestionnaireSituation.lycee,
      objectifs: {QuestionnaireObjectif.emploi},
      prenom: 'Léa',
    );
    final store = givenState()
        .loggedInUser(loginMode: LoginMode.INVITE)
        .withOnboardingQuestionnaire(finished: true, answers: answers)
        .copyWith(actionPlanState: ActionPlanFailureState())
        .store();

    final viewModel = InviteAccueilViewModel.create(store);

    expect(viewModel.showPlanEmptyState, isTrue);
    expect(viewModel.planEmptyKind, InvitePlanEmptyKind.failure);
    expect(viewModel.planDisplayEvent, ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanFailureAction));
    expect(viewModel.showRetry, isTrue);
    expect(viewModel.showModifierButton, isFalse);
    expect(viewModel.displayState, DisplayState.CONTENT);
  });

  test('complet with action plan failure shows retry only', () {
    final answers = OnboardingQuestionnaireAnswers(
      prenom: 'Léa',
      dateNaissance: DateTime(2005, 5, 5),
      habitation: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
      situation: QuestionnaireSituation.lycee,
      objectifs: {QuestionnaireObjectif.emploi},
      domaineInconnu: true,
      villeRecherche: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
      freins: {QuestionnaireFrein.rienNeMeBloque},
    );
    final store = givenState()
        .loggedInUser(loginMode: LoginMode.INVITE)
        .withOnboardingQuestionnaire(finished: true, answers: answers)
        .copyWith(actionPlanState: ActionPlanFailureState())
        .store();

    final viewModel = InviteAccueilViewModel.create(store);

    expect(viewModel.showPlanEmptyState, isTrue);
    expect(viewModel.planEmptyKind, InvitePlanEmptyKind.failure);
    expect(viewModel.showRetry, isTrue);
    expect(viewModel.showModifierButton, isFalse);
  });

  test('for a jeune accompagné whose plan cannot be loaded, shows loading failure with retry even without answers', () {
    final store = givenState()
        .loggedInMiloUser()
        .withOnboardingQuestionnaire(finished: true)
        .copyWith(actionPlanState: ActionPlanFailureState())
        .store();

    final viewModel = InviteAccueilViewModel.create(store);

    expect(viewModel.mode, InviteAccueilMode.incomplet);
    expect(viewModel.showPlanSection, isTrue);
    expect(viewModel.showPlanEmptyState, isTrue);
    expect(viewModel.planEmptyKind, InvitePlanEmptyKind.loadingFailure);
    expect(viewModel.showRetry, isTrue);
    expect(viewModel.showModifierButton, isFalse);
  });

  test('for a jeune accompagné whose plan could not be fetched at launch, shows loading failure without questionnaire', () {
    final store = givenState().loggedInMiloUser().copyWith(actionPlanState: ActionPlanFailureState()).store();

    final viewModel = InviteAccueilViewModel.create(store);

    expect(viewModel.showPlanSection, isTrue);
    expect(viewModel.planEmptyKind, InvitePlanEmptyKind.loadingFailure);
    expect(viewModel.showRetry, isTrue);
    expect(viewModel.showQuestionnaireCard, isFalse);
    expect(viewModel.showExplorerTip, isFalse);
  });

  test('for a jeune accompagné, retry fetches the plan from server again', () {
    final store = StoreSpy.withState(
      givenState().loggedInMiloUser().withOnboardingQuestionnaire(finished: true).copyWith(
            actionPlanState: ActionPlanFailureState(),
          ),
    );

    InviteAccueilViewModel.create(store).retry();

    expect(store.dispatchedAction, isA<OnboardingQuestionnaireRequestAction>());
  });

  test('for an invite, retry generates the plan again', () {
    final answers = const OnboardingQuestionnaireAnswers(
      situation: QuestionnaireSituation.lycee,
      objectifs: {QuestionnaireObjectif.emploi},
    );
    final store = StoreSpy.withState(
      givenState()
          .loggedInUser(loginMode: LoginMode.INVITE)
          .withOnboardingQuestionnaire(finished: true, answers: answers)
          .copyWith(actionPlanState: ActionPlanFailureState()),
    );

    InviteAccueilViewModel.create(store).retry();

    expect(store.dispatchedAction, isA<ActionPlanGenerateAction>());
  });

  test('discovery tile hidden when onboarding is dismissed', () {
    final store = givenState()
        .loggedInUser(loginMode: LoginMode.INVITE)
        .withOnboardingQuestionnaire(finished: true)
        .withActionPlanEmpty()
        .withOnboardingSuccessState(Onboarding(showOnboarding: false))
        .store();

    final viewModel = InviteAccueilViewModel.create(store);

    expect(viewModel.showDiscoveryTile, isFalse);
  });

  test('shouldShowAllowNotifications is false when already dismissed', () {
    final store = givenState()
        .loggedInUser(loginMode: LoginMode.INVITE)
        .withOnboardingQuestionnaire(finished: true)
        .withActionPlanEmpty()
        .withOnboardingSuccessState(Onboarding(showNotificationsOnboarding: false))
        .store();

    final viewModel = InviteAccueilViewModel.create(store);

    expect(viewModel.shouldShowAllowNotifications, isFalse);
  });
}
