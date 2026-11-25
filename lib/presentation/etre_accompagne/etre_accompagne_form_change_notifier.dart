import 'package:flutter/foundation.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';
import 'package:pass_emploi_app/ui/strings.dart';

/// Formulaire « Être accompagné ». Il part de la commune d'habitation du questionnaire, sans jamais la modifier.
class EtreAccompagneFormChangeNotifier extends ChangeNotifier {
  String query;
  QuestionnaireCommune? commune;
  StructuresAccompagnementCommuneOrigine origine;
  StructureAccompagnementType? type;
  String? error;
  bool isGeolocating = false;
  bool geolocationFailed = false;

  EtreAccompagneFormChangeNotifier({QuestionnaireCommune? initialCommune})
    : commune = initialCommune,
      query = initialCommune?.displayLabel ?? '',
      origine = initialCommune != null
          ? StructuresAccompagnementCommuneOrigine.questionnaire
          : StructuresAccompagnementCommuneOrigine.saisie;

  /// « Voir les structures » reste désactivé tant qu'aucune structure n'est choisie.
  bool get canSubmit => type != null;

  void updateQuery(String value) {
    query = value;
    // Modifier le texte annule le choix fait dans la liste.
    if (commune != null && value != commune!.displayLabel) commune = null;
    error = null;
    notifyListeners();
  }

  void selectCommune(QuestionnaireCommune selected, StructuresAccompagnementCommuneOrigine selectedOrigine) {
    commune = selected;
    query = selected.displayLabel;
    origine = selectedOrigine;
    error = null;
    geolocationFailed = false;
    notifyListeners();
  }

  void selectType(StructureAccompagnementType selected) {
    type = selected;
    notifyListeners();
  }

  void startGeolocation() {
    isGeolocating = true;
    geolocationFailed = false;
    notifyListeners();
  }

  void endGeolocation({required bool failed}) {
    isGeolocating = false;
    geolocationFailed = failed;
    notifyListeners();
  }

  /// Renvoie la recherche à lancer, ou `null` en affichant l'erreur sous le champ.
  StructuresAccompagnementRequest? submit() {
    final selectedType = type;
    if (selectedType == null) return null;
    final selectedCommune = commune;
    if (selectedCommune == null || selectedCommune.codePostal == null) {
      return _fail(Strings.etreAccompagneErrorCommune);
    }
    if (selectedCommune.isCommuneAvecArrondissements) {
      return _fail(Strings.etreAccompagneErrorArrondissement);
    }
    error = null;
    notifyListeners();
    return StructuresAccompagnementRequest(type: selectedType, commune: selectedCommune, origine: origine);
  }

  StructuresAccompagnementRequest? _fail(String message) {
    error = message;
    notifyListeners();
    return null;
  }
}
