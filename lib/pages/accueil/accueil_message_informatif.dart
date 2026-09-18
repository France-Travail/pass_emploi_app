import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/accueil/message_informatif.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/utils/platform.dart';

class AccueilMessageInformatif extends StatelessWidget {
  final MessageInformatif messageInformatif;

  AccueilMessageInformatif({required this.messageInformatif});

  @override
  Widget build(BuildContext context) {
    final cta = messageInformatif.cta;
    return DsfrAlert(
      type: DsfrAlertType.info,
      title: messageInformatif.titre,
      description: cta == null
          ? DsfrAlertDescriptionText(messageInformatif.contenu)
          : DsfrAlertDescriptionWidget(_DescriptionWithCta(contenu: messageInformatif.contenu, cta: cta)),
    );
  }
}

class _DescriptionWithCta extends StatelessWidget {
  final String contenu;
  final MessageInformatifCta cta;

  const _DescriptionWithCta({required this.contenu, required this.cta});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          contenu,
          style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: cta.label,
          icon: DsfrIcons.systemDownloadLine,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.sm,
          onPressed: () {
            final url = cta.url(isAndroid: PlatformUtils.getPlatform.isAndroid);
            PassEmploiMatomoTracker.instance.trackOutlink(url);
            launchExternalUrl(url);
          },
        ),
      ],
    );
  }
}
