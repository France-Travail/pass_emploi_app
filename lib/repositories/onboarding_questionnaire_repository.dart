import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

class OnboardingQuestionnaireRepository {
  static const _answersKey = 'onboardingQuestionnaireAnswers';
  static const _finishedKey = 'onboardingQuestionnaireFinished';
  static const _everFinishedKey = 'onboardingQuestionnaireEverFinished';

  final FlutterSecureStorage _preferences;

  OnboardingQuestionnaireRepository(this._preferences);

  Future<OnboardingQuestionnaireAnswers> getAnswers() async {
    final raw = await _preferences.read(key: _answersKey);
    if (raw == null || raw.isEmpty) return const OnboardingQuestionnaireAnswers();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return OnboardingQuestionnaireAnswers.fromJson(json);
    } catch (_) {
      return const OnboardingQuestionnaireAnswers();
    }
  }

  Future<void> saveAnswers(OnboardingQuestionnaireAnswers answers) async {
    await _preferences.write(key: _answersKey, value: jsonEncode(answers.toJson()));
  }

  Future<bool> isFinished() async {
    final raw = await _preferences.read(key: _finishedKey);
    return raw == 'true';
  }

  Future<void> setFinished(bool finished) async {
    await _preferences.write(key: _finishedKey, value: finished ? 'true' : 'false');
    if (finished) await _preferences.write(key: _everFinishedKey, value: 'true');
  }

  /// Survives resuming the questionnaire (which resets "finished"), so first pass and updates can be told apart.
  /// Falls back on "finished" for questionnaires completed before this flag existed.
  Future<bool> hasEverFinished() async {
    return await _preferences.read(key: _everFinishedKey) == 'true' || await isFinished();
  }

  Future<void> clear() async {
    await _preferences.delete(key: _answersKey);
    await _preferences.delete(key: _finishedKey);
    await _preferences.delete(key: _everFinishedKey);
  }
}
