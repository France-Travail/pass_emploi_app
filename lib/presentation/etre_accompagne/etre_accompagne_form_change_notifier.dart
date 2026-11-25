import 'package:flutter/foundation.dart';
import 'package:pass_emploi_app/models/onboarding_questionnaire_answers.dart';
import 'package:pass_emploi_app/models/structure_accompagnement.dart';
import 'package:pass_emploi_app/ui/strings.dart';

/// Formulaire « Être accompagné » : un code postal, la commune quand ce code postal en couvre plusieurs, et la
/// structure. Il part de la commune d'habitation du questionnaire, sans jamais la modifier.
///
/// La commune envoyée est toujours la commune entière (Paris, pas Paris 14e Arrondissement) avec le code postal saisi :
/// le back de pass emploi retrouve lui-même l'arrondissement à partir du code postal.
class EtreAccompagneFormChangeNotifier extends ChangeNotifier {
  static final _formatCodePostal = RegExp(r'^\d{5}$');

  String codePostal;

  /// Communes du code postal ; `null` tant qu'elles ne sont pas connues (recherche à lancer, en cours ou échouée).
  List<QuestionnaireCommune>? communes;
  QuestionnaireCommune? commune;
  StructuresAccompagnementCommuneOrigine origine;
  StructureAccompagnementType? type;
  String? codePostalError;
  String? communeError;
  bool isGeolocating = false;
  bool geolocationFailed = false;

  EtreAccompagneFormChangeNotifier({QuestionnaireCommune? initialCommune}) : this._(_communeConnue(initialCommune));

  EtreAccompagneFormChangeNotifier._(QuestionnaireCommune? initialCommune)
    : commune = initialCommune,
      codePostal = initialCommune?.codePostal ?? '',
      origine = initialCommune != null
          ? StructuresAccompagnementCommuneOrigine.questionnaire
          : StructuresAccompagnementCommuneOrigine.saisie;

  /// Paris, Lyon ou Marseille entier n'a pas de code postal fiable (le premier de la ville) : rien n'est pré-rempli.
  static QuestionnaireCommune? _communeConnue(QuestionnaireCommune? commune) {
    if (commune == null || commune.codePostal == null || commune.isCommuneAvecArrondissements) return null;
    return commune.communeEntiere;
  }

  /// « Voir les structures » reste désactivé tant qu'aucune structure n'est choisie.
  bool get canSubmit => type != null;

  bool get isCodePostalComplete => _formatCodePostal.hasMatch(codePostal);

  /// Les communes du code postal sont à (re)chercher avant de lancer la recherche.
  bool get needsCommunes => isCodePostalComplete && communes == null;

  /// Le choix de la commune n'apparaît que si le code postal en couvre plusieurs.
  bool get showCommuneChoice => (communes?.length ?? 0) > 1;

  void updateCodePostal(String value) {
    if (value == codePostal) return;
    codePostal = value;
    communes = null;
    commune = null;
    origine = StructuresAccompagnementCommuneOrigine.saisie;
    codePostalError = null;
    communeError = null;
    notifyListeners();
  }

  /// Résultat de la recherche des communes de [forCodePostal] : `null` si elle a échoué.
  void setCommunes(String forCodePostal, List<QuestionnaireCommune>? result) {
    // Réponse pour un code postal déjà modifié.
    if (forCodePostal != codePostal) return;
    communes = result;
    if (result != null) {
      final current = commune;
      final kept = current == null ? null : result.where((c) => c.code == current.code).firstOrNull;
      commune = kept ?? (result.length == 1 ? result.single : null);
    }
    notifyListeners();
  }

  void selectCommune(QuestionnaireCommune selected) {
    if (selected.code != commune?.code) origine = StructuresAccompagnementCommuneOrigine.saisie;
    commune = selected;
    communeError = null;
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

  /// Commune trouvée par géolocalisation (un arrondissement à Paris, Lyon ou Marseille) : son code postal remplace la
  /// saisie.
  void applyGeolocatedCommune(QuestionnaireCommune found) {
    final entiere = found.communeEntiere;
    codePostal = entiere.codePostal ?? '';
    commune = entiere.codePostal != null ? entiere : null;
    communes = null;
    origine = StructuresAccompagnementCommuneOrigine.geolocalisation;
    codePostalError = null;
    communeError = null;
    notifyListeners();
  }

  /// Renvoie la recherche à lancer, ou `null` en affichant l'erreur sous le champ ou sous le choix de la commune.
  StructuresAccompagnementRequest? submit() {
    final selectedType = type;
    if (selectedType == null) return null;
    if (!isCodePostalComplete) return _failCodePostal(Strings.etreAccompagneErrorCodePostalFormat);
    final communesDuCodePostal = communes;
    final selectedCommune = commune;
    // Sans réponse de l'API géo, la commune du questionnaire ou de la géolocalisation reste valable.
    if (communesDuCodePostal == null && selectedCommune == null) {
      return _failCodePostal(Strings.etreAccompagneErrorCodePostalVerification);
    }
    if (communesDuCodePostal != null && communesDuCodePostal.isEmpty) {
      return _failCodePostal(Strings.etreAccompagneErrorCodePostalInconnu);
    }
    if (selectedCommune == null) {
      communeError = Strings.etreAccompagneErrorCommuneChoice;
      notifyListeners();
      return null;
    }
    codePostalError = null;
    communeError = null;
    notifyListeners();
    return StructuresAccompagnementRequest(type: selectedType, commune: selectedCommune, origine: origine);
  }

  StructuresAccompagnementRequest? _failCodePostal(String message) {
    codePostalError = message;
    notifyListeners();
    return null;
  }
}
