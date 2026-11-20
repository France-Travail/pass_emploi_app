import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/utils/debouncer.dart';

class DebounceTextFormField extends StatelessWidget {
  final String heroTag;
  final String? initialValue;
  final String? label;
  final String? hintText;
  final Function(String value)? onChanged;
  final Function(String value)? onFieldSubmitted;

  /// A11y 9.12 : nature de la saisie (inputType Android). Texte libre par défaut, jamais « nom de personne » :
  /// métier, mots clés et localisation ne sont pas des noms.
  final TextInputType keyboardType;
  final Debouncer _debouncer = Debouncer(duration: Duration(milliseconds: 200));

  DebounceTextFormField({
    required this.heroTag,
    required this.initialValue,
    this.label,
    this.hintText,
    this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          // A11y 5.1 : le titre forme son propre nœud ; fusionné au champ, il le faisait annoncer « Titre ».
          Semantics(
            container: true,
            headingLevel: 2,
            child: Text(
              label!,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textLabelGrey(context)),
            ),
          ),
          if (hintText != null) ...[
            const SizedBox(height: DsfrSpacings.s1v),
            ExcludeSemantics(
              child: Text(
                hintText!,
                style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textMentionGrey(context)),
              ),
            ),
          ],
          const SizedBox(height: DsfrSpacings.s1w),
        ],
        Hero(
          tag: heroTag,
          child: Material(
            type: MaterialType.transparency,
            child: DsfrInputHeadless(
              initialValue: initialValue,
              autofocus: true,
              keyboardType: keyboardType,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: onFieldSubmitted,
              onChanged: (value) {
                if (onChanged != null) _debouncer.run(() => onChanged!(value));
              },
            ),
          ),
        ),
      ],
    );
  }
}
