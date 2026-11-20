import 'package:flutter/widgets.dart';

/// Ajoute le nom d'un groupe de choix à la fin du nom accessible d'un choix (A11y 9.6, audit RAAM).
///
/// Une personne aveugle peut atteindre un choix sans avoir lu la question qui le précède : le nom du choix doit
/// reprendre celle-ci (« J'ai postulé, Où en es-tu ? »). À réserver aux composants qui ne permettent pas de
/// fournir ce nom eux-mêmes (radios du DSFR) : le rôle, l'état et les actions du choix sont conservés, et le nom
/// commence toujours par le libellé visible.
class GroupLabelSemantics extends StatelessWidget {
  const GroupLabelSemantics({super.key, required this.groupLabel, required this.child});

  final String groupLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Stack(
        // Le choix garde exactement les contraintes de mise en page qu'il recevait, et son contour de focus n'est
        // pas rogné.
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          child,
          // Nœud sans taille, fusionné après le choix : seul son libellé compte. Il est un nœud à part, placé en bas
          // à droite, pour être lu après le libellé du choix, que celui-ci fournisse ou non son propre nœud.
          Positioned(
            right: 0,
            bottom: 0,
            child: Semantics(container: true, label: groupLabel, child: const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}
