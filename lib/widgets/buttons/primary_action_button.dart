import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';

class PrimaryActionButton extends StatelessWidget {
  final Color backgroundColor;
  final Color disabledBackgroundColor;
  final Color textColor;
  final Color? rippleColor;
  final Color? iconColor;
  final IconData? icon;
  final String label;
  final bool withShadow;
  final VoidCallback? onPressed;
  final double? fontSize;
  final double iconSize;
  final double iconRightPadding;
  final double heightPadding;
  final double widthPadding;

  PrimaryActionButton({
    Key? key,
    Color? backgroundColor,
    this.disabledBackgroundColor = AppColors.primaryWithAlpha50,
    this.textColor = Colors.white,
    this.rippleColor = AppColors.primaryDarken,
    this.iconColor = Colors.white,
    this.withShadow = true,
    this.icon,
    this.onPressed,
    required this.label,
    this.fontSize,
    this.iconSize = Dimens.icon_size_m,
    this.iconRightPadding = 12,
    this.heightPadding = 12,
    this.widthPadding = 20,
  })  : backgroundColor = backgroundColor ?? AppColors.primary,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final double leftPadding = icon != null ? 12 : 20;
    final baseTextStyle = TextStyles.textPrimaryButton;
    final usedTextStyle = fontSize != null ? baseTextStyle.copyWith(fontSize: fontSize) : baseTextStyle;
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(textColor),
        textStyle: MaterialStateProperty.all(usedTextStyle),
        backgroundColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          return states.contains(MaterialState.disabled) ? disabledBackgroundColor : backgroundColor;
        }),
        elevation: MaterialStateProperty.resolveWith((states) {
          return (states.contains(MaterialState.disabled) || !withShadow) ? 0 : 10;
        }),
        alignment: Alignment.center,
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(200)))),
        overlayColor: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.pressed)) {
              return rippleColor;
            }
            if (states.contains(MaterialState.focused)) {
              return rippleColor;
            }
            return null;
          },
        ),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: EdgeInsets.fromLTRB(leftPadding, heightPadding, widthPadding, heightPadding),
        child: _getRow(),
      ),
    );
  }

  Widget _getRow() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (icon != null)
          Padding(
            padding: EdgeInsets.only(right: iconRightPadding),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
          ),
        Text(
          label,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
