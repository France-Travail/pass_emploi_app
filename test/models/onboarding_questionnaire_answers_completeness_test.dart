import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';

void main() {
  test('canGenerateActionPlan requires situation and objectifs', () {
    expect(const OnboardingQuestionnaireAnswers().canGenerateActionPlan, isFalse);
    expect(
      const OnboardingQuestionnaireAnswers(situation: QuestionnaireSituation.lycee).canGenerateActionPlan,
      isFalse,
    );
    expect(
      const OnboardingQuestionnaireAnswers(objectifs: {QuestionnaireObjectif.emploi}).canGenerateActionPlan,
      isFalse,
    );
    expect(
      const OnboardingQuestionnaireAnswers(
        situation: QuestionnaireSituation.lycee,
        objectifs: {QuestionnaireObjectif.emploi},
      ).canGenerateActionPlan,
      isTrue,
    );
  });

  test('completeness distinguishes incomplet partiel and complet', () {
    expect(const OnboardingQuestionnaireAnswers().completeness, OnboardingQuestionnaireCompleteness.incomplet);

    expect(
      const OnboardingQuestionnaireAnswers(
        situation: QuestionnaireSituation.lycee,
        objectifs: {QuestionnaireObjectif.emploi},
      ).completeness,
      OnboardingQuestionnaireCompleteness.partiel,
    );

    expect(
      OnboardingQuestionnaireAnswers(
        prenom: 'Léa',
        dateNaissance: DateTime(2005, 5, 5),
        habitation: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
        situation: QuestionnaireSituation.lycee,
        objectifs: {QuestionnaireObjectif.emploi},
        domaineInconnu: true,
        villeRecherche: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
        freins: {QuestionnaireFrein.rienNeMeBloque},
      ).completeness,
      OnboardingQuestionnaireCompleteness.complet,
    );
  });

  test('answeredStepsCount counts domaineInconnu as answered', () {
    const answers = OnboardingQuestionnaireAnswers(domaineInconnu: true);
    expect(answers.isDomaineAnswered, isTrue);
    expect(answers.answeredStepsCount, 1);
  });
}
