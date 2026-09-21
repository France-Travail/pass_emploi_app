import 'package:flutter_test/flutter_test.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_form_change_notifier.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_tracker.dart';

void main() {
  late _TrackerSpy tracker;

  OnboardingQuestionnaireFormChangeNotifier givenForm({
    OnboardingQuestionnaireAnswers answers = const OnboardingQuestionnaireAnswers(),
    bool isUpdate = false,
    bool startAtFirstStep = false,
  }) {
    var stored = answers;
    tracker = _TrackerSpy(isUpdate: isUpdate);
    return OnboardingQuestionnaireFormChangeNotifier(
      loadAnswers: () async => stored,
      saveAnswers: (answers) async => stored = answers,
      onFinishWithoutGeneration: (_) {},
      startAtFirstStep: startAtFirstStep,
      tracker: tracker,
    );
  }

  const lille = QuestionnaireCommune(code: '59350', nom: 'Lille', codePostal: '59000');
  const roubaix = QuestionnaireCommune(code: '59512', nom: 'Roubaix', codePostal: '59100');

  test('sends a screen view for the entry step only, even when it is not step 1', () async {
    final form = givenForm(
      answers: OnboardingQuestionnaireAnswers(prenom: 'Léa', dateNaissance: DateTime(2005, 5, 5)),
    );

    await form.init();

    expect(tracker.screens, ['/questionnaire/premier-passage/etape-3-habitation']);
  });

  test('typing does not send another screen view', () async {
    final form = givenForm();
    await form.init();

    form.updatePrenom('L');
    form.updatePrenom('Lé');
    form.updatePrenom('Léa');

    expect(tracker.screens, ['/questionnaire/premier-passage/etape-1-prenom']);
    expect(tracker.events, isEmpty);
  });

  test('update funnel is sent in its own category and path', () async {
    final form = givenForm(isUpdate: true, startAtFirstStep: true);
    await form.init();

    form.updatePrenom('Léa');
    await form.continueStep();

    expect(tracker.category, AnalyticsEventNames.questionnaireUpdateCategory);
    expect(tracker.screens, [
      '/questionnaire/mise-a-jour/etape-1-prenom',
      '/questionnaire/mise-a-jour/etape-2-date-de-naissance',
    ]);
  });

  test('validating the prénom never sends it', () async {
    final form = givenForm();
    await form.init();

    form.updatePrenom('Léa');
    await form.continueStep();

    expect(tracker.events, [(AnalyticsEventNames.questionnaireStepValidatedAction, 'Étape 1 - Prénom', 1)]);
  });

  test('going back sends "Retour en arrière" and the previous step screen', () async {
    final form = givenForm(answers: const OnboardingQuestionnaireAnswers(prenom: 'Léa'));
    await form.init();

    form.goBack();

    expect(tracker.events, [(AnalyticsEventNames.questionnaireStepBackAction, 'Étape 2 - Date de naissance', 2)]);
    expect(tracker.screens.last, '/questionnaire/premier-passage/etape-1-prenom');
  });

  test('habitation is sent as its département only', () async {
    final form = givenForm(
      answers: OnboardingQuestionnaireAnswers(prenom: 'Léa', dateNaissance: DateTime(2005, 5, 5)),
    );
    await form.init();

    await form.selectHabitationAndContinue(lille);

    expect(tracker.events, [
      (AnalyticsEventNames.questionnaireStepValidatedAction, 'Étape 3 - Habitation', 3),
      (AnalyticsEventNames.questionnaireDepartementAction, '59', null),
    ]);
  });

  test('skipping objectifs sends "Étape passée" and no objectif', () async {
    final form = givenForm(answers: _answersUntil(OnboardingQuestionnaireStep.objectifs));
    await form.init();
    form.toggleObjectif(QuestionnaireObjectif.emploi);

    await form.skipStep();

    expect(tracker.events, [(AnalyticsEventNames.questionnaireStepSkippedAction, 'Étape 5 - Objectifs', 5)]);
  });

  test('validating objectifs sends each objectif and their count', () async {
    final form = givenForm(answers: _answersUntil(OnboardingQuestionnaireStep.objectifs));
    await form.init();
    form.toggleObjectif(QuestionnaireObjectif.emploi);
    form.toggleObjectif(QuestionnaireObjectif.former);

    await form.continueStep();

    expect(tracker.events, [
      (AnalyticsEventNames.questionnaireStepValidatedAction, 'Étape 5 - Objectifs', 5),
      (AnalyticsEventNames.questionnaireObjectifAction, QuestionnaireObjectif.emploi.label, null),
      (AnalyticsEventNames.questionnaireObjectifAction, QuestionnaireObjectif.former.label, null),
      (AnalyticsEventNames.questionnaireObjectifsCountAction, null, 2),
    ]);
  });

  test('domaine typed is never sent', () async {
    final form = givenForm(answers: _answersUntil(OnboardingQuestionnaireStep.domaine));
    await form.init();
    form.updateDomaine('Boulanger chez Dupont 06 12 34 56 78');

    await form.continueStep();

    expect(tracker.events, [
      (AnalyticsEventNames.questionnaireStepValidatedAction, 'Étape 6 - Domaine', 6),
      (AnalyticsEventNames.questionnaireDomaineAction, 'métier saisi', null),
    ]);
  });

  test('"je ne sais pas encore" validates the domaine step', () async {
    final form = givenForm(answers: _answersUntil(OnboardingQuestionnaireStep.domaine));
    await form.init();

    await form.markDomaineUnknownAndContinue();

    expect(tracker.events, [
      (AnalyticsEventNames.questionnaireStepValidatedAction, 'Étape 6 - Domaine', 6),
      (AnalyticsEventNames.questionnaireDomaineAction, 'je ne sais pas encore', null),
    ]);
  });

  test('skipping domaine sends "étape passée" as answer', () async {
    final form = givenForm(answers: _answersUntil(OnboardingQuestionnaireStep.domaine));
    await form.init();

    await form.skipStep();

    expect(tracker.events, [
      (AnalyticsEventNames.questionnaireStepSkippedAction, 'Étape 6 - Domaine', 6),
      (AnalyticsEventNames.questionnaireDomaineAction, 'étape passée', null),
    ]);
  });

  test('zone de recherche prefilled with habitation is "zone inchangée"', () async {
    final form = givenForm(answers: _answersUntil(OnboardingQuestionnaireStep.villeRecherche, habitation: lille));
    await form.init();

    await form.continueStep();

    expect(tracker.events.last, (AnalyticsEventNames.questionnaireZoneAction, 'zone inchangée', 20));
  });

  test('zone de recherche changed is "zone modifiée"', () async {
    final form = givenForm(answers: _answersUntil(OnboardingQuestionnaireStep.villeRecherche, habitation: lille));
    await form.init();
    form.updateRayon(30);

    await form.selectVilleAndContinue(roubaix);

    expect(tracker.events.last, (AnalyticsEventNames.questionnaireZoneAction, 'zone modifiée', 30));
  });

  test('"Rien ne me bloque" is sent alone with a count of 1', () async {
    final form = givenForm(answers: _answersUntil(OnboardingQuestionnaireStep.freins));
    await form.init();
    form.toggleFrein(QuestionnaireFrein.pasDePermis);
    form.toggleFrein(QuestionnaireFrein.rienNeMeBloque);

    await form.continueStep();

    expect(tracker.events, [
      (AnalyticsEventNames.questionnaireStepValidatedAction, 'Étape 8 - Freins', 8),
      (AnalyticsEventNames.questionnaireFreinAction, QuestionnaireFrein.rienNeMeBloque.label, null),
      (AnalyticsEventNames.questionnaireFreinsCountAction, null, 1),
    ]);
  });

  test('geolocation success does not validate the step', () async {
    final form = givenForm(
      answers: OnboardingQuestionnaireAnswers(prenom: 'Léa', dateNaissance: DateTime(2005, 5, 5)),
    );
    await form.init();

    form.startGeolocation();
    form.selectHabitation(lille);
    form.succeedGeolocation();

    expect(tracker.events, [
      (AnalyticsEventNames.questionnaireGeolocationRequestedAction, 'Étape 3 - Habitation', 3),
      (AnalyticsEventNames.questionnaireGeolocationSucceededAction, 'Étape 3 - Habitation', 3),
    ]);
  });

  test('geolocation failure is sent with its cause', () async {
    final form = givenForm(
      answers: OnboardingQuestionnaireAnswers(prenom: 'Léa', dateNaissance: DateTime(2005, 5, 5)),
    );
    await form.init();

    form.failGeolocation(OnboardingQuestionnaireGeolocationFailure.permissionRefusee);

    expect(tracker.events, [(AnalyticsEventNames.questionnaireGeolocationFailedAction, 'Permission refusée', 3)]);
    expect(form.geolocationError, isNotNull);
  });

  test('commune département handles overseas and Corsica', () {
    expect(const QuestionnaireCommune(code: '97411', nom: 'Saint-Denis').departement, '974');
    expect(const QuestionnaireCommune(code: '2A004', nom: 'Ajaccio').departement, '2A');
    expect(lille.departement, '59');
  });
}

OnboardingQuestionnaireAnswers _answersUntil(
  OnboardingQuestionnaireStep step, {
  QuestionnaireCommune habitation = const QuestionnaireCommune(code: '75056', nom: 'Paris'),
}) {
  final index = step.index;
  return OnboardingQuestionnaireAnswers(
    prenom: 'Léa',
    dateNaissance: DateTime(2005, 5, 5),
    habitation: habitation,
    situation: QuestionnaireSituation.lycee,
    objectifs: index > OnboardingQuestionnaireStep.objectifs.index ? {QuestionnaireObjectif.emploi} : {},
    domaine: index > OnboardingQuestionnaireStep.domaine.index ? 'Commerce' : null,
    villeRecherche: index > OnboardingQuestionnaireStep.villeRecherche.index ? habitation : null,
  );
}

class _TrackerSpy extends OnboardingQuestionnaireTracker {
  final List<String> screens = [];
  final List<(String, String?, int?)> events = [];

  _TrackerSpy({required super.isUpdate});

  @override
  void trackScreen(String name) => screens.add(name);

  @override
  void trackEvent(String action, {String? name, int? value}) => events.add((action, name, value));
}
