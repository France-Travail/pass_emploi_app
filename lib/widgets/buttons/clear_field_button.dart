import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

/// Bouton « × » qui efface un champ de saisie.
///
/// A11y (audit RAAM du 15/10/2026) :
/// - 5.1 : bouton distinct, nommé par [tooltip] (ex. « Effacer le champ « Ville ou code postal » »), atteignable par
///   balayage avec TalkBack et VoiceOver, au clavier et au toucher ;
/// - 8.5 : prise de focus visible par le contour DSFR, à la place du voile gris de Material (1,3:1).
class ClearFieldButton extends StatefulWidget {
  const ClearFieldButton({super.key, required this.tooltip, required this.onPressed, this.size = 40});

  final String tooltip;
  final VoidCallback onPressed;

  /// Zone tactile minimale (côté du carré).
  final double size;

  @override
  State<ClearFieldButton> createState() => _ClearFieldButtonState();
}

class _ClearFieldButtonState extends State<ClearFieldButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return DsfrFocusWidget(
      isFocused: _focused,
      borderRadius: BorderRadius.all(Radius.circular(widget.size / 2)),
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onFocusChange: (focused) => setState(() => _focused = focused),
        child: IconButton(
          tooltip: widget.tooltip,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: widget.size, minHeight: widget.size),
          focusColor: DsfrColorDecisions.backgroundTransparent(context),
          icon: Icon(
            DsfrIcons.systemCloseLine,
            size: 16,
            color: DsfrColorDecisions.textDefaultGrey(context),
          ),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
