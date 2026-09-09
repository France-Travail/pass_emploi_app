import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/widgets/buttons/secondary_icon_button.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  final String textToShare;
  final String semanticsLabel;
  final String? subjectForEmail;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? iconColor;

  const ShareButton({
    required this.textToShare,
    required this.semanticsLabel,
    required this.subjectForEmail,
    required this.onPressed,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SecondaryIconButton(
      icon: icon ?? DsfrIcons.systemShareLine,
      iconSize: Dimens.icon_size_m,
      iconColor: iconColor ?? DsfrColorDecisions.textActionHighBlueFrance(context),
      tooltip: semanticsLabel,
      onTap: () {
        if (onPressed != null) onPressed!();
        SharePlus.instance.share(
          ShareParams(
            text: textToShare,
            subject: subjectForEmail,
          ),
        );
      },
    );
  }
}
