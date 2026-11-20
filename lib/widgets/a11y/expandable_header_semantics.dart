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
/// Android : la région « live » n'est active qu'à partir d'un changement d'état, et jusqu'à ce que le focus du
/// lecteur d'écran quitte l'en-tête. TalkBack lit une région « live » dès que son nom change, même sans focus, et le
/// moteur Flutter (3.47) traite la création du nœud comme un changement de nom : une région active dès l'affichage
/// ferait lire tous les en-têtes à l'arrivée sur l'écran, puis à chaque changement de nom (progression d'un objectif).
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

  /// Android : région « live » active (voir la documentation de la classe).
  bool _liveRegion = false;

  @override
  void didUpdateWidget(ExpandableHeaderSemantics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expanded == widget.expanded) return;
    if (_isAndroid) {
      _liveRegion = true;
    } else {
      A11yUtils.announce(_state);
    }
  }

  void _onLoseAccessibilityFocus() {
    if (_liveRegion) setState(() => _liveRegion = false);
  }

  String get _state => widget.expanded ? Strings.a11yExpanded : Strings.a11yCollapsed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      liveRegion: _isAndroid && _liveRegion,
      label: _isAndroid ? '${widget.label}, $_state' : widget.label,
      value: _isAndroid ? null : _state,
      onTap: widget.onTap,
      onDidLoseAccessibilityFocus: _isAndroid ? _onLoseAccessibilityFocus : null,
      excludeSemantics: true,
      child: widget.child,
    );
  }
}
