import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

/// Case à cocher au format « riche » (bordure, libellé, illustration),
/// alignée sur le [DsfrRadioRichButton] du DSFR Flutter.
class OnboardingQuestionnaireCheckboxRich extends StatefulWidget {
  const OnboardingQuestionnaireCheckboxRich({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.size,
    this.trailingIcon,
    this.enabled = true,
  }) : assert(size != DsfrComponentSize.lg);

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final DsfrComponentSize size;
  final Widget? trailingIcon;
  final bool enabled;

  @override
  State<OnboardingQuestionnaireCheckboxRich> createState() => _OnboardingQuestionnaireCheckboxRichState();
}

class _OnboardingQuestionnaireCheckboxRichState extends State<OnboardingQuestionnaireCheckboxRich>
    with MaterialStateMixin<OnboardingQuestionnaireCheckboxRich> {
  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final value = widget.value;
    final onChanged = widget.onChanged;
    final size = widget.size;
    final trailingIcon = widget.trailingIcon;
    final enabled = widget.enabled;
    final canInteract = enabled && onChanged != null;
    // A11y : case à cocher avec son libellé et son état ; l'illustration est décorative.
    return Semantics(
      container: true,
      enabled: enabled,
      checked: value,
      label: label,
      onTap: canInteract ? () => onChanged(!value) : null,
      excludeSemantics: true,
      // A11y 2.3 : contour de focus DSFR, comme sur DsfrRadioRichButton, à la place du voile gris de Material.
      child: DsfrFocusWidget(
        isFocused: isFocused,
        child: Material(
          color: DsfrColorDecisions.backgroundTransparent(context),
          child: InkWell(
            onTap: canInteract ? () => onChanged(!value) : null,
            focusColor: DsfrColorDecisions.backgroundTransparent(context),
            onFocusChange: updateMaterialState(WidgetState.focused),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(
                    color: value
                        ? DsfrColorDecisions.borderActiveBlueFrance(context)
                        : DsfrColorDecisions.borderDefaultGrey(context),
                    width: value ? 2 : 1,
                  ),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(DsfrSpacings.s2w),
                        child: Row(
                          spacing: DsfrSpacings.s1w,
                          children: [
                            DsfrCheckboxIcon(
                              value: value,
                              size: size,
                              enabled: enabled,
                            ),
                            Expanded(
                              child: Text(
                                label,
                                style: DsfrTextStyle.bodyMd(
                                  color: enabled
                                      ? DsfrColorDecisions.textLabelGrey(context)
                                      : DsfrColorDecisions.textDisabledGrey(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      VerticalDivider(
                        width: 0,
                        indent: DsfrSpacings.s1v,
                        endIndent: DsfrSpacings.s1v,
                      ),
                      SizedBox(
                        width: 88,
                        height: 88,
                        child: Center(child: trailingIcon),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
