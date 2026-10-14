import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class A11yUtils {
  static void announce(String text) {
    // delay is needed to avoid the enouncement to be cut by voiceover
    Future.delayed(
      Duration(milliseconds: 100),
      () => SemanticsService.announce(text, TextDirection.ltr),
    );
  }

  static bool withTextScale(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(1.0) > 1.0;
  }

  /// Facteur d'agrandissement appliqué à un texte de [fontSize], pour dimensionner un conteneur.
  /// Depuis Android 14 l'agrandissement n'est pas linéaire : `textScaler.scale(76)` traite 76 comme une
  /// taille de police et ne l'agrandit presque pas, il faut donc multiplier la dimension par ce facteur.
  static double textScaleFactor(BuildContext context, {double fontSize = 16}) {
    return MediaQuery.textScalerOf(context).scale(fontSize) / fontSize;
  }

  static bool withScreenReader(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Détecte le clavier via la vue plateforme : fiable même si un Scaffold ancêtre
  /// a déjà consommé [MediaQuery.viewInsetsOf].
  static bool isKeyboardVisible(BuildContext context) {
    final view = View.of(context);
    return view.viewInsets.bottom / view.devicePixelRatio > 0;
  }
}
