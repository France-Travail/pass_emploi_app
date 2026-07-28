import 'package:equatable/equatable.dart';

enum ActionPlanActionKind { link, app, advice }

class ActionPlanAction extends Equatable {
  final String id;
  final String label;
  final ActionPlanActionKind kind;
  final String? url;
  final String? deepLink;
  final String? serviceName;
  final String? serviceDescription;
  final bool done;

  const ActionPlanAction({
    required this.id,
    required this.label,
    required this.kind,
    this.url,
    this.deepLink,
    this.serviceName,
    this.serviceDescription,
    this.done = false,
  });

  ActionPlanAction copyWith({bool? done}) {
    return ActionPlanAction(
      id: id,
      label: label,
      kind: kind,
      url: url,
      deepLink: deepLink,
      serviceName: serviceName,
      serviceDescription: serviceDescription,
      done: done ?? this.done,
    );
  }

  factory ActionPlanAction.fromJson(Map<String, dynamic> json) {
    return ActionPlanAction(
      id: json['id'] as String,
      label: json['label'] as String,
      kind: ActionPlanActionKind.values.firstWhere(
        (e) => e.name == json['kind'],
        orElse: () => ActionPlanActionKind.advice,
      ),
      url: json['url'] as String?,
      deepLink: json['deepLink'] as String?,
      serviceName: json['serviceName'] as String?,
      serviceDescription: json['serviceDescription'] as String?,
      done: json['done'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'kind': kind.name,
        if (url != null) 'url': url,
        if (deepLink != null) 'deepLink': deepLink,
        if (serviceName != null) 'serviceName': serviceName,
        if (serviceDescription != null) 'serviceDescription': serviceDescription,
        'done': done,
      };

  @override
  List<Object?> get props => [id, label, kind, url, deepLink, serviceName, serviceDescription, done];
}

class ActionPlanObjective extends Equatable {
  final String id;
  final String title;
  final String theme;
  final List<ActionPlanAction> actions;

  const ActionPlanObjective({
    required this.id,
    required this.title,
    required this.theme,
    required this.actions,
  });

  int get doneCount => actions.where((a) => a.done).length;

  int get totalCount => actions.length;

  bool get isComplete => totalCount > 0 && doneCount == totalCount;

  ActionPlanObjective copyWith({List<ActionPlanAction>? actions}) {
    return ActionPlanObjective(
      id: id,
      title: title,
      theme: theme,
      actions: actions ?? this.actions,
    );
  }

  factory ActionPlanObjective.fromJson(Map<String, dynamic> json) {
    final actionsJson = json['actions'];
    return ActionPlanObjective(
      id: json['id'] as String,
      title: json['title'] as String,
      theme: json['theme'] as String? ?? '',
      actions: actionsJson is List
          ? actionsJson.whereType<Map<String, dynamic>>().map(ActionPlanAction.fromJson).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'theme': theme,
        'actions': actions.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, title, theme, actions];
}

class ActionPlan extends Equatable {
  final String id;
  final String greeting;
  final List<ActionPlanObjective> objectives;
  final DateTime? generatedAt;
  final String? generator;
  final String? model;

  const ActionPlan({
    required this.id,
    required this.greeting,
    required this.objectives,
    this.generatedAt,
    this.generator,
    this.model,
  });

  ActionPlan applyProgress({required Set<String> doneIds, required Set<String> deletedIds}) {
    return copyWith(
      objectives: objectives
          .map(
            (objective) => objective.copyWith(
              actions: objective.actions
                  .where((action) => !deletedIds.contains(action.id))
                  .map((action) => action.copyWith(done: doneIds.contains(action.id)))
                  .toList(),
            ),
          )
          .where((objective) => objective.actions.isNotEmpty)
          .toList(),
    );
  }

  ActionPlan toggleDone(String actionId) {
    return copyWith(
      objectives: objectives
          .map(
            (objective) => objective.copyWith(
              actions: objective.actions
                  .map((action) => action.id == actionId ? action.copyWith(done: !action.done) : action)
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  ActionPlan deleteAction(String actionId) {
    return copyWith(
      objectives: objectives
          .map(
            (objective) => objective.copyWith(
              actions: objective.actions.where((action) => action.id != actionId).toList(),
            ),
          )
          .where((objective) => objective.actions.isNotEmpty)
          .toList(),
    );
  }

  ActionPlanAction? findAction(String actionId) {
    for (final objective in objectives) {
      for (final action in objective.actions) {
        if (action.id == actionId) return action;
      }
    }
    return null;
  }

  ActionPlan copyWith({List<ActionPlanObjective>? objectives}) {
    return ActionPlan(
      id: id,
      greeting: greeting,
      objectives: objectives ?? this.objectives,
      generatedAt: generatedAt,
      generator: generator,
      model: model,
    );
  }

  factory ActionPlan.fromJson(Map<String, dynamic> json) {
    final objectivesJson = json['objectives'];
    return ActionPlan(
      id: json['id'] as String,
      greeting: json['greeting'] as String? ?? '',
      objectives: objectivesJson is List
          ? objectivesJson.whereType<Map<String, dynamic>>().map(ActionPlanObjective.fromJson).toList()
          : const [],
      generatedAt: json['generatedAt'] != null ? DateTime.tryParse(json['generatedAt'] as String) : null,
      generator: json['generator'] as String?,
      model: json['model'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'greeting': greeting,
        'objectives': objectives.map((e) => e.toJson()).toList(),
        if (generatedAt != null) 'generatedAt': generatedAt!.toIso8601String(),
        if (generator != null) 'generator': generator,
        if (model != null) 'model': model,
      };

  @override
  List<Object?> get props => [id, greeting, objectives, generatedAt, generator, model];
}

class ActionPlanProgress extends Equatable {
  final Set<String> doneActionIds;
  final Set<String> deletedActionIds;

  const ActionPlanProgress({
    this.doneActionIds = const {},
    this.deletedActionIds = const {},
  });

  ActionPlanProgress toggleDone(String actionId) {
    final next = Set<String>.of(doneActionIds);
    if (next.contains(actionId)) {
      next.remove(actionId);
    } else {
      next.add(actionId);
    }
    return ActionPlanProgress(doneActionIds: next, deletedActionIds: deletedActionIds);
  }

  ActionPlanProgress deleteAction(String actionId) {
    return ActionPlanProgress(
      doneActionIds: Set.of(doneActionIds)..remove(actionId),
      deletedActionIds: Set.of(deletedActionIds)..add(actionId),
    );
  }

  ActionPlanProgress retainForPlan(ActionPlan plan) {
    final validIds = plan.objectives.expand((o) => o.actions.map((a) => a.id)).toSet();
    return ActionPlanProgress(
      doneActionIds: doneActionIds.intersection(validIds),
      deletedActionIds: deletedActionIds.intersection(validIds),
    );
  }

  factory ActionPlanProgress.fromJson(Map<String, dynamic> json) {
    final done = json['doneActionIds'];
    final deleted = json['deletedActionIds'];
    return ActionPlanProgress(
      doneActionIds: done is List ? done.map((e) => e.toString()).toSet() : {},
      deletedActionIds: deleted is List ? deleted.map((e) => e.toString()).toSet() : {},
    );
  }

  Map<String, dynamic> toJson() => {
        'doneActionIds': doneActionIds.toList(),
        'deletedActionIds': deletedActionIds.toList(),
      };

  @override
  List<Object?> get props => [doneActionIds, deletedActionIds];
}
