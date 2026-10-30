import 'package:flutter/foundation.dart';
import 'package:pass_emploi_app/poc_orientation/rome_models.dart';

// Gardés en mémoire le temps de la démo : rien n'est écrit sur le téléphone ni envoyé à un serveur.
class MesMetiers extends ValueNotifier<List<RomeMetierResume>> {
  MesMetiers._() : super(const []);

  static final instance = MesMetiers._();

  bool contient(String code) => value.any((metier) => metier.code == code);

  void basculer(RomeMetierResume metier) {
    value = contient(metier.code) ? value.where((m) => m.code != metier.code).toList() : [...value, metier];
  }
}
