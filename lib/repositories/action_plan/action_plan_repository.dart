import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/action_plan/action_plan.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/repositories/action_plan/bayes_impact_profile_mapper.dart';

class ActionPlanRepository {
  static const _planKey = 'actionPlan';
  static const _progressKey = 'actionPlanProgress';

  final Dio _httpClient;
  final FlutterSecureStorage _preferences;
  final Crashlytics? _crashlytics;
  final BayesImpactProfileMapper _mapper;

  ActionPlanRepository({
    required String baseUrl,
    required String apiKey,
    required FlutterSecureStorage preferences,
    Crashlytics? crashlytics,
    Dio? httpClient,
    BayesImpactProfileMapper mapper = const BayesImpactProfileMapper(),
  }) : _preferences = preferences,
       _crashlytics = crashlytics,
       _mapper = mapper,
       _httpClient =
           httpClient ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               headers: {
                 'Content-Type': 'application/json',
                 'Authorization': 'Bearer $apiKey',
                 'X-Api-Key': apiKey,
               },
             ),
           );

  Future<ActionPlan?> generate(OnboardingQuestionnaireAnswers answers) async {
    if (!answers.canGenerateActionPlan) return null;
    const path = '/v1/action-plans';
    try {
      final response = await _httpClient.post<Map<String, dynamic>>(
        path,
        data: {'profile': _mapper.toProfile(answers)},
      );
      final planJson = response.data?['plan'];
      if (planJson is! Map<String, dynamic>) return null;
      final plan = ActionPlan.fromJson(planJson);
      final previousProgress = await getProgress();
      final retained = previousProgress.retainForPlan(plan);
      await savePlan(plan);
      await saveProgress(retained);
      return plan.applyProgress(doneIds: retained.doneActionIds, deletedIds: retained.deletedActionIds);
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, path);
      return null;
    }
  }

  Future<ActionPlan?> getStoredPlan() async {
    final raw = await _preferences.read(key: _planKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final plan = ActionPlan.fromJson(json);
      final progress = await getProgress();
      return plan.applyProgress(doneIds: progress.doneActionIds, deletedIds: progress.deletedActionIds);
    } catch (_) {
      return null;
    }
  }

  Future<void> savePlan(ActionPlan plan) async {
    await _preferences.write(key: _planKey, value: jsonEncode(plan.toJson()));
  }

  Future<ActionPlanProgress> getProgress() async {
    final raw = await _preferences.read(key: _progressKey);
    if (raw == null || raw.isEmpty) return const ActionPlanProgress();
    try {
      return ActionPlanProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const ActionPlanProgress();
    }
  }

  Future<void> saveProgress(ActionPlanProgress progress) async {
    await _preferences.write(key: _progressKey, value: jsonEncode(progress.toJson()));
  }

  Future<ActionPlan?> toggleDone(String actionId) async {
    final plan = await getStoredPlan();
    if (plan == null) return null;
    final progress = (await getProgress()).toggleDone(actionId);
    await saveProgress(progress);
    return plan.toggleDone(actionId);
  }

  Future<ActionPlan?> deleteAction(String actionId) async {
    final plan = await getStoredPlan();
    if (plan == null) return null;
    final progress = (await getProgress()).deleteAction(actionId);
    await saveProgress(progress);
    return plan.deleteAction(actionId);
  }

  Future<void> clear() async {
    await _preferences.delete(key: _planKey);
    await _preferences.delete(key: _progressKey);
  }
}
