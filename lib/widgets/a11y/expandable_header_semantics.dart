import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';

/// En-tête d'accordéon : un seul bouton dont l'état (développé / réduit) est restitué et mis à jour (A11y 5.5).
///
/// Les moteurs Flutter Android et iOS (3.35) ignorent la propriété `expanded`. L'état est donc donné dans le texte :
/// - Android : à la fin du nom (« Informations légales, réduit, Bouton »), dans une région « live » : TalkBack relit
///   l'élément dès que l'état change, sans annonce (dépréciée depuis Android 16) ;
/// - iOS : en valeur (« Informations légales, réduit, bouton »), et annoncé au changement.
///
/// À revoir lors d'une montée de version de Flutter qui restituerait `expanded` nativement (éviter la double lecture).
class ExpandableHeaderSemantics extends StatefulWidget {
  const ExpandableHeaderSemantics({
    super.key,
    required this.label,
    required this.expanded,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<ExpandableHeaderSemantics> createState() => _ExpandableHeaderSemanticsState();
}

class _ExpandableHeaderSemanticsState extends State<ExpandableHeaderSemantics> {
  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  void didUpdateWidget(ExpandableHeaderSemantics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isAndroid && oldWidget.expanded != widget.expanded) A11yUtils.announce(_state);
  }

  String get _state => widget.expanded ? Strings.a11yExpanded : Strings.a11yCollapsed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      liveRegion: _isAndroid,
      label: _isAndroid ? '${widget.label}, $_state' : widget.label,
      value: _isAndroid ? null : _state,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: widget.child,
    );
  }
}
