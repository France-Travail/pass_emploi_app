import 'package:flutter/material.dart';
import 'package:pass_emploi_app/models/accueil/message_informatif.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/utils/platform.dart';
import 'package:pass_emploi_app/widgets/buttons/primary_action_button.dart';
import 'package:pass_emploi_app/widgets/cards/generic/card_container.dart';

class AccueilMessageInformatif extends StatelessWidget {
  final MessageInformatif messageInformatif;

  AccueilMessageInformatif({required this.messageInformatif});

  @override
  Widget build(BuildContext context) {
    final cta = messageInformatif.cta;
    return CardContainer(
      backgroundColor: AppColors.primaryLighten,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.info_rounded, color: AppColors.primary),
          SizedBox(width: Margins.spacing_s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(messageInformatif.titre, style: TextStyles.textSBold.copyWith(color: AppColors.primary)),
                SizedBox(height: Margins.spacing_s),
                Text(messageInformatif.contenu, style: TextStyles.textSRegular().copyWith(color: AppColors.primary)),
                if (cta != null) ...[
                  SizedBox(height: Margins.spacing_s),
                  PrimaryActionButton(
                    heightPadding: Margins.spacing_s,
                    icon: Icons.download,
                    label: cta.label,
                    onPressed: () {
                      final url = cta.url(isAndroid: PlatformUtils.getPlatform.isAndroid);
                      PassEmploiMatomoTracker.instance.trackOutlink(url);
                      launchExternalUrl(url);
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
