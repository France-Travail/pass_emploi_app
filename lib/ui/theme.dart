import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

/// Thème de l'application, aligné sur le DSFR en clair et en sombre.
///
/// Les DsfrColorDecisions demandent un BuildContext : chaque couleur reprend donc les jetons de la décision citée.
/// Roues de chargement, calendrier, curseur et poignées de sélection prennent `colorScheme.primary` (bleu France).
class PassEmploiTheme {
  static final data = _theme(Brightness.light);
  static final darkData = _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    Color pick(Color light, Color dark) => brightness == Brightness.light ? light : dark;

    // backgroundActionHighBlueFrance, textActionHighBlueFrance
    final blueFrance = pick(DsfrColors.blueFranceSun113, DsfrColors.blueFrance625);
    // textInvertedBlueFrance
    final onBlueFrance = pick(DsfrColors.blueFrance975, DsfrColors.blueFranceSun113);
    // backgroundActionLowBlueFrance
    final blueFranceLow = pick(DsfrColors.blueFrance925, DsfrColors.blueFrance125);
    // textDefaultError
    final error = pick(DsfrColors.error425, DsfrColors.error625);
    // backgroundDefaultGrey
    final background = pick(DsfrColors.grey1000, DsfrColors.grey50);
    // backgroundRaisedGrey
    final raised = pick(DsfrColors.grey1000, DsfrColors.grey75);

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: blueFrance,
        onPrimary: onBlueFrance,
        primaryContainer: blueFranceLow,
        onPrimaryContainer: blueFrance,
        secondary: blueFrance,
        onSecondary: onBlueFrance,
        secondaryContainer: blueFranceLow,
        onSecondaryContainer: blueFrance,
        error: error,
        // textInvertedGrey
        onError: pick(DsfrColors.grey1000, DsfrColors.grey50),
        // backgroundContrastError
        errorContainer: pick(DsfrColors.error950, DsfrColors.error100),
        onErrorContainer: error,
        surface: background,
        // textTitleGrey
        onSurface: pick(DsfrColors.grey50, DsfrColors.grey1000),
        // textDefaultGrey
        onSurfaceVariant: pick(DsfrColors.grey200, DsfrColors.grey850),
        surfaceContainerLow: raised,
        surfaceContainer: raised,
        // backgroundOverlapGrey : fond des fenêtres et du calendrier
        surfaceContainerHigh: pick(DsfrColors.grey1000, DsfrColors.grey100),
        // backgroundContrastGrey
        surfaceContainerHighest: pick(DsfrColors.grey950, DsfrColors.grey100),
        // textMentionGrey
        outline: pick(DsfrColors.grey425, DsfrColors.grey625),
        // borderDefaultGrey
        outlineVariant: pick(DsfrColors.grey900, DsfrColors.grey175),
        inverseSurface: pick(DsfrColors.grey200, DsfrColors.grey850),
        onInverseSurface: background,
        inversePrimary: pick(DsfrColors.blueFrance625, DsfrColors.blueFranceSun113),
        surfaceTint: Colors.transparent,
      ),
    );
  }
}
