import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/presentation/onboarding_questionnaire/onboarding_questionnaire_tracker.dart';
import 'package:pass_emploi_app/ui/strings.dart';

typedef OnboardingQuestionnaireAnswersLoader = Future<OnboardingQuestionnaireAnswers> Function();
typedef OnboardingQuestionnaireAnswersSaver = Future<void> Function(OnboardingQuestionnaireAnswers answers);
typedef OnboardingQuestionnaireFinishWithoutGeneration = void Function(OnboardingQuestionnaireAnswers answers);

enum OnboardingQuestionnaireStep {
  prenom,
  dateNaissance,
  habitation,
  situation,
  objectifs,
  domaine,
  villeRecherche,
  freins,
  loader;

  bool get isLoader => this == OnboardingQuestionnaireStep.loader;

  int get questionnaireIndex => index + 1;

  static const int questionnaireCount = 8;

  OnboardingQuestionnaireStep? get previous {
    if (index == 0) return null;
    return OnboardingQuestionnaireStep.values[index - 1];
  }

  OnboardingQuestionnaireStep? get next {
    if (index >= OnboardingQuestionnaireStep.values.length - 1) return null;
    return OnboardingQuestionnaireStep.values[index + 1];
  }
}

class OnboardingQuestionnaireFormChangeNotifier extends ChangeNotifier {
  final OnboardingQuestionnaireAnswersLoader _loadAnswers;
  final OnboardingQuestionnaireAnswersSaver _saveAnswers;
  final OnboardingQuestionnaireFinishWithoutGeneration? _onFinishWithoutGeneration;
  final bool startAtFirstStep;
  final bool skipActionPlanGeneration;
  final OnboardingQuestionnaireTracker? _tracker;

  OnboardingQuestionnaireStep step = OnboardingQuestionnaireStep.prenom;
  OnboardingQuestionnaireAnswers savedAnswers = const OnboardingQuestionnaireAnswers();

  String draftPrenom = '';
  String draftBirthDay = '';
  String draftBirthMonth = '';
  String draftBirthYear = '';
  QuestionnaireCommune? draftHabitation;
  String draftHabitationQuery = '';
  QuestionnaireSituation? draftSituation;
  Set<QuestionnaireObjectif> draftObjectifs = {};
  String draftDomaine = '';
  QuestionnaireCommune? draftVilleRecherche;
  String draftVilleQuery = '';
  int draftRayonKm = 20;
  Set<QuestionnaireFrein> draftFreins = {};

  bool isLoading = true;
  bool isGeolocating = false;
  String? geolocationError;

  OnboardingQuestionnaireFormChangeNotifier({
    required OnboardingQuestionnaireAnswersLoader loadAnswers,
    required OnboardingQuestionnaireAnswersSaver saveAnswers,
    OnboardingQuestionnaireFinishWithoutGeneration? onFinishWithoutGeneration,
    this.startAtFirstStep = false,
    this.skipActionPlanGeneration = false,
    OnboardingQuestionnaireTracker? tracker,
  }) : _loadAnswers = loadAnswers,
       _saveAnswers = saveAnswers,
       _onFinishWithoutGeneration = onFinishWithoutGeneration,
       _tracker = tracker;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();
    savedAnswers = await _loadAnswers();
    _hydrateDraftsFromSaved();
    step = startAtFirstStep ? OnboardingQuestionnaireStep.prenom : firstIncompleteStep(savedAnswers);
    _tracker?.trackStepScreen(step);
    isLoading = false;
    notifyListeners();
  }

  /// Première étape sans réponse ; si tout est rempli (ex. modifier le plan), repart de l'étape 5 (objectifs).
  @visibleForTesting
  static OnboardingQuestionnaireStep firstIncompleteStep(OnboardingQuestionnaireAnswers answers) {
    if (!answers.isPrenomAnswered) return OnboardingQuestionnaireStep.prenom;
    if (!answers.isDateNaissanceAnswered) return OnboardingQuestionnaireStep.dateNaissance;
    if (!answers.isHabitationAnswered) return OnboardingQuestionnaireStep.habitation;
    if (!answers.isSituationAnswered) return OnboardingQuestionnaireStep.situation;
    if (!answers.isObjectifsAnswered) return OnboardingQuestionnaireStep.objectifs;
    if (!answers.isDomaineAnswered) return OnboardingQuestionnaireStep.domaine;
    if (!answers.isVilleRechercheAnswered) return OnboardingQuestionnaireStep.villeRecherche;
    if (!answers.isFreinsAnswered) return OnboardingQuestionnaireStep.freins;
    return OnboardingQuestionnaireStep.objectifs;
  }

  void _hydrateDraftsFromSaved() {
    draftPrenom = savedAnswers.prenom ?? '';
    final birth = savedAnswers.dateNaissance;
    if (birth != null) {
      draftBirthDay = birth.day.toString().padLeft(2, '0');
      draftBirthMonth = birth.month.toString().padLeft(2, '0');
      draftBirthYear = birth.year.toString();
    } else {
      draftBirthDay = '';
      draftBirthMonth = '';
      draftBirthYear = '';
    }
    draftHabitation = savedAnswers.habitation;
    draftHabitationQuery = savedAnswers.habitation?.displayLabel ?? '';
    draftSituation = savedAnswers.situation;
    draftObjectifs = Set.of(savedAnswers.objectifs);
    draftDomaine = savedAnswers.domaine ?? '';
    _prefillVilleFromHabitation();
    draftFreins = Set.of(savedAnswers.freins);
  }

  void _reloadDraftForStep(OnboardingQuestionnaireStep target) {
    switch (target) {
      case OnboardingQuestionnaireStep.prenom:
        draftPrenom = savedAnswers.prenom ?? '';
      case OnboardingQuestionnaireStep.dateNaissance:
        final birth = savedAnswers.dateNaissance;
        if (birth != null) {
          draftBirthDay = birth.day.toString().padLeft(2, '0');
          draftBirthMonth = birth.month.toString().padLeft(2, '0');
          draftBirthYear = birth.year.toString();
        } else {
          draftBirthDay = '';
          draftBirthMonth = '';
          draftBirthYear = '';
        }
      case OnboardingQuestionnaireStep.habitation:
        draftHabitation = savedAnswers.habitation;
        draftHabitationQuery = savedAnswers.habitation?.displayLabel ?? '';
      case OnboardingQuestionnaireStep.situation:
        draftSituation = savedAnswers.situation;
      case OnboardingQuestionnaireStep.objectifs:
        draftObjectifs = Set.of(savedAnswers.objectifs);
      case OnboardingQuestionnaireStep.domaine:
        draftDomaine = savedAnswers.domaine ?? '';
      case OnboardingQuestionnaireStep.villeRecherche:
        _prefillVilleFromHabitation();
      case OnboardingQuestionnaireStep.freins:
        draftFreins = Set.of(savedAnswers.freins);
      case OnboardingQuestionnaireStep.loader:
        break;
    }
  }

  bool get canContinue => switch (step) {
    OnboardingQuestionnaireStep.prenom => draftPrenom.trim().isNotEmpty,
    OnboardingQuestionnaireStep.dateNaissance => parsedBirthDate != null,
    OnboardingQuestionnaireStep.habitation => draftHabitation != null,
    OnboardingQuestionnaireStep.situation => draftSituation != null,
    OnboardingQuestionnaireStep.objectifs => draftObjectifs.isNotEmpty,
    OnboardingQuestionnaireStep.domaine => draftDomaine.trim().isNotEmpty,
    OnboardingQuestionnaireStep.villeRecherche => draftVilleRecherche != null,
    OnboardingQuestionnaireStep.freins => draftFreins.isNotEmpty,
    OnboardingQuestionnaireStep.loader => false,
  };

  DateTime? get parsedBirthDate {
    if (draftBirthDay.length != 2 || draftBirthMonth.length != 2 || draftBirthYear.length != 4) {
      return null;
    }
    final day = int.tryParse(draftBirthDay);
    final month = int.tryParse(draftBirthMonth);
    final year = int.tryParse(draftBirthYear);
    if (day == null || month == null || year == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) return null;
    return date;
  }

  static const int minimumAge = 15;

  /// Moins de 15 ans à la date du jour : l'app ne laisse pas continuer (passer l'étape reste possible).
  bool get isBirthDateUnderMinimumAge {
    final birthDate = parsedBirthDate;
    return birthDate != null && isUnderMinimumAge(birthDate, clock.now());
  }

  /// Une date future compte comme moins de 15 ans. Né un 29 février : 15 ans le 1er mars des années non bissextiles.
  @visibleForTesting
  static bool isUnderMinimumAge(DateTime birthDate, DateTime now) {
    final minimumAgeBirthday = DateTime(birthDate.year + minimumAge, birthDate.month, birthDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return today.isBefore(minimumAgeBirthday);
  }

  void updatePrenom(String value) {
    draftPrenom = value.length > 256 ? value.substring(0, 256) : value;
    notifyListeners();
  }

  void updateBirthDay(String value) {
    draftBirthDay = value;
    notifyListeners();
  }

  void updateBirthMonth(String value) {
    draftBirthMonth = value;
    notifyListeners();
  }

  void updateBirthYear(String value) {
    draftBirthYear = value;
    notifyListeners();
  }

  void updateHabitationQuery(String value) {
    draftHabitationQuery = value;
    if (draftHabitation != null && draftHabitation!.displayLabel != value) {
      draftHabitation = null;
    }
    geolocationError = null;
    notifyListeners();
  }

  void selectHabitation(QuestionnaireCommune commune) {
    draftHabitation = commune;
    draftHabitationQuery = commune.displayLabel;
    geolocationError = null;
    notifyListeners();
  }

  void updateSituation(QuestionnaireSituation situation) {
    draftSituation = situation;
    notifyListeners();
  }

  Future<void> selectSituationAndContinue(QuestionnaireSituation situation) async {
    updateSituation(situation);
    await continueStep();
  }

  void toggleObjectif(QuestionnaireObjectif objectif) {
    final next = Set<QuestionnaireObjectif>.of(draftObjectifs);
    if (next.contains(objectif)) {
      next.remove(objectif);
    } else {
      next.add(objectif);
    }
    draftObjectifs = next;
    notifyListeners();
  }

  void updateDomaine(String value) {
    draftDomaine = value.length > 256 ? value.substring(0, 256) : value;
    notifyListeners();
  }

  void updateVilleQuery(String value) {
    draftVilleQuery = value;
    if (draftVilleRecherche != null && draftVilleRecherche!.displayLabel != value) {
      draftVilleRecherche = null;
    }
    geolocationError = null;
    notifyListeners();
  }

  void selectVilleRecherche(QuestionnaireCommune commune) {
    draftVilleRecherche = commune;
    draftVilleQuery = commune.displayLabel;
    geolocationError = null;
    notifyListeners();
  }

  void updateRayon(double value) {
    draftRayonKm = value.round();
    notifyListeners();
  }

  void toggleFrein(QuestionnaireFrein frein) {
    final next = Set<QuestionnaireFrein>.of(draftFreins);
    if (frein.isExclusive) {
      if (next.contains(frein)) {
        next.remove(frein);
      } else {
        next
          ..clear()
          ..add(frein);
      }
    } else {
      next.remove(QuestionnaireFrein.rienNeMeBloque);
      if (next.contains(frein)) {
        next.remove(frein);
      } else {
        next.add(frein);
      }
    }
    draftFreins = next;
    notifyListeners();
  }

  Future<void> continueStep() async {
    if (!canContinue) return;
    if (step == OnboardingQuestionnaireStep.dateNaissance && isBirthDateUnderMinimumAge) return;
    await _persistCurrentStep();
    _tracker?.trackStepEvent(AnalyticsEventNames.questionnaireStepValidatedAction, step);
    _trackAnswers();
    _goNext();
  }

  Future<void> skipStep() async {
    await _clearCurrentStep();
    _tracker?.trackStepEvent(AnalyticsEventNames.questionnaireStepSkippedAction, step);
    if (step == OnboardingQuestionnaireStep.domaine) _trackDomaine("étape passée");
    _goNext();
  }

  Future<void> _clearCurrentStep() async {
    switch (step) {
      case OnboardingQuestionnaireStep.prenom:
        draftPrenom = '';
        savedAnswers = savedAnswers.copyWith(clearPrenom: true);
      case OnboardingQuestionnaireStep.dateNaissance:
        draftBirthDay = '';
        draftBirthMonth = '';
        draftBirthYear = '';
        savedAnswers = savedAnswers.copyWith(clearDateNaissance: true);
      case OnboardingQuestionnaireStep.habitation:
        draftHabitation = null;
        draftHabitationQuery = '';
        savedAnswers = savedAnswers.copyWith(clearHabitation: true);
      case OnboardingQuestionnaireStep.situation:
        draftSituation = null;
        savedAnswers = savedAnswers.copyWith(clearSituation: true);
      case OnboardingQuestionnaireStep.objectifs:
        draftObjectifs = {};
        savedAnswers = savedAnswers.copyWith(objectifs: {});
      case OnboardingQuestionnaireStep.domaine:
        draftDomaine = '';
        savedAnswers = savedAnswers.copyWith(clearDomaine: true, domaineInconnu: false);
      case OnboardingQuestionnaireStep.villeRecherche:
        draftVilleRecherche = null;
        draftVilleQuery = '';
        savedAnswers = savedAnswers.copyWith(clearVilleRecherche: true);
      case OnboardingQuestionnaireStep.freins:
        draftFreins = {};
        savedAnswers = savedAnswers.copyWith(freins: {});
      case OnboardingQuestionnaireStep.loader:
        return;
    }
    await _saveAnswers(savedAnswers);
  }

  Future<void> selectHabitationAndContinue(QuestionnaireCommune commune) async {
    selectHabitation(commune);
    await continueStep();
  }

  Future<void> selectVilleAndContinue(QuestionnaireCommune commune) async {
    selectVilleRecherche(commune);
    await continueStep();
  }

  Future<void> markDomaineUnknownAndContinue() async {
    savedAnswers = savedAnswers.copyWith(clearDomaine: true, domaineInconnu: true);
    await _saveAnswers(savedAnswers);
    draftDomaine = '';
    _tracker?.trackStepEvent(AnalyticsEventNames.questionnaireStepValidatedAction, step);
    _trackDomaine("je ne sais pas encore");
    _goNext();
  }

  void _trackAnswers() {
    final tracker = _tracker;
    if (tracker == null) return;
    switch (step) {
      case OnboardingQuestionnaireStep.habitation:
        final departement = savedAnswers.habitation?.departement;
        if (departement != null) {
          tracker.trackEvent(AnalyticsEventNames.questionnaireDepartementAction, name: departement);
        }
      case OnboardingQuestionnaireStep.situation:
        tracker.trackEvent(AnalyticsEventNames.questionnaireSituationAction, name: savedAnswers.situation?.label);
      case OnboardingQuestionnaireStep.objectifs:
        for (final objectif in savedAnswers.objectifs) {
          tracker.trackEvent(AnalyticsEventNames.questionnaireObjectifAction, name: objectif.label);
        }
        tracker.trackEvent(AnalyticsEventNames.questionnaireObjectifsCountAction, value: savedAnswers.objectifs.length);
      case OnboardingQuestionnaireStep.domaine:
        _trackDomaine("métier saisi");
      case OnboardingQuestionnaireStep.villeRecherche:
        final unchanged = savedAnswers.villeRecherche?.code == savedAnswers.habitation?.code;
        tracker.trackEvent(
          AnalyticsEventNames.questionnaireZoneAction,
          name: unchanged ? "zone inchangée" : "zone modifiée",
          value: savedAnswers.rayonKm,
        );
      case OnboardingQuestionnaireStep.freins:
        for (final frein in savedAnswers.freins) {
          tracker.trackEvent(AnalyticsEventNames.questionnaireFreinAction, name: frein.label);
        }
        tracker.trackEvent(AnalyticsEventNames.questionnaireFreinsCountAction, value: savedAnswers.freins.length);
      case OnboardingQuestionnaireStep.prenom ||
          OnboardingQuestionnaireStep.dateNaissance ||
          OnboardingQuestionnaireStep.loader:
        break;
    }
  }

  // Never the text typed by the jeune.
  void _trackDomaine(String answer) =>
      _tracker?.trackEvent(AnalyticsEventNames.questionnaireDomaineAction, name: answer);

  Future<void> _persistCurrentStep() async {
    switch (step) {
      case OnboardingQuestionnaireStep.prenom:
        savedAnswers = savedAnswers.copyWith(prenom: draftPrenom.trim());
      case OnboardingQuestionnaireStep.dateNaissance:
        savedAnswers = savedAnswers.copyWith(dateNaissance: parsedBirthDate);
      case OnboardingQuestionnaireStep.habitation:
        savedAnswers = savedAnswers.copyWith(habitation: draftHabitation);
        if (savedAnswers.villeRecherche == null && draftHabitation != null) {
          draftVilleRecherche = draftHabitation;
          draftVilleQuery = draftHabitation!.displayLabel;
        }
      case OnboardingQuestionnaireStep.situation:
        savedAnswers = savedAnswers.copyWith(situation: draftSituation);
      case OnboardingQuestionnaireStep.objectifs:
        savedAnswers = savedAnswers.copyWith(objectifs: Set.of(draftObjectifs));
      case OnboardingQuestionnaireStep.domaine:
        savedAnswers = savedAnswers.copyWith(
          domaine: draftDomaine.trim(),
          domaineInconnu: false,
        );
      case OnboardingQuestionnaireStep.villeRecherche:
        savedAnswers = savedAnswers.copyWith(
          villeRecherche: draftVilleRecherche,
          rayonKm: draftRayonKm,
        );
      case OnboardingQuestionnaireStep.freins:
        savedAnswers = savedAnswers.copyWith(freins: Set.of(draftFreins));
      case OnboardingQuestionnaireStep.loader:
        return;
    }
    await _saveAnswers(savedAnswers);
  }

  void _goNext() {
    final next = step.next;
    if (next == null) return;
    // Loader is only useful while generate() runs; otherwise finish immediately.
    if (next == OnboardingQuestionnaireStep.loader &&
        (skipActionPlanGeneration || !savedAnswers.canGenerateActionPlan)) {
      _onFinishWithoutGeneration?.call(savedAnswers);
      return;
    }
    step = next;
    _tracker?.trackStepScreen(step);
    if (step == OnboardingQuestionnaireStep.villeRecherche) {
      _prefillVilleFromHabitation();
    }
    geolocationError = null;
    notifyListeners();
  }

  void _prefillVilleFromHabitation() {
    final suggested = savedAnswers.villeRecherche ?? savedAnswers.habitation ?? draftHabitation;
    draftVilleRecherche = suggested;
    draftVilleQuery = suggested?.displayLabel ?? '';
    draftRayonKm = savedAnswers.rayonKm;
  }

  /// Returns true if the form should close (logout).
  bool goBack() {
    if (step == OnboardingQuestionnaireStep.loader) return false;
    final previous = step.previous;
    if (previous == null) return true;
    _tracker?.trackStepEvent(AnalyticsEventNames.questionnaireStepBackAction, step);
    step = previous;
    _tracker?.trackStepScreen(step);
    _reloadDraftForStep(step);
    geolocationError = null;
    notifyListeners();
    return false;
  }

  void setGeolocating(bool value) {
    isGeolocating = value;
    if (value) geolocationError = null;
    notifyListeners();
  }

  void setGeolocationError(String? message) {
    isGeolocating = false;
    geolocationError = message;
    notifyListeners();
  }

  void startGeolocation() {
    setGeolocating(true);
    _tracker?.trackStepEvent(AnalyticsEventNames.questionnaireGeolocationRequestedAction, step);
  }

  void succeedGeolocation() {
    setGeolocating(false);
    _tracker?.trackStepEvent(AnalyticsEventNames.questionnaireGeolocationSucceededAction, step);
  }

  void failGeolocation(OnboardingQuestionnaireGeolocationFailure failure) {
    setGeolocationError(Strings.onboardingQuestionnaireGeolocateError);
    _tracker?.trackEvent(
      AnalyticsEventNames.questionnaireGeolocationFailedAction,
      name: failure.label,
      value: step.questionnaireIndex,
    );
  }
}
