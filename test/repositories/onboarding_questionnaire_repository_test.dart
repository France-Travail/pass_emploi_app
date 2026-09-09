import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/repositories/onboarding_questionnaire_repository.dart';

import '../doubles/spies.dart';

void main() {
  late FlutterSecureStorageSpy storage;
  late OnboardingQuestionnaireRepository repository;

  setUp(() {
    storage = FlutterSecureStorageSpy(delay: Duration.zero);
    repository = OnboardingQuestionnaireRepository(storage);
  });

  test('returns empty answers when nothing stored', () async {
    final answers = await repository.getAnswers();
    expect(answers, const OnboardingQuestionnaireAnswers());
  });

  test('saves and reloads answers', () async {
    final toSave = OnboardingQuestionnaireAnswers(
      prenom: 'Léa',
      situation: QuestionnaireSituation.lycee,
      objectifs: {QuestionnaireObjectif.emploi},
      rayonKm: 30,
      freins: {QuestionnaireFrein.pasDePermis},
    );

    await repository.saveAnswers(toSave);
    final loaded = await repository.getAnswers();

    expect(loaded.prenom, 'Léa');
    expect(loaded.situation, QuestionnaireSituation.lycee);
    expect(loaded.objectifs, {QuestionnaireObjectif.emploi});
    expect(loaded.rayonKm, 30);
    expect(loaded.freins, {QuestionnaireFrein.pasDePermis});
  });

  test('clear removes stored answers', () async {
    await repository.saveAnswers(const OnboardingQuestionnaireAnswers(prenom: 'Léa'));
    await repository.clear();

    final loaded = await repository.getAnswers();
    expect(loaded.prenom, isNull);
  });

  test('finished flag defaults to false and can be persisted', () async {
    expect(await repository.isFinished(), isFalse);
    await repository.setFinished(true);
    expect(await repository.isFinished(), isTrue);
    await repository.setFinished(false);
    expect(await repository.isFinished(), isFalse);
  });
}
