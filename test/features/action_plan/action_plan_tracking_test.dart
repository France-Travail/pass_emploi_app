import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_tracking.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';

void main() {
  group('actionPlanChangeEvents', () {
    test('checking an action sends "Démarche cochée"', () {
      final before = _plan([
        _objective('o1', 'EMPLOI', [_action('a1'), _action('a2')]),
      ]);
      final after = before.toggleDone('a1');

      expect(actionPlanChangeEvents(before: before, after: after, actionId: 'a1', deleted: false), [
        ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanActionDoneAction, name: 'label a1'),
      ]);
    });

    test('unchecking an action sends "Démarche décochée"', () {
      final before = _plan([
        _objective('o1', 'EMPLOI', [_action('a1', done: true), _action('a2')]),
      ]);
      final after = before.toggleDone('a1');

      expect(actionPlanChangeEvents(before: before, after: after, actionId: 'a1', deleted: false), [
        ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanActionUndoneAction, name: 'label a1'),
      ]);
    });

    test('deleting an action sends "Démarche supprimée" with its label', () {
      final before = _plan([
        _objective('o1', 'EMPLOI', [_action('a1'), _action('a2')]),
      ]);
      final after = before.deleteAction('a1');

      expect(actionPlanChangeEvents(before: before, after: after, actionId: 'a1', deleted: true), [
        ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanActionDeletedAction, name: 'label a1'),
      ]);
    });

    test('checking the last action of an objective sends "Objectif complété"', () {
      final before = _plan([
        _objective('o1', 'EMPLOI', [
          _action('a1', done: true),
          _action('a2', done: true),
          _action('a3'),
          _action('a4', done: true),
        ]),
        _objective('o2', 'FORMER', [_action('b1')]),
      ]);
      final after = before.toggleDone('a3');

      expect(actionPlanChangeEvents(before: before, after: after, actionId: 'a3', deleted: false), [
        ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanActionDoneAction, name: 'label a3'),
        ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanObjectiveCompletedAction, name: 'EMPLOI', value: 4),
      ]);
    });

    test('objective completed after deletions carries the remaining actions count', () {
      final before = _plan([
        _objective('o1', 'EMPLOI', [_action('a1', done: true), _action('a2')]),
        _objective('o2', 'FORMER', [_action('b1')]),
      ]);
      final after = before.toggleDone('a2');

      expect(
        actionPlanChangeEvents(before: before, after: after, actionId: 'a2', deleted: false),
        contains(
          ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanObjectiveCompletedAction, name: 'EMPLOI', value: 2),
        ),
      );
    });

    test('completing the last objective also sends "Plan complété"', () {
      final before = _plan([
        _objective('o1', 'EMPLOI', [_action('a1', done: true)]),
        _objective('o2', 'FORMER', [_action('b1', done: true)]),
        _objective('o3', 'ORIENTER', [_action('c1')]),
      ]);
      final after = before.toggleDone('c1');

      expect(actionPlanChangeEvents(before: before, after: after, actionId: 'c1', deleted: false), [
        ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanActionDoneAction, name: 'label c1'),
        ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanObjectiveCompletedAction, name: 'ORIENTER', value: 1),
        ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanCompletedAction, value: 3),
      ]);
    });

    test('an already complete objective is not sent again', () {
      final before = _plan([
        _objective('o1', 'EMPLOI', [_action('a1', done: true)]),
        _objective('o2', 'FORMER', [_action('b1'), _action('b2')]),
      ]);
      final after = before.toggleDone('b1');

      expect(actionPlanChangeEvents(before: before, after: after, actionId: 'b1', deleted: false), [
        ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanActionDoneAction, name: 'label b1'),
      ]);
    });
  });
}

ActionPlanAction _action(String id, {bool done = false}) {
  return ActionPlanAction(id: id, label: 'label $id', kind: ActionPlanActionKind.advice, done: done);
}

ActionPlanObjective _objective(String id, String theme, List<ActionPlanAction> actions) {
  return ActionPlanObjective(id: id, title: 'title $id', theme: theme, actions: actions);
}

ActionPlan _plan(List<ActionPlanObjective> objectives) {
  return ActionPlan(id: 'plan', greeting: 'Salut', objectives: objectives);
}
