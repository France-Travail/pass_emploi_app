import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';

class CardTitle extends StatelessWidget {
  const CardTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyles.textBaseBold.copyWith(
        fontSize: 16,
        color: AppColors.contentColor,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
