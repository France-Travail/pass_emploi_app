import 'package:flutter/foundation.dart';
import 'package:pass_emploi_app/models/invite_onboarding_answers.dart';
import 'package:pass_emploi_app/repositories/invite_onboarding_repository.dart';

enum InviteOnboardingStep {
  prenom,
  dateNaissance,
  habitation,
  situation,
  objectifs,
  domaine,
  villeRecherche,
  freins,
  loader;

  bool get isLoader => this == InviteOnboardingStep.loader;

  int get questionnaireIndex => index + 1;

  static const int questionnaireCount = 8;

  InviteOnboardingStep? get previous {
    if (index == 0) return null;
    return InviteOnboardingStep.values[index - 1];
  }

  InviteOnboardingStep? get next {
    if (index >= InviteOnboardingStep.values.length - 1) return null;
    return InviteOnboardingStep.values[index + 1];
  }
}

class InviteOnboardingFormChangeNotifier extends ChangeNotifier {
  final InviteOnboardingRepository _repository;

  InviteOnboardingStep step = InviteOnboardingStep.prenom;
  InviteOnboardingAnswers savedAnswers = const InviteOnboardingAnswers();

  String draftPrenom = '';
  String draftBirthDay = '';
  String draftBirthMonth = '';
  String draftBirthYear = '';
  InviteCommune? draftHabitation;
  String draftHabitationQuery = '';
  InviteSituation? draftSituation;
  Set<InviteObjectif> draftObjectifs = {};
  String draftDomaine = '';
  InviteCommune? draftVilleRecherche;
  String draftVilleQuery = '';
  int draftRayonKm = 20;
  Set<InviteFrein> draftFreins = {};

  bool isLoading = true;
  bool isGeolocating = false;
  String? geolocationError;

  InviteOnboardingFormChangeNotifier(this._repository);

  Future<void> init() async {
    isLoading = true;
    notifyListeners();
    savedAnswers = await _repository.getAnswers();
    _hydrateDraftsFromSaved();
    step = InviteOnboardingStep.prenom;
    isLoading = false;
    notifyListeners();
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

  void _reloadDraftForStep(InviteOnboardingStep target) {
    switch (target) {
      case InviteOnboardingStep.prenom:
        draftPrenom = savedAnswers.prenom ?? '';
      case InviteOnboardingStep.dateNaissance:
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
      case InviteOnboardingStep.habitation:
        draftHabitation = savedAnswers.habitation;
        draftHabitationQuery = savedAnswers.habitation?.displayLabel ?? '';
      case InviteOnboardingStep.situation:
        draftSituation = savedAnswers.situation;
      case InviteOnboardingStep.objectifs:
        draftObjectifs = Set.of(savedAnswers.objectifs);
      case InviteOnboardingStep.domaine:
        draftDomaine = savedAnswers.domaine ?? '';
      case InviteOnboardingStep.villeRecherche:
        _prefillVilleFromHabitation();
      case InviteOnboardingStep.freins:
        draftFreins = Set.of(savedAnswers.freins);
      case InviteOnboardingStep.loader:
        break;
    }
  }

  bool get canContinue => switch (step) {
        InviteOnboardingStep.prenom => draftPrenom.trim().isNotEmpty,
        InviteOnboardingStep.dateNaissance => parsedBirthDate != null,
        InviteOnboardingStep.habitation => draftHabitation != null,
        InviteOnboardingStep.situation => draftSituation != null,
        InviteOnboardingStep.objectifs => draftObjectifs.isNotEmpty,
        InviteOnboardingStep.domaine => draftDomaine.trim().isNotEmpty,
        InviteOnboardingStep.villeRecherche => draftVilleRecherche != null,
        InviteOnboardingStep.freins => draftFreins.isNotEmpty,
        InviteOnboardingStep.loader => false,
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

  void selectHabitation(InviteCommune commune) {
    draftHabitation = commune;
    draftHabitationQuery = commune.displayLabel;
    geolocationError = null;
    notifyListeners();
  }

  void updateSituation(InviteSituation situation) {
    draftSituation = situation;
    notifyListeners();
  }

  Future<void> selectSituationAndContinue(InviteSituation situation) async {
    updateSituation(situation);
    await continueStep();
  }

  void toggleObjectif(InviteObjectif objectif) {
    final next = Set<InviteObjectif>.of(draftObjectifs);
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

  void selectVilleRecherche(InviteCommune commune) {
    draftVilleRecherche = commune;
    draftVilleQuery = commune.displayLabel;
    geolocationError = null;
    notifyListeners();
  }

  void updateRayon(double value) {
    draftRayonKm = value.round();
    notifyListeners();
  }

  void toggleFrein(InviteFrein frein) {
    final next = Set<InviteFrein>.of(draftFreins);
    if (frein.isExclusive) {
      if (next.contains(frein)) {
        next.remove(frein);
      } else {
        next
          ..clear()
          ..add(frein);
      }
    } else {
      next.remove(InviteFrein.rienNeMeBloque);
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
    await _persistCurrentStep();
    _goNext();
  }

  Future<void> skipStep() async {
    await _clearCurrentStep();
    _goNext();
  }

  Future<void> _clearCurrentStep() async {
    switch (step) {
      case InviteOnboardingStep.prenom:
        draftPrenom = '';
        savedAnswers = savedAnswers.copyWith(clearPrenom: true);
      case InviteOnboardingStep.dateNaissance:
        draftBirthDay = '';
        draftBirthMonth = '';
        draftBirthYear = '';
        savedAnswers = savedAnswers.copyWith(clearDateNaissance: true);
      case InviteOnboardingStep.habitation:
        draftHabitation = null;
        draftHabitationQuery = '';
        savedAnswers = savedAnswers.copyWith(clearHabitation: true);
      case InviteOnboardingStep.situation:
        draftSituation = null;
        savedAnswers = savedAnswers.copyWith(clearSituation: true);
      case InviteOnboardingStep.objectifs:
        draftObjectifs = {};
        savedAnswers = savedAnswers.copyWith(objectifs: {});
      case InviteOnboardingStep.domaine:
        draftDomaine = '';
        savedAnswers = savedAnswers.copyWith(clearDomaine: true, domaineInconnu: false);
      case InviteOnboardingStep.villeRecherche:
        draftVilleRecherche = null;
        draftVilleQuery = '';
        savedAnswers = savedAnswers.copyWith(clearVilleRecherche: true);
      case InviteOnboardingStep.freins:
        draftFreins = {};
        savedAnswers = savedAnswers.copyWith(freins: {});
      case InviteOnboardingStep.loader:
        return;
    }
    await _repository.saveAnswers(savedAnswers);
  }

  Future<void> selectHabitationAndContinue(InviteCommune commune) async {
    selectHabitation(commune);
    await continueStep();
  }

  Future<void> selectVilleAndContinue(InviteCommune commune) async {
    selectVilleRecherche(commune);
    await continueStep();
  }

  Future<void> markDomaineUnknownAndContinue() async {
    savedAnswers = savedAnswers.copyWith(clearDomaine: true, domaineInconnu: true);
    await _repository.saveAnswers(savedAnswers);
    draftDomaine = '';
    _goNext();
  }

  Future<void> _persistCurrentStep() async {
    switch (step) {
      case InviteOnboardingStep.prenom:
        savedAnswers = savedAnswers.copyWith(prenom: draftPrenom.trim());
      case InviteOnboardingStep.dateNaissance:
        savedAnswers = savedAnswers.copyWith(dateNaissance: parsedBirthDate);
      case InviteOnboardingStep.habitation:
        savedAnswers = savedAnswers.copyWith(habitation: draftHabitation);
        if (savedAnswers.villeRecherche == null && draftHabitation != null) {
          draftVilleRecherche = draftHabitation;
          draftVilleQuery = draftHabitation!.displayLabel;
        }
      case InviteOnboardingStep.situation:
        savedAnswers = savedAnswers.copyWith(situation: draftSituation);
      case InviteOnboardingStep.objectifs:
        savedAnswers = savedAnswers.copyWith(objectifs: Set.of(draftObjectifs));
      case InviteOnboardingStep.domaine:
        savedAnswers = savedAnswers.copyWith(
          domaine: draftDomaine.trim(),
          domaineInconnu: false,
        );
      case InviteOnboardingStep.villeRecherche:
        savedAnswers = savedAnswers.copyWith(
          villeRecherche: draftVilleRecherche,
          rayonKm: draftRayonKm,
        );
      case InviteOnboardingStep.freins:
        savedAnswers = savedAnswers.copyWith(freins: Set.of(draftFreins));
      case InviteOnboardingStep.loader:
        return;
    }
    await _repository.saveAnswers(savedAnswers);
  }

  void _goNext() {
    final next = step.next;
    if (next == null) return;
    step = next;
    if (step == InviteOnboardingStep.villeRecherche) {
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
    if (step == InviteOnboardingStep.loader) return false;
    final previous = step.previous;
    if (previous == null) return true;
    step = previous;
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
}
