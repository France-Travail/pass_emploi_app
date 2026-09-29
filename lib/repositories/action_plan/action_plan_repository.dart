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
  static const _feedbackKey = 'actionPlanFeedbackThemes';

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
    OnboardingQuestionnaireAnswers answers, {
    bool keepLocalProgress = true,
  }) async {
    if (!answers.canGenerateActionPlan) return null;
    final url = '/jeunes/$userId/plan-action';
    try {
      final response = await _httpClient.post(
        url,
        data: _mapper.toRequest(answers),
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;
      final plan = ActionPlan.fromApiJson(data);
      return keepLocalProgress ? await _mergeAndPersist(plan) : await _replaceAndPersist(plan);
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
      return ActionPlanFetchFound(await _replaceAndPersist(ActionPlan.fromApiJson(data)));
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
    // Objectives absent from the previous plan come with new actions: their feedback is asked again.
    final feedbackThemes = previous?.feedbackThemes.intersection(merged.themes) ?? <String>{};
    await _persist(merged, doneIds);
    await _writeFeedbackThemes(feedbackThemes);
    return merged.applyFeedback(feedbackThemes).withoutEmptyObjectives();
  }

  Future<ActionPlan> _replaceAndPersist(ActionPlan plan) async {
    final feedbackThemes = (await _readFeedbackThemes()).intersection(plan.themes);
    await _persist(plan, plan.doneActionIds);
    await _writeFeedbackThemes(feedbackThemes);
    return plan.applyFeedback(feedbackThemes).withoutEmptyObjectives();
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

  Future<ActionPlan?> giveFeedback(String objectiveId) async {
    final state = await _loadState();
    if (state == null) return null;
    final objective = state.plan.findObjective(objectiveId);
    if (objective == null) return null;
    final feedbackThemes = {...state.feedbackThemes, objective.theme};
    await _writeFeedbackThemes(feedbackThemes);
    return state.plan.applyFeedback(feedbackThemes).withoutEmptyObjectives();
  }

  Future<bool> sendDone(String userId, String actionId, {required bool done}) async {
    final url = '/jeunes/$userId/plan-action/taches/$actionId';
    try {
      await _httpClient.patch(url, data: {'terminee': done});
      return true;
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
      return false;
    }
  }

  Future<bool> sendDelete(String userId, String actionId) async {
    final url = '/jeunes/$userId/plan-action/taches/$actionId';
    try {
      await _httpClient.delete(url);
      return true;
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
      return false;
    }
  }

  Future<void> clear() async {
    await _preferences.delete(key: _planKey);
    await _preferences.delete(key: _progressKey);
    await _preferences.delete(key: _doneKey);
    await _preferences.delete(key: _feedbackKey);
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
    final feedbackThemes = await _readFeedbackThemes();
    return _ActionPlanState(plan.applyDone(doneIds).applyFeedback(feedbackThemes), doneIds, feedbackThemes);
  }

  Future<void> _persist(ActionPlan plan, Set<String> doneIds) async {
    await savePlan(plan);
    await _preferences.write(
      key: _doneKey,
      value: jsonEncode(doneIds.toList()),
    );
    await _preferences.delete(key: _progressKey);
  }

  Future<Set<String>> _readDoneActionIds() => _readStringSet(_doneKey);

  Future<Set<String>> _readFeedbackThemes() => _readStringSet(_feedbackKey);

  Future<void> _writeFeedbackThemes(Set<String> themes) async {
    await _preferences.write(key: _feedbackKey, value: jsonEncode(themes.toList()));
  }

  Future<Set<String>> _readStringSet(String key) async {
    final raw = await _preferences.read(key: key);
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
  final Set<String> feedbackThemes;

  const _ActionPlanState(this.plan, this.doneIds, this.feedbackThemes);
}
