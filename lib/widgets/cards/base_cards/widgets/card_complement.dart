import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';

class CardComplement extends StatelessWidget {
  final String text;
  final Color? color;
  final bool bold;
  final IconData icon;

  CardComplement({required this.text, required this.icon, Color? color, this.bold = false})
      : color = color ?? AppColors.grey800();

  factory CardComplement.place({required String text}) => CardComplement(
        text: text,
        icon: AppIcons.place_outlined,
      );

  factory CardComplement.date({required String text}) => CardComplement(
        text: text,
        icon: AppIcons.event,
      );

  factory CardComplement.dateTime({required String text}) => CardComplement(
        text: text,
        icon: AppIcons.schedule,
      );

  factory CardComplement.time({required String text}) => CardComplement(
        text: text,
        icon: AppIcons.schedule,
      );

  factory CardComplement.dateLate({required String text}) => CardComplement(
    text: text,
        icon: AppIcons.event,
        color: AppColors.warning(),
        bold: true,
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: Dimens.icon_size_base, color: color),
        SizedBox(width: Margins.spacing_xs),
        Flexible(
            fit: FlexFit.loose,
            child: Text(
              text,
              style: (bold ? TextStyles.textSBold : TextStyles.textSRegular()).copyWith(color: color),
            ))
      ],
    );
  }
}
