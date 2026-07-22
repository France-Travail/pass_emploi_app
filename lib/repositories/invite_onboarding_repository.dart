import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pass_emploi_app/models/invite_onboarding_answers.dart';

class InviteOnboardingRepository {
  static const _key = 'inviteOnboardingAnswers';

  final FlutterSecureStorage _preferences;

  InviteOnboardingRepository(this._preferences);

  Future<InviteOnboardingAnswers> getAnswers() async {
    final raw = await _preferences.read(key: _key);
    if (raw == null || raw.isEmpty) return const InviteOnboardingAnswers();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return InviteOnboardingAnswers.fromJson(json);
    } catch (_) {
      return const InviteOnboardingAnswers();
    }
  }

  Future<void> saveAnswers(InviteOnboardingAnswers answers) async {
    await _preferences.write(key: _key, value: jsonEncode(answers.toJson()));
  }

  Future<void> clear() async {
    await _preferences.delete(key: _key);
  }
}
