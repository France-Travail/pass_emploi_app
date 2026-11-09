import 'package:flutter/material.dart';
import 'package:pass_emploi_app/widgets/slider/slider_focus_outline.dart';

/// Curseur DSFR restitué comme un seul composant ajustable, atteignable au clavier.
///
/// - Le Slider du DSFR restitue sa valeur en pourcentage et son libellé est séparé : on expose un seul composant
///   ajustable avec libellé, valeur lisible (en kilomètres par exemple) et bornes min/max.
/// - A11y 8.5 : prise de focus visible (contour DSFR, voir [SliderFocusOutline]).
/// - A11y 5.2 (iOS, contre-visite Access42 du 06/11/2026) : l'accès complet au clavier d'iOS n'atteint que les
///   éléments qui ont une action « toucher ». Cette action donne le focus clavier au curseur.
class SliderSemantics extends StatefulWidget {
  const SliderSemantics({
    super.key,
    required this.label,
    required this.value,
    required this.increasedValue,
    required this.decreasedValue,
    required this.hint,
    required this.onIncrease,
    required this.onDecrease,
    required this.child,
  });

  final String label;
  final String value;
  final String increasedValue;
  final String decreasedValue;
  final String hint;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  /// Le curseur (DsfrSlider).
  final Widget child;

  @override
  State<SliderSemantics> createState() => _SliderSemanticsState();
}

class _SliderSemanticsState extends State<SliderSemantics> {
  final _outlineFocusNode = FocusNode(debugLabel: 'SliderSemantics');

  @override
  void dispose() {
    _outlineFocusNode.dispose();
    super.dispose();
  }

  // DsfrSlider (flutter_dsfr 0.5.0) n'accepte pas de FocusNode : on donne le focus au premier élément focalisable
  // qu'il contient, le Slider Material.
  void _focusSlider() => _outlineFocusNode.traversalDescendants.firstOrNull?.requestFocus();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      slider: true,
      label: widget.label,
      value: widget.value,
      increasedValue: widget.increasedValue,
      decreasedValue: widget.decreasedValue,
      hint: widget.hint,
      onIncrease: widget.onIncrease,
      onDecrease: widget.onDecrease,
      onTap: _focusSlider,
      excludeSemantics: true,
      child: SliderFocusOutline(focusNode: _outlineFocusNode, child: widget.child),
    );
  }
}
