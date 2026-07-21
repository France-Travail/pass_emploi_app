import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pass_emploi_app/models/invite_onboarding_answers.dart';
import 'package:pass_emploi_app/presentation/invite_onboarding/invite_onboarding_form_change_notifier.dart';
import 'package:pass_emploi_app/repositories/invite_onboarding_repository.dart';

class _MockInviteOnboardingRepository extends Mock implements InviteOnboardingRepository {}

void main() {
  late _MockInviteOnboardingRepository repository;
  late InviteOnboardingFormChangeNotifier form;

  setUpAll(() {
    registerFallbackValue(const InviteOnboardingAnswers());
  });

  setUp(() {
    repository = _MockInviteOnboardingRepository();
    form = InviteOnboardingFormChangeNotifier(repository);
  });

  group('init', () {
    test('starts at prenom step with prefilled saved answers', () async {
      when(() => repository.getAnswers()).thenAnswer(
        (_) async => const InviteOnboardingAnswers(prenom: 'Léa'),
      );

      await form.init();

      expect(form.step, InviteOnboardingStep.prenom);
      expect(form.draftPrenom, 'Léa');
      expect(form.isLoading, false);
    });
  });

  group('continue / skip / back', () {
    setUp(() async {
      when(() => repository.getAnswers()).thenAnswer((_) async => const InviteOnboardingAnswers());
      when(() => repository.saveAnswers(any())).thenAnswer((_) async {});
      await form.init();
    });

    test('continue is disabled when prenom is empty', () {
      expect(form.canContinue, false);
    });

    test('continue saves prenom and goes to next step', () async {
      form.updatePrenom('Léa');

      await form.continueStep();

      expect(form.step, InviteOnboardingStep.dateNaissance);
      expect(form.savedAnswers.prenom, 'Léa');
      verify(() => repository.saveAnswers(any())).called(1);
    });

    test('skip does not save current draft prenom', () async {
      form.updatePrenom('Léa');

      await form.skipStep();

      expect(form.step, InviteOnboardingStep.dateNaissance);
      expect(form.savedAnswers.prenom, isNull);
      verifyNever(() => repository.saveAnswers(any()));
    });

    test('back from step 2 returns to prenom with saved data', () async {
      form.updatePrenom('Léa');
      await form.continueStep();
      form.updateBirthDay('01');
      form.updateBirthMonth('01');
      form.updateBirthYear('2005');

      final shouldLogout = form.goBack();

      expect(shouldLogout, false);
      expect(form.step, InviteOnboardingStep.prenom);
      expect(form.draftPrenom, 'Léa');
    });

    test('back from step 1 requests logout', () {
      expect(form.goBack(), true);
    });

    test('prenom is truncated to 256 chars', () {
      form.updatePrenom('a' * 300);
      expect(form.draftPrenom.length, 256);
    });
  });

  group('freins exclusive option', () {
    setUp(() async {
      when(() => repository.getAnswers()).thenAnswer((_) async => const InviteOnboardingAnswers());
      when(() => repository.saveAnswers(any())).thenAnswer((_) async {});
      await form.init();
      form.step = InviteOnboardingStep.freins;
    });

    test('selecting rienNeMeBloque clears other freins', () {
      form.toggleFrein(InviteFrein.pasDePermis);
      form.toggleFrein(InviteFrein.manqueConfiance);
      form.toggleFrein(InviteFrein.rienNeMeBloque);

      expect(form.draftFreins, {InviteFrein.rienNeMeBloque});
    });

    test('selecting another frein removes rienNeMeBloque', () {
      form.toggleFrein(InviteFrein.rienNeMeBloque);
      form.toggleFrein(InviteFrein.pasDePermis);

      expect(form.draftFreins, {InviteFrein.pasDePermis});
    });
  });

  group('birthdate validation', () {
    setUp(() async {
      when(() => repository.getAnswers()).thenAnswer((_) async => const InviteOnboardingAnswers());
      await form.init();
      form.step = InviteOnboardingStep.dateNaissance;
    });

    test('complete valid date enables continue', () {
      form.updateBirthDay('15');
      form.updateBirthMonth('06');
      form.updateBirthYear('2004');

      expect(form.canContinue, true);
      expect(form.parsedBirthDate, DateTime(2004, 6, 15));
    });

    test('incomplete date disables continue', () {
      form.updateBirthDay('15');
      form.updateBirthMonth('06');

      expect(form.canContinue, false);
    });
  });

  group('situation auto advance', () {
    setUp(() async {
      when(() => repository.getAnswers()).thenAnswer((_) async => const InviteOnboardingAnswers());
      when(() => repository.saveAnswers(any())).thenAnswer((_) async {});
      await form.init();
      form.step = InviteOnboardingStep.situation;
    });

    test('selectSituationAndContinue saves and goes to objectifs', () async {
      await form.selectSituationAndContinue(InviteSituation.lycee);

      expect(form.draftSituation, InviteSituation.lycee);
      expect(form.savedAnswers.situation, InviteSituation.lycee);
      expect(form.step, InviteOnboardingStep.objectifs);
      verify(() => repository.saveAnswers(any())).called(1);
    });
  });

  group('ville prefill from habitation', () {
    const habitation = InviteCommune(code: '59350', nom: 'Lille', codePostal: '59000');

    setUp(() async {
      when(() => repository.getAnswers()).thenAnswer((_) async => const InviteOnboardingAnswers());
      when(() => repository.saveAnswers(any())).thenAnswer((_) async {});
      await form.init();
    });

    test('arriving on villeRecherche suggests habitation city', () async {
      form.step = InviteOnboardingStep.habitation;
      form.selectHabitation(habitation);
      await form.continueStep();

      form.step = InviteOnboardingStep.domaine;
      await form.skipStep();

      expect(form.step, InviteOnboardingStep.villeRecherche);
      expect(form.draftVilleRecherche, habitation);
      expect(form.draftVilleQuery, 'Lille (59000)');
    });
  });
}
