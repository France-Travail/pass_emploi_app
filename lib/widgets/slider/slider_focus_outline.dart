import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

/// Rend visible la prise de focus d'un curseur DSFR (A11y 8.5, audit RAAM du 15/10/2026).
///
/// Le Slider Material n'indique le focus que par un halo #F0ECF5 sur fond blanc (contraste 1,2:1). Le halo est retiré
/// et le curseur est entouré du contour de focus DSFR, comme les autres composants, quand il a le focus clavier.
class SliderFocusOutline extends StatelessWidget {
  const SliderFocusOutline({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(overlayColor: Colors.transparent),
      // Le Focus englobant ne prend pas le focus lui-même : il signale celui du curseur.
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        child: Builder(
          builder: (context) => DsfrFocusWidget(
            isFocused: Focus.of(context).hasFocus,
            child: child,
          ),
        ),
      ),
    );
  }
}
