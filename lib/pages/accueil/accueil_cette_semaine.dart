import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/features/deep_link/deep_link_actions.dart';
import 'package:pass_emploi_app/models/deep_link.dart';
import 'package:pass_emploi_app/presentation/accueil/accueil_item.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/textes.dart';

class AccueilCetteSemaine extends StatelessWidget {
  final AccueilCetteSemaineItem item;

  AccueilCetteSemaine(this.item);

  @override
  Widget build(BuildContext context) {
    final rendezvousCount = item.rendezvousCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LargeSectionTitle(Strings.accueilCetteSemaineSection),
        const SizedBox(height: DsfrSpacings.s2w),
        Row(
          children: [
            if (rendezvousCount != null) ...[
              Expanded(
                child: _BlocInfo(
                  icon: DsfrIcons.businessCalendarEventLine,
                  label: Strings.accueilRendezvous,
                  count: rendezvousCount,
                ),
              ),
              const SizedBox(width: DsfrSpacings.s2w),
            ],
            Expanded(
              child: _BlocInfo(
                icon: DsfrIcons.systemCheckboxCircleLine,
                label: item.actionsOuDemarchesLabel,
                count: item.actionsOuDemarchesCount,
              ),
            ),
          ],
        ),
        const SizedBox(height: DsfrSpacings.s2w),
        DsfrButton(
          label: Strings.accueilVoirDetailsCetteSemaine,
          variant: DsfrButtonVariant.secondary,
          size: DsfrComponentSize.md,
          onPressed: () {
            PassEmploiMatomoTracker.instance.trackEvent(
              eventCategory: AnalyticsEventNames.accueilCategory,
              action: AnalyticsEventNames.accueilDetailSemainePressed,
            );
            StoreProvider.of<AppState>(context).dispatch(
              HandleDeepLinkAction(
                MonSuiviDeepLink(),
                DeepLinkOrigin.inAppNavigation,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BlocInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;

  const _BlocInfo({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DsfrColorDecisions.backgroundContrastBlueFrance(context),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DsfrSpacings.s2w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: DsfrColorDecisions.textTitleBlueFrance(context),
                    size: DsfrSpacings.s3w,
                  ),
                  const SizedBox(width: DsfrSpacings.s1w),
                  Text(
                    count,
                    style: DsfrTextStyle.headline5(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                ],
              ),
              const SizedBox(height: DsfrSpacings.s1v),
              Text(
                label,
                style: DsfrTextStyle.bodyXsBold(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
