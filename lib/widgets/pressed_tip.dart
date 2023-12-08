import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';

class PressedTip extends StatelessWidget {
  final String tip;
  final Color textColor;
  final IconData icon;

  PressedTip(this.tip, {Color? textColor, IconData? icon})
      : textColor = textColor ?? AppColors.contentColor(),
        icon = icon ?? AppIcons.chevron_right_rounded;

  factory PressedTip.externalLink(String tip) {
    return PressedTip(tip, icon: AppIcons.open_in_new_rounded);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            tip,
            style: TextStyles.textSRegular(color: textColor),
            textAlign: TextAlign.end,
          ),
        ),
        SizedBox(width: Margins.spacing_s),
        Icon(icon, color: textColor, size: Dimens.icon_size_base),
      ],
    );
  }
}
