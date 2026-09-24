import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_request_mapper.dart';

class ActionPlanRepository {
  static const _planKey = 'actionPlan';
  static const _progressKey = 'actionPlanProgress';
  static const _doneKey = 'actionPlanDoneActionIds';

  final Dio _httpClient;
  final FlutterSecureStorage _preferences;
  final Crashlytics? _crashlytics;
  final ActionPlanRequestMapper _mapper;

  ActionPlanRepository(
    this._httpClient,
    this._preferences, [
    this._crashlytics,
    this._mapper = const ActionPlanRequestMapper(),
  ]);

  Future<ActionPlan?> generate(
    String userId,
    OnboardingQuestionnaireAnswers answers,
  ) async {
    if (!answers.canGenerateActionPlan) return null;
    final url = '/jeunes/$userId/plan-action';
    try {
      final response = await _httpClient.post(
        url,
        data: _mapper.toRequest(answers),
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      return await _mergeAndPersist(ActionPlan.fromApiJson(data));
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
      return null;
    }
  }

  Future<ActionPlanFetchResult> fetch(String userId) async {
    final url = '/jeunes/$userId/plan-action';
    try {
      final response = await _httpClient.get(url);
      final data = response.data;
      if (data is! Map<String, dynamic>) return ActionPlanFetchFailure();
      return ActionPlanFetchFound(await _mergeAndPersist(ActionPlan.fromApiJson(data)));
    } catch (e, stack) {
      if (e is DioException && e.response?.statusCode == 404) return ActionPlanFetchNotFound();
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
      return ActionPlanFetchFailure();
    }
  }

  Future<ActionPlan> _mergeAndPersist(ActionPlan plan) async {
    final previous = await _loadState();
    final doneIds = previous?.doneIds ?? await _readDoneActionIds();
    final merged = (previous == null ? plan : plan.keepActionsFrom(previous.plan)).applyDone(doneIds);
    await _persist(merged, doneIds);
    return merged.withoutEmptyObjectives();
  }

  Future<ActionPlan?> getStoredPlan() async {
    final state = await _loadState();
    if (state == null) return null;
    await _persist(state.plan, state.doneIds);
    return state.plan.withoutEmptyObjectives();
  }

  Future<void> savePlan(ActionPlan plan) async {
    await _preferences.write(key: _planKey, value: jsonEncode(plan.toJson()));
  }

  Future<ActionPlan?> toggleDone(String actionId) async {
    final state = await _loadState();
    if (state == null) return null;
    if (state.plan.objectiveIdOf(actionId) == null) return null;
    final next = state.plan.toggleDone(actionId);
    final doneIds = Set<String>.of(state.doneIds);
    if (next.findAction(actionId)?.done == true) {
      doneIds.add(actionId);
    } else {
      doneIds.remove(actionId);
    }
    await _persist(next, doneIds);
    return next.withoutEmptyObjectives();
  }

  Future<ActionPlan?> deleteAction(String actionId) async {
    final state = await _loadState();
    if (state == null) return null;
    if (state.plan.objectiveIdOf(actionId) == null) return null;
    final next = state.plan.deleteAction(actionId);
    await _persist(next, state.doneIds);
    return next.withoutEmptyObjectives();
  }

  Future<void> clear() async {
    await _preferences.delete(key: _planKey);
    await _preferences.delete(key: _progressKey);
    await _preferences.delete(key: _doneKey);
  }

  Future<_ActionPlanState?> _loadState() async {
    var plan = await _getRawPlan();
    if (plan == null) return null;
    final progress = await _readProgress();
    if (!progress.isEmpty) {
      final migrated = progress.hasLegacy ? progress.migrateLegacy(plan) : progress;
      plan = plan.applyProgress(migrated);
    }
    final doneIds = {
      ...await _readDoneActionIds(),
      ...plan.doneActionIds,
      ...progress.allDoneActionIds,
    };
    return _ActionPlanState(plan.applyDone(doneIds), doneIds);
  }

  Future<void> _persist(ActionPlan plan, Set<String> doneIds) async {
    await savePlan(plan);
    await _preferences.write(
      key: _doneKey,
      value: jsonEncode(doneIds.toList()),
    );
    await _preferences.delete(key: _progressKey);
  }

  Future<Set<String>> _readDoneActionIds() async {
    final raw = await _preferences.read(key: _doneKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return {};
      return decoded.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<ActionPlanProgress> _readProgress() async {
    final raw = await _preferences.read(key: _progressKey);
    if (raw == null || raw.isEmpty) return const ActionPlanProgress();
    try {
      return ActionPlanProgress.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const ActionPlanProgress();
    }
  }

  Future<ActionPlan?> _getRawPlan() async {
    final raw = await _preferences.read(key: _planKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return ActionPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

sealed class ActionPlanFetchResult extends Equatable {
  @override
  List<Object?> get props => [];
}

class ActionPlanFetchFound extends ActionPlanFetchResult {
  final ActionPlan plan;

  ActionPlanFetchFound(this.plan);

  @override
  List<Object?> get props => [plan];
}

class ActionPlanFetchNotFound extends ActionPlanFetchResult {}

class ActionPlanFetchFailure extends ActionPlanFetchResult {}

class _ActionPlanState {
  final ActionPlan plan;
  final Set<String> doneIds;

  const _ActionPlanState(this.plan, this.doneIds);
}
