import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';

class BottomSheetButton extends StatelessWidget {
  const BottomSheetButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.withNavigationSuffix = false,
    this.color,
  });
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final bool withNavigationSuffix;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? context.content;
    return Semantics(
      button: true,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: textColor),
        title: Text(text, style: TextStyles.textBaseBold.copyWith(color: textColor)),
        trailing: withNavigationSuffix ? Icon(AppIcons.chevron_right_rounded, color: context.content) : null,
        onTap: onPressed,
      ),
    );
  }
}
