import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

extension GlobayKeyA11yExt on GlobalKey {
  void requestA11yFocus() {
    currentContext?.findRenderObject()?.sendSemanticsEvent(FocusSemanticEvent());
  }

  void requestFocusDelayed({Duration? duration}) {
    Future.delayed(duration ?? Duration(milliseconds: 100), () {
      currentContext?.findRenderObject()?.sendSemanticsEvent(FocusSemanticEvent());
    });
  }
}

extension FocusNodeA11yExt on FocusNode {
  /// Déplace le focus clavier puis notifie le lecteur d'écran (nom, rôle, valeur).
  void requestFocusWithA11y({Duration? delay}) {
    requestFocus();
    Future.delayed(delay ?? const Duration(milliseconds: 100), () {
      context?.findRenderObject()?.sendSemanticsEvent(FocusSemanticEvent());
    });
  }
}

/// Déplace le focus du lecteur d'écran sur [child] à son affichage.
///
/// Crée un nœud sémantique dédié (`container`) : à placer AU-DESSUS d'un `Semantics(header: true)`,
/// jamais en dessous, sinon le texte est isolé dans ce nœud et perd son rôle d'en-tête.
class AutoFocusA11y extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Duration? duration;

  const AutoFocusA11y({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration,
  });

  @override
  State<AutoFocusA11y> createState() => _AutoFocusA11yState();
}

class _AutoFocusA11yState extends State<AutoFocusA11y> {
  final GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => globalKey.requestFocusDelayed(duration: widget.duration));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le focus doit viser un nœud sémantique propre au widget : sans `container`, l'événement
    // remonte au premier ancêtre qui en possède un (la page) et le focus ne se déplace pas.
    return Semantics(
      key: globalKey,
      container: true,
      explicitChildNodes: true,
      child: widget.child,
    );
  }
}
