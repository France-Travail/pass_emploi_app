import 'package:dio/dio.dart';
import 'package:pass_emploi_app/crashlytics/crashlytics.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/repositories/action_plan/action_plan_request_mapper.dart';

class RepriseCompteInviteRepository {
  final Dio _httpClient;
  final Crashlytics? _crashlytics;
  final ActionPlanRequestMapper _mapper;

  RepriseCompteInviteRepository(this._httpClient, [this._crashlytics, this._mapper = const ActionPlanRequestMapper()]);

  Future<bool> reprendre({
    required String idInvite,
    required String jetonConnecte,
    Map<String, dynamic>? plan,
    OnboardingQuestionnaireAnswers? questionnaire,
  }) async {
    final url = "/jeunes/$idInvite/reprise-invite";
    // Le questionnaire n'est pris en compte qu'avec le plan qu'il a généré, et un questionnaire invalide
    // (sans situation ni objectif) ferait échouer toute la reprise.
    final withQuestionnaire = plan != null && questionnaire != null && questionnaire.canGenerateActionPlan;
    try {
      await _httpClient.post(
        url,
        data: {
          "jetonConnecte": jetonConnecte,
          if (plan != null) "plan": plan,
          if (withQuestionnaire) "questionnaire": _mapper.toRequest(questionnaire),
        },
      );
      return true;
    } catch (e, stack) {
      _crashlytics?.recordNonNetworkExceptionUrl(e, stack, url);
    }
    return false;
  }
}
