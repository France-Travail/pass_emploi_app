import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/onboarding/onboarding_actions.dart';
import 'package:pass_emploi_app/pages/onboarding_page.dart';
import 'package:pass_emploi_app/presentation/accueil/accueil_item.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class AccueilOnboardingTile extends StatelessWidget {
  const AccueilOnboardingTile(this.onboardingItem);
  final OnboardingItem onboardingItem;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted =
        onboardingItem.completedSteps == onboardingItem.totalSteps;
    final progressPercent = onboardingItem.totalSteps == 0
        ? 0
        : ((onboardingItem.completedSteps / onboardingItem.totalSteps) * 100)
              .round();
    const radius = BorderRadius.all(Radius.circular(4));

    return Semantics(
      button: true,
      label: isCompleted
          ? Strings.onboardingAccueilTitleCompleted
          : '${Strings.onboardingAccueilTitle}. ${onboardingItem.completedSteps} sur ${onboardingItem.totalSteps}',
      onTap: () {
        if (isCompleted) {
          StoreProvider.of<AppState>(context).dispatch(OnboardingHideAction());
        } else {
          Navigator.of(context).push(OnboardingPage.route());
        }
      },
      child: Material(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        borderRadius: radius,
        child: InkWell(
          onTap: () {
            if (isCompleted) {
              StoreProvider.of<AppState>(
                context,
              ).dispatch(OnboardingHideAction());
            } else {
              Navigator.of(context).push(OnboardingPage.route());
            }
          },
          borderRadius: radius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: DsfrColorDecisions.borderActionHighBlueFrance(context),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DsfrSpacings.s2w),
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DsfrBadge(
                      label: Strings.inviteAccueilDiscoveryProgress(
                        progressPercent,
                      ),
                      type: isCompleted
                          ? DsfrBadgeType.success
                          : DsfrBadgeType.news,
                      size: DsfrComponentSize.sm,
                      withIcon: true,
                    ),
                    const SizedBox(height: DsfrSpacings.s1w),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isCompleted
                                ? Strings.onboardingAccueilTitleCompleted
                                : Strings.onboardingAccueilTitle,
                            style: DsfrTextStyle.bodyMdBold(
                              color: DsfrColorDecisions.textTitleGrey(context),
                            ),
                          ),
                        ),
                        Icon(
                          isCompleted
                              ? DsfrIcons.systemCloseLine
                              : DsfrIcons.systemArrowRightSLine,
                          color: DsfrColorDecisions.textTitleBlueFrance(
                            context,
                          ),
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
