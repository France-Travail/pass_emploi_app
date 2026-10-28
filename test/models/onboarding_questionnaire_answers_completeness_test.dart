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
    expect(
      const OnboardingQuestionnaireAnswers().completeness(withPrenom: true),
      OnboardingQuestionnaireCompleteness.incomplet,
    );

    expect(
      const OnboardingQuestionnaireAnswers(
        situation: QuestionnaireSituation.lycee,
        objectifs: {QuestionnaireObjectif.emploi},
      ).completeness(withPrenom: true),
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
      ).completeness(withPrenom: true),
      OnboardingQuestionnaireCompleteness.complet,
    );
  });

  test('without the prenom step (jeune connecté), 7 steps are enough to be complet', () {
    final answers = OnboardingQuestionnaireAnswers(
      dateNaissance: DateTime(2005, 5, 5),
      habitation: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
      situation: QuestionnaireSituation.lycee,
      objectifs: {QuestionnaireObjectif.emploi},
      domaineInconnu: true,
      villeRecherche: const QuestionnaireCommune(code: '75056', nom: 'Paris'),
      freins: {QuestionnaireFrein.rienNeMeBloque},
    );

    expect(answers.completeness(withPrenom: true), OnboardingQuestionnaireCompleteness.partiel);
    expect(answers.completeness(withPrenom: false), OnboardingQuestionnaireCompleteness.complet);
    expect(OnboardingQuestionnaireAnswers.totalStepsCount(withPrenom: false), 7);
  });

  test('answeredStepsCount counts domaineInconnu as answered', () {
    const answers = OnboardingQuestionnaireAnswers(domaineInconnu: true);
    expect(answers.isDomaineAnswered, isTrue);
    expect(answers.answeredStepsCount(withPrenom: true), 1);
  });

  test('answeredStepsCount without the prenom step does not count the prenom', () {
    const answers = OnboardingQuestionnaireAnswers(prenom: 'Léa', domaineInconnu: true);
    expect(answers.answeredStepsCount(withPrenom: true), 2);
    expect(answers.answeredStepsCount(withPrenom: false), 1);
  });
}
