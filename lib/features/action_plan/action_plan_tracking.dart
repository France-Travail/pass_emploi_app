import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';

// Objectives are identified by their theme, actions by their label (from the référentiel, never user input).
class ActionPlanTrackingEvent extends Equatable {
  final String action;
  final String? name;
  final int? value;

  const ActionPlanTrackingEvent(this.action, {this.name, this.value});

  void send() {
    PassEmploiMatomoTracker.instance.trackEvent(
      eventCategory: AnalyticsEventNames.actionPlanCategory,
      action: action,
      eventName: name,
      eventValue: value,
    );
  }

  @override
  List<Object?> get props => [action, name, value];
}

List<ActionPlanTrackingEvent> actionPlanChangeEvents({
  required ActionPlan? before,
  required ActionPlan after,
  required String actionId,
  required bool deleted,
}) {
  final events = <ActionPlanTrackingEvent>[];

  if (deleted) {
    final label = before?.findAction(actionId)?.label;
    if (label != null) {
      events.add(ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanActionDeletedAction, name: label));
    }
  } else {
    final action = after.findAction(actionId);
    if (action != null) {
      events.add(
        ActionPlanTrackingEvent(
          action.done
              ? AnalyticsEventNames.actionPlanActionDoneAction
              : AnalyticsEventNames.actionPlanActionUndoneAction,
          name: action.label,
        ),
      );
    }
  }

  final wasComplete = {
    for (final objective in before?.objectives ?? const <ActionPlanObjective>[]) objective.id: objective.isComplete,
  };
  for (final objective in after.objectives) {
    if (objective.isComplete && wasComplete[objective.id] != true) {
      events.add(
        ActionPlanTrackingEvent(
          AnalyticsEventNames.actionPlanObjectiveCompletedAction,
          name: objective.theme,
          value: objective.totalCount,
        ),
      );
    }
  }

  if (_isComplete(after) && (before == null || !_isComplete(before))) {
    events.add(
      ActionPlanTrackingEvent(AnalyticsEventNames.actionPlanCompletedAction, value: after.objectives.length),
    );
  }

  return events;
}

bool _isComplete(ActionPlan plan) {
  final objectives = plan.objectives.where((objective) => objective.actions.isNotEmpty);
  return objectives.isNotEmpty && objectives.every((objective) => objective.isComplete);
}
