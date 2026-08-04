import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_actions.dart';
import 'package:pass_emploi_app/features/onboarding_questionnaire/onboarding_questionnaire_state.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/models/login_mode.dart';
import 'package:pass_emploi_app/redux/app_state.dart';

import '../../doubles/fixtures.dart';
import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../utils/test_setup.dart';

void main() {
  late MockOnboardingQuestionnaireRepository repository;
  late MockActionPlanRepository actionPlanRepository;

  setUpAll(() {
    registerFallbackValue(const OnboardingQuestionnaireAnswers());
  });

  setUp(() {
    repository = MockOnboardingQuestionnaireRepository();
    actionPlanRepository = MockActionPlanRepository();
  });

  test('after invite login, loads finished flag and answers', () async {
    when(() => repository.getAnswers()).thenAnswer(
      (_) async => const OnboardingQuestionnaireAnswers(prenom: 'Léa'),
    );
    when(() => repository.isFinished()).thenAnswer((_) async => true);

    final factory = TestStoreFactory()
      ..onboardingQuestionnaireRepository = repository
      ..actionPlanRepository = actionPlanRepository;
    final store = factory.initializeReduxStore(initialState: AppState.initialState());
    final success = store.onChange.firstWhere((s) => s.onboardingQuestionnaireState is OnboardingQuestionnaireSuccessState);

    store.dispatch(LoginSuccessAction(mockUser(id: 'invite-id', loginMode: LoginMode.INVITE)));

    final state = await success;
    final questionnaireState = state.onboardingQuestionnaireState as OnboardingQuestionnaireSuccessState;
    expect(questionnaireState.finished, isTrue);
    expect(questionnaireState.answers.prenom, 'Léa');
  });

  test('complete without enough answers empties plan and persists finished flag', () async {
    when(() => repository.saveAnswers(any())).thenAnswer((_) async {});
    when(() => repository.setFinished(true)).thenAnswer((_) async {});

    final factory = TestStoreFactory()
      ..onboardingQuestionnaireRepository = repository
      ..actionPlanRepository = actionPlanRepository;
    final store = factory.initializeReduxStore(
      initialState: givenState().loggedInUser(loginMode: LoginMode.INVITE),
    );
    final finished = store.onChange.firstWhere(
      (s) =>
          s.actionPlanState is ActionPlanEmptyState &&
          s.onboardingQuestionnaireState is OnboardingQuestionnaireSuccessState &&
          (s.onboardingQuestionnaireState as OnboardingQuestionnaireSuccessState).finished,
    );

    store.dispatch(OnboardingQuestionnaireCompleteAction(const OnboardingQuestionnaireAnswers()));

    final state = await finished;
    expect(state.actionPlanState, isA<ActionPlanEmptyState>());
    expect((state.onboardingQuestionnaireState as OnboardingQuestionnaireSuccessState).finished, isTrue);
    verify(() => repository.saveAnswers(any())).called(1);
    await untilCalled(() => repository.setFinished(true));
    verify(() => repository.setFinished(true)).called(1);
    verifyNever(() => actionPlanRepository.generate(any(), any()));
  });

  test('complete with enough answers generates plan and persists finished flag', () async {
    final answers = const OnboardingQuestionnaireAnswers(
      situation: QuestionnaireSituation.lycee,
      objectifs: {QuestionnaireObjectif.emploi},
    );
    final plan = const ActionPlan(id: 'p1', greeting: 'Salut', objectives: []);
    when(() => repository.saveAnswers(any())).thenAnswer((_) async {});
    when(() => repository.setFinished(true)).thenAnswer((_) async {});
    when(() => actionPlanRepository.generate(any(), any())).thenAnswer((_) async => plan);

    final factory = TestStoreFactory()
      ..onboardingQuestionnaireRepository = repository
      ..actionPlanRepository = actionPlanRepository;
    final store = factory.initializeReduxStore(
      initialState: givenState().loggedInUser(loginMode: LoginMode.INVITE),
    );
    final generated = store.onChange.firstWhere((s) => s.actionPlanState is ActionPlanSuccessState);

    store.dispatch(OnboardingQuestionnaireCompleteAction(answers));

    final state = await generated;
    expect((state.actionPlanState as ActionPlanSuccessState).plan.id, 'p1');
    final questionnaireState = state.onboardingQuestionnaireState;
    if (questionnaireState is OnboardingQuestionnaireSuccessState) {
      expect(questionnaireState.finished, isFalse);
    }
    verify(() => repository.saveAnswers(answers)).called(1);
    await untilCalled(() => repository.setFinished(true));
    verify(() => repository.setFinished(true)).called(1);
    verify(() => actionPlanRepository.generate(any(), answers)).called(1);
  });

  test('finish action marks questionnaire as finished in state', () async {
    final answers = const OnboardingQuestionnaireAnswers(prenom: 'Léa');
    final factory = TestStoreFactory()
      ..onboardingQuestionnaireRepository = repository
      ..actionPlanRepository = actionPlanRepository;
    final store = factory.initializeReduxStore(
      initialState: givenState()
          .loggedInUser(loginMode: LoginMode.INVITE)
          .copyWith(
            onboardingQuestionnaireState: OnboardingQuestionnaireSuccessState(
              finished: false,
              answers: answers,
            ),
          ),
    );
    final finished = store.onChange.firstWhere(
      (s) =>
          s.onboardingQuestionnaireState is OnboardingQuestionnaireSuccessState &&
          (s.onboardingQuestionnaireState as OnboardingQuestionnaireSuccessState).finished,
    );

    store.dispatch(OnboardingQuestionnaireFinishAction(answers));

    final state = await finished;
    expect((state.onboardingQuestionnaireState as OnboardingQuestionnaireSuccessState).answers, answers);
  });

  test('answers updated action persists via repository', () async {
    when(() => repository.saveAnswers(any())).thenAnswer((_) async {});

    final factory = TestStoreFactory()
      ..onboardingQuestionnaireRepository = repository
      ..actionPlanRepository = actionPlanRepository;
    final store = factory.initializeReduxStore(
      initialState: givenState()
          .loggedInUser(loginMode: LoginMode.INVITE)
          .copyWith(
            onboardingQuestionnaireState: OnboardingQuestionnaireSuccessState(
              finished: false,
              answers: const OnboardingQuestionnaireAnswers(),
            ),
          ),
    );

    final updated = const OnboardingQuestionnaireAnswers(prenom: 'Léa');
    final success = store.onChange.firstWhere(
      (s) =>
          s.onboardingQuestionnaireState is OnboardingQuestionnaireSuccessState &&
          (s.onboardingQuestionnaireState as OnboardingQuestionnaireSuccessState).answers.prenom == 'Léa',
    );

    store.dispatch(OnboardingQuestionnaireAnswersUpdatedAction(updated));

    final state = await success;
    expect((state.onboardingQuestionnaireState as OnboardingQuestionnaireSuccessState).answers.prenom, 'Léa');
    verify(() => repository.saveAnswers(updated)).called(1);
  });
}
