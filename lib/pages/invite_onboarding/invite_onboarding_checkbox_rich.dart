import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

/// Case à cocher au format « riche » (bordure, libellé, illustration),
/// alignée sur le [DsfrRadioRichButton] du DSFR Flutter.
class InviteOnboardingCheckboxRich extends StatelessWidget {
  const InviteOnboardingCheckboxRich({
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
  Widget build(BuildContext context) {
    final canInteract = enabled && onChanged != null;
    return Material(
      color: DsfrColorDecisions.backgroundTransparent(context),
      child: InkWell(
        onTap: canInteract ? () => onChanged!(!value) : null,
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
    );
  }
}
