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

  factory ActionPlanAction.fromApiJson(Map<String, dynamic> json) {
    return ActionPlanAction(
      id: json['id'] as String,
      label: json['libelle'] as String,
      kind: switch (json['type'] as String?) {
        'LIEN' => ActionPlanActionKind.link,
        'NAVIGATION' => ActionPlanActionKind.app,
        'CONSEIL' => ActionPlanActionKind.advice,
        _ => ActionPlanActionKind.advice,
      },
      url: json['url'] as String?,
      deepLink: json['destination'] as String?,
      serviceName: json['nomService'] as String?,
      serviceDescription: json['descriptionService'] as String?,
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
  List<Object?> get props => [
    id,
    label,
    kind,
    url,
    deepLink,
    serviceName,
    serviceDescription,
    done,
  ];
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
          ? actionsJson
                .whereType<Map<String, dynamic>>()
                .map(ActionPlanAction.fromJson)
                .toList()
          : const [],
    );
  }

  factory ActionPlanObjective.fromApiJson(Map<String, dynamic> json) {
    final actionsJson = json['actions'];
    return ActionPlanObjective(
      id: json['id'] as String,
      title: json['titre'] as String,
      theme: json['theme'] as String? ?? '',
      actions: actionsJson is List
          ? actionsJson
                .whereType<Map<String, dynamic>>()
                .map(ActionPlanAction.fromApiJson)
                .toList()
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

  String? objectiveIdOf(String actionId) {
    for (final objective in objectives) {
      if (objective.actions.any((action) => action.id == actionId))
        return objective.id;
    }
    return null;
  }

  ActionPlan applyProgress(ActionPlanProgress progress) {
    return copyWith(
      objectives: objectives
          .map((objective) {
            final objectiveProgress = progress.forObjective(objective.id);
            return objective.copyWith(
              actions: objective.actions
                  .where(
                    (action) =>
                        !objectiveProgress.deletedActionIds.contains(action.id),
                  )
                  .map(
                    (action) => action.copyWith(
                      done: objectiveProgress.doneActionIds.contains(action.id),
                    ),
                  )
                  .toList(),
            );
          })
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
                  .map(
                    (action) => action.id == actionId
                        ? action.copyWith(done: !action.done)
                        : action,
                  )
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
              actions: objective.actions
                  .where((action) => action.id != actionId)
                  .toList(),
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
          ? objectivesJson
                .whereType<Map<String, dynamic>>()
                .map(ActionPlanObjective.fromJson)
                .toList()
          : const [],
      generatedAt: json['generatedAt'] != null
          ? DateTime.tryParse(json['generatedAt'] as String)
          : null,
      generator: json['generator'] as String?,
      model: json['model'] as String?,
    );
  }

  factory ActionPlan.fromApiJson(Map<String, dynamic> json) {
    final objectivesJson = json['objectives'];
    return ActionPlan(
      id: json['id'] as String,
      greeting: json['accroche'] as String? ?? '',
      objectives: objectivesJson is List
          ? objectivesJson
                .whereType<Map<String, dynamic>>()
                .map(ActionPlanObjective.fromApiJson)
                .toList()
          : const [],
      generatedAt: json['genereLe'] != null
          ? DateTime.tryParse(json['genereLe'] as String)
          : null,
      generator: json['generateur'] as String?,
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
  List<Object?> get props => [
    id,
    greeting,
    objectives,
    generatedAt,
    generator,
    model,
  ];
}

class ActionPlanObjectiveProgress extends Equatable {
  final Set<String> doneActionIds;
  final Set<String> deletedActionIds;

  const ActionPlanObjectiveProgress({
    this.doneActionIds = const {},
    this.deletedActionIds = const {},
  });

  bool get isEmpty => doneActionIds.isEmpty && deletedActionIds.isEmpty;

  ActionPlanObjectiveProgress toggleDone(String actionId) {
    final next = Set<String>.of(doneActionIds);
    if (next.contains(actionId)) {
      next.remove(actionId);
    } else {
      next.add(actionId);
    }
    return ActionPlanObjectiveProgress(
      doneActionIds: next,
      deletedActionIds: deletedActionIds,
    );
  }

  ActionPlanObjectiveProgress deleteAction(String actionId) {
    return ActionPlanObjectiveProgress(
      doneActionIds: Set.of(doneActionIds)..remove(actionId),
      deletedActionIds: Set.of(deletedActionIds)..add(actionId),
    );
  }

  ActionPlanObjectiveProgress merge(ActionPlanObjectiveProgress other) {
    return ActionPlanObjectiveProgress(
      doneActionIds: {...doneActionIds, ...other.doneActionIds},
      deletedActionIds: {...deletedActionIds, ...other.deletedActionIds},
    );
  }

  factory ActionPlanObjectiveProgress.fromJson(Map<String, dynamic> json) {
    final done = json['doneActionIds'];
    final deleted = json['deletedActionIds'];
    return ActionPlanObjectiveProgress(
      doneActionIds: done is List ? done.map((e) => e.toString()).toSet() : {},
      deletedActionIds: deleted is List
          ? deleted.map((e) => e.toString()).toSet()
          : {},
    );
  }

  Map<String, dynamic> toJson() => {
    'doneActionIds': doneActionIds.toList(),
    'deletedActionIds': deletedActionIds.toList(),
  };

  @override
  List<Object?> get props => [doneActionIds, deletedActionIds];
}

class ActionPlanProgress extends Equatable {
  static const _legacyKey = '_legacy';

  final Map<String, ActionPlanObjectiveProgress> byObjectiveId;

  const ActionPlanProgress({this.byObjectiveId = const {}});

  bool get hasLegacy => byObjectiveId.containsKey(_legacyKey);

  ActionPlanObjectiveProgress forObjective(String objectiveId) {
    return byObjectiveId[objectiveId] ?? const ActionPlanObjectiveProgress();
  }

  ActionPlanProgress toggleDone(String objectiveId, String actionId) {
    return _setObjective(
      objectiveId,
      forObjective(objectiveId).toggleDone(actionId),
    );
  }

  ActionPlanProgress deleteAction(String objectiveId, String actionId) {
    return _setObjective(
      objectiveId,
      forObjective(objectiveId).deleteAction(actionId),
    );
  }

  ActionPlanProgress retainForObjectives(ActionPlan plan) {
    final current = hasLegacy ? migrateLegacy(plan) : this;
    return ActionPlanProgress(
      byObjectiveId: {
        for (final objective in plan.objectives)
          if (current.byObjectiveId.containsKey(objective.id))
            objective.id: current.byObjectiveId[objective.id]!,
      },
    );
  }

  ActionPlanProgress migrateLegacy(ActionPlan plan) {
    final legacy = byObjectiveId[_legacyKey];
    if (legacy == null) return this;
    final next = Map<String, ActionPlanObjectiveProgress>.of(byObjectiveId)
      ..remove(_legacyKey);
    for (final objective in plan.objectives) {
      final actionIds = objective.actions.map((action) => action.id).toSet();
      final migrated = ActionPlanObjectiveProgress(
        doneActionIds: legacy.doneActionIds.intersection(actionIds),
        deletedActionIds: legacy.deletedActionIds.intersection(actionIds),
      );
      if (migrated.isEmpty) continue;
      next[objective.id] =
          (next[objective.id] ?? const ActionPlanObjectiveProgress()).merge(
            migrated,
          );
    }
    return ActionPlanProgress(byObjectiveId: next);
  }

  ActionPlanProgress _setObjective(
    String objectiveId,
    ActionPlanObjectiveProgress progress,
  ) {
    final next = Map<String, ActionPlanObjectiveProgress>.of(byObjectiveId);
    if (progress.isEmpty) {
      next.remove(objectiveId);
    } else {
      next[objectiveId] = progress;
    }
    return ActionPlanProgress(byObjectiveId: next);
  }

  factory ActionPlanProgress.fromJson(Map<String, dynamic> json) {
    final byObjective = json['byObjectiveId'];
    if (byObjective is Map) {
      return ActionPlanProgress(
        byObjectiveId: {
          for (final entry in byObjective.entries)
            if (entry.value is Map<String, dynamic>)
              entry.key.toString(): ActionPlanObjectiveProgress.fromJson(
                entry.value as Map<String, dynamic>,
              ),
        },
      );
    }
    final done = json['doneActionIds'];
    final deleted = json['deletedActionIds'];
    final legacy = ActionPlanObjectiveProgress(
      doneActionIds: done is List ? done.map((e) => e.toString()).toSet() : {},
      deletedActionIds: deleted is List
          ? deleted.map((e) => e.toString()).toSet()
          : {},
    );
    if (legacy.isEmpty) return const ActionPlanProgress();
    return ActionPlanProgress(byObjectiveId: {_legacyKey: legacy});
  }

  Map<String, dynamic> toJson() => {
    'byObjectiveId': {
      for (final entry in byObjectiveId.entries)
        entry.key: entry.value.toJson(),
    },
  };

  @override
  List<Object?> get props {
    final keys = byObjectiveId.keys.toList()..sort();
    return [
      for (final key in keys) ...[key, byObjectiveId[key]],
    ];
  }
}
