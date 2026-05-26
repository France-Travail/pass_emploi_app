import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/buttons/focused_border_builder.dart';

class ColoredActionButton extends StatelessWidget {
  final Color backgroundColor;
  final Color disabledBackgroundColor;
  final Color textColor;
  final Color? rippleColor;
  final String label;
  final bool withShadow;
  final VoidCallback? onPressed;
  final double? fontSize;

  const ColoredActionButton({
    super.key,
    required this.backgroundColor,
    required this.textColor,
    this.disabledBackgroundColor = AppColors.disabled,
    this.rippleColor,
    required this.label,
    this.withShadow = false,
    this.onPressed,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyles.textPrimaryButton.copyWith(
      color: textColor,
      fontSize: fontSize,
    );
    return FocusedBorderBuilder(
      builder: (focusNode) {
        return TextButton(
          focusNode: focusNode,
          style: ButtonStyle(
            padding: WidgetStateProperty.all(EdgeInsets.zero),
            foregroundColor: WidgetStateProperty.all(textColor),
            textStyle: WidgetStateProperty.all(textStyle),
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              return states.contains(WidgetState.disabled) ? disabledBackgroundColor : backgroundColor;
            }),
            elevation: WidgetStateProperty.resolveWith((states) {
              return (states.contains(WidgetState.disabled) || !withShadow) ? 0 : 10;
            }),
            overlayColor: WidgetStateProperty.all(rippleColor),
            alignment: Alignment.center,
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_base))),
            ),
          ),
          onPressed: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Margins.spacing_m, vertical: Margins.spacing_base),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
        );
      },
    );
  }
}
