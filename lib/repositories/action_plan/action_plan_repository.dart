import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_request_mapper.dart';

class ActionPlanRepository {
  static const _planKey = 'actionPlan';
  static const _progressKey = 'actionPlanProgress';

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
      final plan = ActionPlan.fromApiJson(data);
      final previous = await _displayedPlan();
      final merged = previous == null ? plan : plan.keepActionsFrom(previous);
      await _persistDisplayedPlan(merged);
      return merged.withoutEmptyObjectives();
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
      return null;
    }
  }

  Future<ActionPlan?> getStoredPlan() async {
    final plan = await _displayedPlan();
    if (plan == null) return null;
    if (await _hasProgress()) await _persistDisplayedPlan(plan);
    return plan.withoutEmptyObjectives();
  }

  Future<void> savePlan(ActionPlan plan) async {
    await _preferences.write(key: _planKey, value: jsonEncode(plan.toJson()));
  }

  Future<ActionPlan?> toggleDone(String actionId) async {
    final plan = await _displayedPlan();
    if (plan == null) return null;
    if (plan.objectiveIdOf(actionId) == null) return null;
    final next = plan.toggleDone(actionId);
    await _persistDisplayedPlan(next);
    return next.withoutEmptyObjectives();
  }

  Future<ActionPlan?> deleteAction(String actionId) async {
    final plan = await _displayedPlan();
    if (plan == null) return null;
    if (plan.objectiveIdOf(actionId) == null) return null;
    final next = plan.deleteAction(actionId);
    await _persistDisplayedPlan(next);
    return next.withoutEmptyObjectives();
  }

  Future<void> clear() async {
    await _preferences.delete(key: _planKey);
    await _preferences.delete(key: _progressKey);
  }

  Future<ActionPlan?> _displayedPlan() async {
    final plan = await _getRawPlan();
    if (plan == null) return null;
    final progress = await _readProgress();
    if (progress.isEmpty) return plan;
    final migrated = progress.hasLegacy
        ? progress.migrateLegacy(plan)
        : progress;
    return plan.applyProgress(migrated);
  }

  Future<void> _persistDisplayedPlan(ActionPlan plan) async {
    await savePlan(plan);
    await _preferences.delete(key: _progressKey);
  }

  Future<bool> _hasProgress() async {
    final raw = await _preferences.read(key: _progressKey);
    return raw != null && raw.isNotEmpty;
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
