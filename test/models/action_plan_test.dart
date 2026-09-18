import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';

void main() {
  group('ActionPlan.keepActionsFrom', () {
    test(
      'keeps previous actions when the objective theme is still present',
      () {
        final previous = _plan(
          objectives: [
            _objectiveX(
              actions: [_actionA.copyWith(done: true), _actionB],
            ),
          ],
        );
        final generated = _plan(
          objectives: [
            _objectiveX(
              id: 'objective-x-new',
              title: 'X updated',
              actions: [_actionA, _actionB, _actionE],
            ),
          ],
        );

        final merged = generated.keepActionsFrom(previous);

        expect(merged.objectives.single.id, 'objective-x-new');
        expect(merged.objectives.single.title, 'X updated');
        expect(merged.findAction('a')?.done, isTrue);
        expect(merged.findAction('b')?.done, isFalse);
        expect(merged.findAction('e'), isNull);
      },
    );

    test('does not keep actions when only the API id matches', () {
      final previous = _plan(
        objectives: [
          _objectiveX(actions: [_actionA.copyWith(done: true), _actionB]),
        ],
      );
      final generated = _plan(
        objectives: [
          _objectiveY(id: 'objective-x'),
        ],
      );

      final merged = generated.keepActionsFrom(previous);

      expect(merged.findAction('a'), isNull);
      expect(merged.findAction('c')?.done, isFalse);
      expect(merged.findAction('d')?.done, isFalse);
      expect(merged.findAction('e')?.done, isFalse);
    });

    test('uses generated actions when the objective is new', () {
      final previous = _plan(objectives: [_objectiveX()]);
      final generated = _plan(objectives: [_objectiveX(), _objectiveY()]);

      final merged = generated.keepActionsFrom(previous);

      expect(merged.findAction('a')?.done, isFalse);
      expect(merged.findAction('c')?.done, isFalse);
      expect(merged.findAction('d')?.done, isFalse);
      expect(merged.findAction('e')?.done, isFalse);
    });

    test('resets actions when an objective is dropped then selected again', () {
      final previous = _plan(
        objectives: [
          _objectiveX(actions: [_actionA.copyWith(done: true)]),
        ],
      );
      final generated = _plan(objectives: [_objectiveX(), _objectiveY()]);

      final merged = generated.keepActionsFrom(previous);

      expect(merged.findAction('a')?.done, isTrue);
      expect(merged.findAction('c')?.done, isFalse);
      expect(merged.findAction('d')?.done, isFalse);
      expect(merged.findAction('e')?.done, isFalse);
    });

    test('keeps an emptied objective so it is not treated as new', () {
      final previous = _plan(
        objectives: [
          _objectiveY(actions: const []),
        ],
      );
      final generated = _plan(objectives: [_objectiveY()]);

      final merged = generated.keepActionsFrom(previous);

      expect(merged.objectives.single.id, 'objective-y');
      expect(merged.objectives.single.actions, isEmpty);
    });
  });

  group('ActionPlan.applyDone', () {
    test('restores checked actions even when the objective is new', () {
      final plan = _plan(objectives: [_objectiveY()]);

      final next = plan.applyDone({'c', 'e'});

      expect(next.findAction('c')?.done, isTrue);
      expect(next.findAction('d')?.done, isFalse);
      expect(next.findAction('e')?.done, isTrue);
    });

    test('unchecks actions that are no longer in the persisted set', () {
      final plan = _plan(
        objectives: [
          _objectiveX(actions: [_actionA.copyWith(done: true), _actionB]),
        ],
      );

      final next = plan.applyDone(const {});

      expect(next.findAction('a')?.done, isFalse);
      expect(next.findAction('b')?.done, isFalse);
    });
  });

  group('ActionPlan.deleteAction', () {
    test('keeps the objective when the last action is deleted', () {
      final plan = _plan(
        objectives: [
          _objectiveX(actions: [_actionA]),
        ],
      );

      final next = plan.deleteAction('a');

      expect(next.objectives, hasLength(1));
      expect(next.objectives.single.actions, isEmpty);
    });
  });

  group('ActionPlan.withoutEmptyObjectives', () {
    test('hides objectives with no remaining actions', () {
      final plan = _plan(
        objectives: [
          _objectiveX(),
          _objectiveY(actions: const []),
        ],
      );

      expect(
        plan.withoutEmptyObjectives().objectives.map(
          (objective) => objective.id,
        ),
        ['objective-x'],
      );
    });
  });

  group('ActionPlan.applyProgress', () {
    test(
      'applies checked and deleted actions without dropping empty objectives',
      () {
        final progress = ActionPlanProgress(
          byObjectiveId: {
            'objective-x': const ActionPlanObjectiveProgress(
              doneActionIds: {'a'},
            ),
            'objective-y': const ActionPlanObjectiveProgress(
              deletedActionIds: {'c', 'd', 'e'},
            ),
          },
        );

        final nextPlan = _plan(
          objectives: [_objectiveX(), _objectiveY()],
        ).applyProgress(progress);

        expect(nextPlan.findAction('a')?.done, isTrue);
        expect(nextPlan.findAction('b')?.done, isFalse);
        expect(
          nextPlan.objectives
              .firstWhere((objective) => objective.id == 'objective-y')
              .actions,
          isEmpty,
        );
      },
    );
  });

  group('ActionPlanProgress', () {
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

ActionPlanObjective _objectiveX({
  String id = 'objective-x',
  String title = 'X',
  List<ActionPlanAction>? actions,
}) {
  return ActionPlanObjective(
    id: id,
    title: title,
    theme: 'x',
    actions: actions ?? const [_actionA, _actionB],
  );
}

ActionPlanObjective _objectiveY({
  String id = 'objective-y',
  List<ActionPlanAction>? actions,
}) {
  return ActionPlanObjective(
    id: id,
    title: 'Y',
    theme: 'y',
    actions: actions ?? const [_actionC, _actionD, _actionE],
  );
}

ActionPlan _plan({required List<ActionPlanObjective> objectives}) {
  return ActionPlan(id: 'plan', greeting: 'Salut', objectives: objectives);
}
