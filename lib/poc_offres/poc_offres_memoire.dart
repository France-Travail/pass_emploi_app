import 'package:flutter/foundation.dart';
import 'package:pass_emploi_app/poc_offres/poc_offres_modeles.dart';

// Gardé en mémoire le temps de la démo : rien n'est écrit sur le téléphone ni envoyé à un serveur.
class PocOffresMemoire {
  PocOffresMemoire._();

  static final instance = PocOffresMemoire._();

  final suivis = ValueNotifier<Set<String>>(const {});
  final _consultations = <String, DateTime>{};
  final _candidatures = <String, DateTime>{};
  final recherchesBenevolat = <PocCriteresBenevolat>[];
  final recherchesAlternance = <PocCriteresMetier>[];
  final recherchesFormation = <PocCriteresMetier>[];

  bool estSuivi(String id) => suivis.value.contains(id);

  void basculerSuivi(String id) {
    suivis.value = estSuivi(id) ? ({...suivis.value}..remove(id)) : {...suivis.value, id};
  }

  DateTime? derniereConsultation(String id) => _consultations[id];

  void noterConsultation(String id) => _consultations[id] = DateTime.now();

  DateTime? dateCandidature(String id) => _candidatures[id];

  void noterCandidature(String id) => _candidatures[id] = DateTime.now();

  static void retenirRecherche<T>(List<T> recherches, T criteres) {
    recherches.remove(criteres);
    recherches.insert(0, criteres);
    if (recherches.length > 3) recherches.removeRange(3, recherches.length);
  }
}
