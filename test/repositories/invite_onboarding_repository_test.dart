import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/invite_onboarding_answers.dart';
import 'package:pass_emploi_app/repositories/invite_onboarding_repository.dart';

import '../doubles/spies.dart';

void main() {
  late FlutterSecureStorageSpy storage;
  late InviteOnboardingRepository repository;

  setUp(() {
    storage = FlutterSecureStorageSpy(delay: Duration.zero);
    repository = InviteOnboardingRepository(storage);
  });

  test('returns empty answers when nothing stored', () async {
    final answers = await repository.getAnswers();
    expect(answers, const InviteOnboardingAnswers());
  });

  test('saves and reloads answers', () async {
    final toSave = InviteOnboardingAnswers(
      prenom: 'Léa',
      situation: InviteSituation.lycee,
      objectifs: {InviteObjectif.emploi},
      rayonKm: 30,
      freins: {InviteFrein.pasDePermis},
    );

    await repository.saveAnswers(toSave);
    final loaded = await repository.getAnswers();

    expect(loaded.prenom, 'Léa');
    expect(loaded.situation, InviteSituation.lycee);
    expect(loaded.objectifs, {InviteObjectif.emploi});
    expect(loaded.rayonKm, 30);
    expect(loaded.freins, {InviteFrein.pasDePermis});
  });

  test('clear removes stored answers', () async {
    await repository.saveAnswers(const InviteOnboardingAnswers(prenom: 'Léa'));
    await repository.clear();

    final loaded = await repository.getAnswers();
    expect(loaded.prenom, isNull);
  });
}
