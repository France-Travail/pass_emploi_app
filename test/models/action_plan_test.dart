import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';

void main() {
  group('ActionPlanProgress', () {
    test(
      'keeps checked and deleted actions when the objective is still present',
      () {
        final progress = ActionPlanProgress(
          byObjectiveId: {
            'objective-x': const ActionPlanObjectiveProgress(
              doneActionIds: {'a', 'b'},
            ),
            'objective-y': const ActionPlanObjectiveProgress(
              deletedActionIds: {'c', 'd'},
            ),
          },
        );

        final retained = progress.retainForObjectives(
          _plan(
            objectives: [
              _objectiveX(),
              _objectiveY(actions: [_actionC, _actionD, _actionE]),
            ],
          ),
        );

        final nextPlan = _plan(
          objectives: [
            _objectiveX(),
            _objectiveY(actions: [_actionC, _actionD, _actionE]),
          ],
        ).applyProgress(retained);

        expect(nextPlan.findAction('a')?.done, isTrue);
        expect(nextPlan.findAction('b')?.done, isTrue);
        expect(nextPlan.findAction('c'), isNull);
        expect(nextPlan.findAction('d'), isNull);
        expect(nextPlan.findAction('e')?.done, isFalse);
      },
    );

    test(
      'keeps deleted actions hidden even if they are missing from this generation',
      () {
        final progress = ActionPlanProgress(
          byObjectiveId: {
            'objective-y': const ActionPlanObjectiveProgress(
              deletedActionIds: {'c', 'd'},
            ),
          },
        );

        final retained = progress.retainForObjectives(
          _plan(
            objectives: [
              _objectiveY(actions: [_actionE]),
            ],
          ),
        );
        expect(retained.forObjective('objective-y').deletedActionIds, {
          'c',
          'd',
        });

        final laterPlan = _plan(
          objectives: [_objectiveY()],
        ).applyProgress(retained);
        expect(laterPlan.findAction('c'), isNull);
        expect(laterPlan.findAction('d'), isNull);
        expect(laterPlan.findAction('e')?.done, isFalse);
      },
    );

    test(
      'resets checked and deleted actions when the objective is no longer selected',
      () {
        final progress = ActionPlanProgress(
          byObjectiveId: {
            'objective-x': const ActionPlanObjectiveProgress(
              doneActionIds: {'a'},
            ),
            'objective-y': const ActionPlanObjectiveProgress(
              deletedActionIds: {'c', 'd'},
            ),
          },
        );

        final withoutY = progress.retainForObjectives(
          _plan(objectives: [_objectiveX()]),
        );
        expect(withoutY.byObjectiveId.containsKey('objective-y'), isFalse);

        final withYAgain = withoutY.retainForObjectives(
          _plan(objectives: [_objectiveX(), _objectiveY()]),
        );
        final nextPlan = _plan(
          objectives: [_objectiveX(), _objectiveY()],
        ).applyProgress(withYAgain);

        expect(nextPlan.findAction('a')?.done, isTrue);
        expect(nextPlan.findAction('c')?.done, isFalse);
        expect(nextPlan.findAction('d')?.done, isFalse);
      },
    );

    test('migrates legacy flat progress onto the matching objectives', () {
      final legacy = ActionPlanProgress.fromJson({
        'doneActionIds': ['a'],
        'deletedActionIds': ['c'],
      });
      expect(legacy.hasLegacy, isTrue);

      final migrated = legacy.migrateLegacy(
        _plan(objectives: [_objectiveX(), _objectiveY()]),
      );
      expect(migrated.hasLegacy, isFalse);
      expect(migrated.forObjective('objective-x').doneActionIds, {'a'});
      expect(migrated.forObjective('objective-y').deletedActionIds, {'c'});
    });
  });
}

const _actionA = ActionPlanAction(
  id: 'a',
  label: 'A',
  kind: ActionPlanActionKind.advice,
);
const _actionB = ActionPlanAction(
  id: 'b',
  label: 'B',
  kind: ActionPlanActionKind.advice,
);
const _actionC = ActionPlanAction(
  id: 'c',
  label: 'C',
  kind: ActionPlanActionKind.advice,
);
const _actionD = ActionPlanAction(
  id: 'd',
  label: 'D',
  kind: ActionPlanActionKind.advice,
);
const _actionE = ActionPlanAction(
  id: 'e',
  label: 'E',
  kind: ActionPlanActionKind.advice,
);

ActionPlanObjective _objectiveX() {
  return const ActionPlanObjective(
    id: 'objective-x',
    title: 'X',
    theme: 'x',
    actions: [_actionA, _actionB],
  );
}

ActionPlanObjective _objectiveY({List<ActionPlanAction>? actions}) {
  return ActionPlanObjective(
    id: 'objective-y',
    title: 'Y',
    theme: 'y',
    actions: actions ?? const [_actionC, _actionD, _actionE],
  );
}

ActionPlan _plan({required List<ActionPlanObjective> objectives}) {
  return ActionPlan(id: 'plan', greeting: 'Salut', objectives: objectives);
}
