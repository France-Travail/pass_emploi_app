import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/utils/date_extensions.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';

/// Champ date DSFR qui ouvre le calendrier : apparence de [DsfrDateInput], restitué comme un seul bouton.
///
/// A11y (audit RAAM) : [DsfrDateInput] est un champ de saisie en lecture seule, sans action « toucher », dont
/// l'étiquette est posée sur le groupe et non sur le champ : TalkBack lisait l'étiquette à part, puis un champ sans
/// nom (« désactivé » le cas échéant). Comme « Autre date » (voir `OtherDateButton`), il est restitué en un seul
/// élément :
/// - 5.1 : rôle bouton, puisqu'il ouvre le calendrier ; état désactivé sur ce même élément ;
/// - 9.1 / 9.2 : nom = étiquette visible, suivie de [groupLabel] (A11y 9.6) et du message d'erreur (A11y 9.9) ;
/// - la date choisie est sa valeur, lue en toutes lettres ; [hintText] est son indication.
class DsfrDatePickerField extends StatelessWidget {
  const DsfrDatePickerField({
    super.key,
    required this.label,
    required this.controller,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
    required this.onChanged,
    this.groupLabel,
    this.hintText,
    this.enabled = true,
    this.composantState = const DsfrComponentState.none(),
  });

  final String label;

  /// Nom du groupe ou de la section, repris dans le nom accessible après l'étiquette (A11y 9.6).
  final String? groupLabel;
  final String? hintText;

  /// Texte affiché dans le champ, au format jj/mm/aaaa.
  final TextEditingController controller;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialDate;
  final bool enabled;
  final DsfrComponentState composantState;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final errorMessage = composantState.state == DsfrComponentStateEnum.error ? composantState.text : null;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, dateValue, _) => Semantics(
        container: true,
        button: true,
        enabled: enabled,
        label: [label, groupLabel, errorMessage].whereType<String>().where((part) => part.isNotEmpty).join(', '),
        value: dateValue.text.isEmpty ? null : dateValue.text.toDateForScreenReaders(),
        hint: hintText,
        onTap: enabled ? () => _pickDate(context) : null,
        excludeSemantics: true,
        child: DsfrDateInput(
          label: label,
          hintText: hintText,
          controller: controller,
          enabled: enabled,
          firstDate: firstDate,
          lastDate: lastDate,
          initialDate: initialDate,
          locale: const Locale('fr', 'FR'),
          composantState: composantState,
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// Même calendrier que celui ouvert au toucher par [DsfrDateInput], pour l'action « toucher » du lecteur d'écran.
  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('fr', 'FR'),
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked == null) return;
    controller.text = picked.toDay();
    onChanged(picked);
  }
}
