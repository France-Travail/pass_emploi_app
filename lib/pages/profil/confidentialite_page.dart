import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/analytics/tracker.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/launcher_utils.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_profil_tile.dart';

class ConfidentialitePage extends StatelessWidget {
  static MaterialPageRoute<void> materialPageRoute() {
    return MaterialPageRoute(builder: (_) => const ConfidentialitePage());
  }

  const ConfidentialitePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Tracker(
      tracking: AnalyticsScreenNames.confidentialite,
      child: Scaffold(
        backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
        appBar: const BackAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s3w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageTitle(Strings.privacyAndDataLabel),
              const SizedBox(height: DsfrSpacings.s2w),
              DsfrProfilTile(
                icon: DsfrIcons.systemExternalLinkLine,
                iconBackgroundColor: DsfrColors.greenEmeraude950,
                title: Strings.legalNoticeLabel,
                semanticsLink: true,
                onTap: () => _launchAndTrackExternalLink(Strings.legalNoticeUrl),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              DsfrProfilTile(
                icon: DsfrIcons.systemExternalLinkLine,
                iconBackgroundColor: DsfrColors.greenEmeraude950,
                title: Strings.termsOfUseLabel,
                semanticsLink: true,
                onTap: () => _launchAndTrackExternalLink(Strings.termsOfServiceUrl),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              DsfrProfilTile(
                icon: DsfrIcons.systemExternalLinkLine,
                iconBackgroundColor: DsfrColors.greenEmeraude950,
                title: Strings.privacyPolicyLabel,
                semanticsLink: true,
                onTap: () => _launchAndTrackExternalLink(Strings.privacyPolicyUrl),
              ),
              const SizedBox(height: DsfrSpacings.s2w),
              DsfrProfilTile(
                icon: DsfrIcons.systemExternalLinkLine,
                iconBackgroundColor: DsfrColors.greenEmeraude950,
                title: Strings.accessibilityLevelLabel,
                semanticsLink: true,
                onTap: () => _launchAndTrackExternalLink(Strings.accessibilityUrl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _launchAndTrackExternalLink(String link) {
  PassEmploiMatomoTracker.instance.trackOutlink(link);
  launchExternalUrl(link);
}
