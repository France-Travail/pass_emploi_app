import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';

void main() {
  late OnboardingQuestionnaireAnswers storedAnswers;
  late List<OnboardingQuestionnaireAnswers> savedCalls;
  late OnboardingQuestionnaireFormChangeNotifier form;

  setUp(() {
    storedAnswers = const OnboardingQuestionnaireAnswers();
    savedCalls = [];
    form = OnboardingQuestionnaireFormChangeNotifier(
      loadAnswers: () async => storedAnswers,
      saveAnswers: (answers) async {
        storedAnswers = answers;
        savedCalls.add(answers);
      },
    );
  });

  group('init', () {
    test('starts at prenom when no answers are saved', () async {
      await form.init();

      expect(form.step, OnboardingQuestionnaireStep.prenom);
      expect(form.isLoading, false);
    });

    test('starts at first incomplete step with prefilled saved answers', () async {
      storedAnswers = const OnboardingQuestionnaireAnswers(prenom: 'Léa');

      await form.init();

      expect(form.step, OnboardingQuestionnaireStep.dateNaissance);
      expect(form.draftPrenom, 'Léa');
      expect(form.isLoading, false);
    });

    test('starts at dateNaissance when only birthdate is missing among early steps', () async {
      storedAnswers = OnboardingQuestionnaireAnswers(
        prenom: 'Léa',
        habitation: const QuestionnaireCommune(code: '59350', nom: 'Lille', codePostal: '59000'),
        situation: QuestionnaireSituation.lycee,
        objectifs: {QuestionnaireObjectif.emploi},
        domaine: 'Commerce',
        villeRecherche: const QuestionnaireCommune(code: '59350', nom: 'Lille', codePostal: '59000'),
        freins: {QuestionnaireFrein.rienNeMeBloque},
      );

      await form.init();

      expect(form.step, OnboardingQuestionnaireStep.dateNaissance);
    });

    test('starts at objectifs when profile is complete so user can update action plan', () async {
      storedAnswers = OnboardingQuestionnaireAnswers(
        prenom: 'Léa',
        dateNaissance: DateTime(2005, 1, 1),
        habitation: const QuestionnaireCommune(code: '59350', nom: 'Lille', codePostal: '59000'),
        situation: QuestionnaireSituation.lycee,
        objectifs: {QuestionnaireObjectif.emploi},
        domaine: 'Commerce',
        villeRecherche: const QuestionnaireCommune(code: '59350', nom: 'Lille', codePostal: '59000'),
        freins: {QuestionnaireFrein.rienNeMeBloque},
      );

      await form.init();

      expect(form.step, OnboardingQuestionnaireStep.objectifs);
      expect(form.step.questionnaireIndex, 5);
      expect(form.draftObjectifs, {QuestionnaireObjectif.emploi});
      expect(form.draftPrenom, 'Léa');
    });
  });

  group('firstIncompleteStep', () {
    test('returns each step when it is the first missing answer', () {
      expect(
        OnboardingQuestionnaireFormChangeNotifier.firstIncompleteStep(const OnboardingQuestionnaireAnswers()),
        OnboardingQuestionnaireStep.prenom,
      );
      expect(
        OnboardingQuestionnaireFormChangeNotifier.firstIncompleteStep(
          const OnboardingQuestionnaireAnswers(prenom: 'Léa'),
        ),
        OnboardingQuestionnaireStep.dateNaissance,
      );
      expect(
        OnboardingQuestionnaireFormChangeNotifier.firstIncompleteStep(
          OnboardingQuestionnaireAnswers(prenom: 'Léa', dateNaissance: DateTime(2005, 1, 1)),
        ),
        OnboardingQuestionnaireStep.habitation,
      );
    });

    test('treats domaineInconnu as answered domaine', () {
      expect(
        OnboardingQuestionnaireFormChangeNotifier.firstIncompleteStep(
          OnboardingQuestionnaireAnswers(
            prenom: 'Léa',
            dateNaissance: DateTime(2005, 1, 1),
            habitation: const QuestionnaireCommune(code: '59350', nom: 'Lille'),
            situation: QuestionnaireSituation.lycee,
            objectifs: {QuestionnaireObjectif.emploi},
            domaineInconnu: true,
          ),
        ),
        OnboardingQuestionnaireStep.villeRecherche,
      );
    });

    test('returns objectifs when all answers are filled (modifier le plan)', () {
      expect(
        OnboardingQuestionnaireFormChangeNotifier.firstIncompleteStep(
          OnboardingQuestionnaireAnswers(
            prenom: 'Léa',
            dateNaissance: DateTime(2005, 1, 1),
            habitation: const QuestionnaireCommune(code: '59350', nom: 'Lille'),
            situation: QuestionnaireSituation.lycee,
            objectifs: {QuestionnaireObjectif.emploi},
            domaine: 'Commerce',
            villeRecherche: const QuestionnaireCommune(code: '59350', nom: 'Lille'),
            freins: {QuestionnaireFrein.rienNeMeBloque},
          ),
        ),
        OnboardingQuestionnaireStep.objectifs,
      );
    });
  });

  group('continue / skip / back', () {
    setUp(() async {
      await form.init();
    });

    test('continue is disabled when prenom is empty', () {
      expect(form.canContinue, false);
    });

    test('continue saves prenom and goes to next step', () async {
      form.updatePrenom('Léa');

      await form.continueStep();

      expect(form.step, OnboardingQuestionnaireStep.dateNaissance);
      expect(form.savedAnswers.prenom, 'Léa');
      expect(savedCalls, hasLength(1));
    });

    test('skip discards draft prenom and goes to next step', () async {
      form.updatePrenom('Léa');

      await form.skipStep();

      expect(form.step, OnboardingQuestionnaireStep.dateNaissance);
      expect(form.draftPrenom, isEmpty);
      expect(form.savedAnswers.prenom, isNull);
      expect(savedCalls, hasLength(1));
    });

    test('skip clears previously saved prenom when coming back', () async {
      form.updatePrenom('Léa');
      await form.continueStep();
      form.goBack();
      form.updatePrenom('');

      await form.skipStep();

      expect(form.step, OnboardingQuestionnaireStep.dateNaissance);
      expect(form.savedAnswers.prenom, isNull);
      expect(form.draftPrenom, isEmpty);
    });

    test('back from step 2 returns to prenom with saved data', () async {
      form.updatePrenom('Léa');
      await form.continueStep();
      form.updateBirthDay('01');
      form.updateBirthMonth('01');
      form.updateBirthYear('2005');

      final shouldLogout = form.goBack();

      expect(shouldLogout, false);
      expect(form.step, OnboardingQuestionnaireStep.prenom);
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
      await form.init();
      form.step = OnboardingQuestionnaireStep.freins;
    });

    test('selecting rienNeMeBloque clears other freins', () {
      form.toggleFrein(QuestionnaireFrein.pasDePermis);
      form.toggleFrein(QuestionnaireFrein.manqueConfiance);
      form.toggleFrein(QuestionnaireFrein.rienNeMeBloque);

      expect(form.draftFreins, {QuestionnaireFrein.rienNeMeBloque});
    });

    test('selecting another frein removes rienNeMeBloque', () {
      form.toggleFrein(QuestionnaireFrein.rienNeMeBloque);
      form.toggleFrein(QuestionnaireFrein.pasDePermis);

      expect(form.draftFreins, {QuestionnaireFrein.pasDePermis});
    });
  });

  group('birthdate validation', () {
    setUp(() async {
      await form.init();
      form.step = OnboardingQuestionnaireStep.dateNaissance;
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
      await form.init();
      form.step = OnboardingQuestionnaireStep.situation;
    });

    test('selectSituationAndContinue saves and goes to objectifs', () async {
      await form.selectSituationAndContinue(QuestionnaireSituation.lycee);

      expect(form.draftSituation, QuestionnaireSituation.lycee);
      expect(form.savedAnswers.situation, QuestionnaireSituation.lycee);
      expect(form.step, OnboardingQuestionnaireStep.objectifs);
      expect(savedCalls, hasLength(1));
    });
  });

  group('ville prefill from habitation', () {
    const habitation = QuestionnaireCommune(code: '59350', nom: 'Lille', codePostal: '59000');

    setUp(() async {
      await form.init();
    });

    test('arriving on villeRecherche suggests habitation city', () async {
      form.step = OnboardingQuestionnaireStep.habitation;
      form.selectHabitation(habitation);
      await form.continueStep();

      form.step = OnboardingQuestionnaireStep.domaine;
      await form.skipStep();

      expect(form.step, OnboardingQuestionnaireStep.villeRecherche);
      expect(form.draftVilleRecherche, habitation);
      expect(form.draftVilleQuery, 'Lille (59000)');
    });
  });
}
