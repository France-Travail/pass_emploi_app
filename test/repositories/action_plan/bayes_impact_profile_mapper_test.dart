import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/repositories/action_plan/bayes_impact_profile_mapper.dart';

void main() {
  const mapper = BayesImpactProfileMapper();

  test('maps required fields for a guest profile', () {
    final profile = mapper.toProfile(
      OnboardingQuestionnaireAnswers(
        prenom: 'Malik',
        dateNaissance: DateTime(2007, 1, 1),
        situation: QuestionnaireSituation.lycee,
        objectifs: {QuestionnaireObjectif.alternance, QuestionnaireObjectif.vieQuotidienne},
        domaine: 'mécanique',
        villeRecherche: const QuestionnaireCommune(code: '76540', nom: 'Rouen'),
        rayonKm: 30,
        freins: {QuestionnaireFrein.pasDeTransport, QuestionnaireFrein.peuExperience},
      ),
    );

    expect(profile['authProvider'], 'guest');
    expect(profile['situation'], 'high-school');
    expect(profile['goals'], ['apprenticeship', 'dont-know']);
    expect(profile['firstName'], 'Malik');
    expect(profile['domain'], 'mécanique');
    expect(profile['obstacles'], ['transport']);
    expect(profile['location'], {
      'city': 'Rouen',
      'radiusKm': 30,
      'territory': '76',
    });
    expect(profile['age'], isA<int>());
  });

  test('maps rienNeMeBloque to empty obstacles', () {
    final profile = mapper.toProfile(
      const OnboardingQuestionnaireAnswers(
        situation: QuestionnaireSituation.autre,
        objectifs: {QuestionnaireObjectif.emploi},
        freins: {QuestionnaireFrein.rienNeMeBloque},
      ),
    );

    expect(profile['obstacles'], isEmpty);
  });

  test('maps overseas department territory with 3 digits', () {
    final profile = mapper.toProfile(
      const OnboardingQuestionnaireAnswers(
        situation: QuestionnaireSituation.emploi,
        objectifs: {QuestionnaireObjectif.emploi},
        villeRecherche: QuestionnaireCommune(code: '97209', nom: 'Fort-de-France'),
      ),
    );

    expect(profile['location']['territory'], '972');
  });
}
