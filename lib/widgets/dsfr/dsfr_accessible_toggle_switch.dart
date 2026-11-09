import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

/// [DsfrToggleSwitch] avec un état actif et une action « toucher » exposés aux lecteurs d'écran.
///
/// A11y 5.1 et 5.2 (contre-visite Access42 du 06/11/2026) : l'interrupteur de flutter_dsfr 0.5.0 n'expose que son
/// état basculé. Sur iOS, un interrupteur sans `enabled: true` est annoncé « estompé » par VoiceOver, et l'accès
/// complet au clavier n'atteint que les éléments qui ont une action « toucher ». Sur Android, l'interrupteur devient
/// aussi « cliquable » pour TalkBack.
///
/// À remplacer par [DsfrToggleSwitch] quand flutter_dsfr exposera lui-même `enabled` et `onTap`.
class DsfrAccessibleToggleSwitch extends StatelessWidget {
  const DsfrAccessibleToggleSwitch({
    super.key,
    required this.label,
    required this.value,
    this.labelLocation = DsfrToggleSwitchLabelLocation.right,
    this.enabled = true,
    this.onChanged,
    this.description,
    this.status,
    this.componentState = const DsfrComponentState.none(),
    this.semanticsLabel,
  });

  final String label;
  final bool value;
  final DsfrToggleSwitchLabelLocation labelLocation;
  final bool enabled;
  final ValueChanged<bool>? onChanged;
  final String? description;
  final String? status;
  final DsfrComponentState componentState;

  /// Texte lu avant l'étiquette et le statut de l'interrupteur.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final canToggle = enabled && onChanged != null;
    return Semantics(
      container: true,
      label: semanticsLabel,
      enabled: canToggle,
      onTap: canToggle ? () => onChanged(!value) : null,
      child: DsfrToggleSwitch(
        label: label,
        value: value,
        labelLocation: labelLocation,
        enabled: enabled,
        onChanged: onChanged,
        description: description,
        status: status,
        componentState: componentState,
      ),
    );
  }
}
