import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_state.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/login_mode.dart';

import '../../doubles/mocks.dart';
import '../../dsl/app_state_dsl.dart';
import '../../utils/test_setup.dart';

void main() {
  late MockActionPlanRepository repository;

  setUp(() => repository = MockActionPlanRepository());

  test('for an invite, request loads the plan stored on the device', () async {
    const plan = ActionPlan(id: 'p1', greeting: '', objectives: []);
    when(() => repository.getStoredPlan()).thenAnswer((_) async => plan);

    final store = (TestStoreFactory()..actionPlanRepository = repository).initializeReduxStore(
      initialState: givenState().loggedInUser(loginMode: LoginMode.INVITE),
    );
    final success = store.onChange.firstWhere((s) => s.actionPlanState is ActionPlanSuccessState);

    store.dispatch(ActionPlanRequestAction());

    expect((await success).actionPlanState, ActionPlanSuccessState(plan));
  });

  test('for a jeune accompagné, request keeps the plan synced with the server and never reads the stored one', () async {
    final store = (TestStoreFactory()..actionPlanRepository = repository).initializeReduxStore(
      initialState: givenState().loggedInMiloUser().copyWith(actionPlanState: ActionPlanFailureState()),
    );

    store.dispatch(ActionPlanRequestAction());
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(store.state.actionPlanState, isA<ActionPlanFailureState>());
    verifyNever(() => repository.getStoredPlan());
  });
}
