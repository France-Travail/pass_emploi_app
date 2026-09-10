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
      final previousProgress = await getProgress();
      final retained = previousProgress.retainForObjectives(plan);
      await savePlan(plan);
      await saveProgress(retained);
      return plan.applyProgress(retained);
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
      return null;
    }
  }

  Future<ActionPlan?> getStoredPlan() async {
    final plan = await _getRawPlan();
    if (plan == null) return null;
    final progress = await getProgress();
    return plan.applyProgress(progress);
  }

  Future<void> savePlan(ActionPlan plan) async {
    await _preferences.write(key: _planKey, value: jsonEncode(plan.toJson()));
  }

  Future<ActionPlanProgress> getProgress() async {
    final raw = await _preferences.read(key: _progressKey);
    if (raw == null || raw.isEmpty) return const ActionPlanProgress();
    try {
      final progress = ActionPlanProgress.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (!progress.hasLegacy) return progress;
      final plan = await _getRawPlan();
      if (plan == null) return progress;
      final migrated = progress.migrateLegacy(plan);
      await saveProgress(migrated);
      return migrated;
    } catch (_) {
      return const ActionPlanProgress();
    }
  }

  Future<void> saveProgress(ActionPlanProgress progress) async {
    await _preferences.write(
      key: _progressKey,
      value: jsonEncode(progress.toJson()),
    );
  }

  Future<ActionPlan?> toggleDone(String actionId) async {
    final plan = await getStoredPlan();
    if (plan == null) return null;
    final objectiveId = plan.objectiveIdOf(actionId);
    if (objectiveId == null) return null;
    final progress = (await getProgress()).toggleDone(objectiveId, actionId);
    await saveProgress(progress);
    return plan.toggleDone(actionId);
  }

  Future<ActionPlan?> deleteAction(String actionId) async {
    final plan = await getStoredPlan();
    if (plan == null) return null;
    final objectiveId = plan.objectiveIdOf(actionId);
    if (objectiveId == null) return null;
    final progress = (await getProgress()).deleteAction(objectiveId, actionId);
    await saveProgress(progress);
    return plan.deleteAction(actionId);
  }

  Future<void> clear() async {
    await _preferences.delete(key: _planKey);
    await _preferences.delete(key: _progressKey);
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
