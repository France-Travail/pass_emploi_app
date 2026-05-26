import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/buttons/focused_border_builder.dart';

class PrimaryActionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool withShadow;
  final VoidCallback? onPressed;
  final double? fontSize;
  final double iconSize;
  final double iconRightPadding;
  final double heightPadding;
  final double widthPadding;
  final bool underlined;
  final Widget? suffix;
  final bool? semanticsRoleLink;
  final String? semanticsLabel;

  const PrimaryActionButton({
    super.key,
    this.icon,
    this.onPressed,
    required this.label,
    this.withShadow = true,
    this.fontSize,
    this.iconSize = Dimens.icon_size_m,
    this.iconRightPadding = Margins.spacing_s,
    this.heightPadding = Margins.spacing_base,
    this.widthPadding = Margins.spacing_m,
    this.underlined = false,
    this.suffix,
    this.semanticsRoleLink,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = AppColorsSpecifics.primaryButtonForegroundColor(context);
    final backgroundColor = AppColorsSpecifics.primaryButtonBackgroundColor(context);
    final textStyle = TextStyles.textPrimaryButton.copyWith(
      color: foregroundColor,
      decoration: underlined ? TextDecoration.underline : null,
      fontSize: fontSize,
    );
    return FocusedBorderBuilder(
      builder: (focusNode) {
        return TextButton(
          isSemanticButton: semanticsRoleLink == null,
          focusNode: focusNode,
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(foregroundColor),
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              return states.contains(WidgetState.disabled) ? AppColors.disabled : backgroundColor;
            }),
            overlayColor: WidgetStateProperty.all(AppColors.primaryDarken),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
            textStyle: WidgetStateProperty.all(textStyle),
            elevation: WidgetStateProperty.resolveWith((states) {
              return (states.contains(WidgetState.disabled) || !withShadow) ? 0 : 10;
            }),
            alignment: Alignment.center,
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(Dimens.radius_base))),
            ),
          ),
          onPressed: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widthPadding, vertical: heightPadding),
            child: _buildContent(textStyle),
          ),
        );
      },
    );
  }

  Widget _buildContent(TextStyle textStyle) {
    return Semantics(
      link: semanticsRoleLink,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(right: iconRightPadding),
              child: Icon(icon, size: iconSize, color: AppColors.contentOnPrimary),
            ),
          Text(
            label,
            semanticsLabel: semanticsLabel,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
          if (suffix != null)
            Padding(
              padding: EdgeInsets.only(left: Margins.spacing_base),
              child: suffix!,
            ),
        ],
      ),
    );
  }
}
