import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/pages/demarche/create_demarche/create_demarche_success_page.dart';
import 'package:pass_emploi_app/presentation/user_action/postuler_confirmation_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/pass_emploi_matomo_tracker.dart';
import 'package:pass_emploi_app/widgets/create_user_action_confirmation_offre_suivi_page.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/success/bottom_actions.dart';
import 'package:pass_emploi_app/widgets/success/success_illustration.dart';

class PostulerConfirmationPage extends StatelessWidget {
  const PostulerConfirmationPage({required this.offreId});

  final String offreId;

  static Route<void> route(String offreId) {
    return MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => PostulerConfirmationPage(offreId: offreId));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, PostulerConfirmationViewModel>(
      converter: (store) => PostulerConfirmationViewModel.create(store, offreId),
      builder: (context, viewModel) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
        return Theme(
          data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
          child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: SecondaryAppBar(title: Strings.offrePostuleeConfirmationAppBar, backgroundColor: backgroundColor),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: DsfrSpacings.s3w),
                            const SuccessIllustration(size: 160),
                            const SizedBox(height: DsfrSpacings.s3w),
                            Semantics(
                              header: true,
                              child: Text(
                                Strings.offreSuivieConfirmationPageTitle,
                                textAlign: TextAlign.center,
                                style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                              ),
                            ),
                            const SizedBox(height: DsfrSpacings.s1w),
                            Text(
                              Strings.offreSuivieConfirmationPageDescription,
                              textAlign: TextAlign.center,
                              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                            ),
                            if (viewModel.onCreateActionOrDemarche != null) ...[
                              const SizedBox(height: DsfrSpacings.s3w),
                              Text(
                                viewModel.wishToCreateActionOrDemarche,
                                textAlign: TextAlign.center,
                                style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    BottomActions(
                      children: [
                        if (viewModel.onCreateActionOrDemarche != null) ...[
                          SizedBox(
                            width: double.infinity,
                            child: DsfrButton(
                              label: viewModel.onCreateActionOrDemarcheLabel,
                              variant: DsfrButtonVariant.primary,
                              size: DsfrComponentSize.md,
                              onPressed: () {
                                Navigator.of(context).pop();
                                viewModel.onCreateActionOrDemarche?.call();
                                if (viewModel.useDemarche) {
                                  PassEmploiMatomoTracker.instance.trackEvent(
                                    eventCategory: AnalyticsEventNames.createDemarcheEventCategory,
                                    action: AnalyticsEventNames.createDemarcheFromOffreSuiviAction,
                                  );
                                  Navigator.of(
                                    context,
                                  ).push(CreateDemarcheSuccessPage.route(CreateDemarcheSource.fromReferentiel));
                                } else {
                                  PassEmploiMatomoTracker.instance.trackEvent(
                                    eventCategory: AnalyticsEventNames.createActionEventCategory,
                                    action: AnalyticsEventNames.createActionResultFromOffreSuiviAction,
                                  );
                                  Navigator.of(context).push(CreateUserActionConfirmationOffreSuiviPage.route());
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: DsfrSpacings.s2w),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: DsfrButton(
                            label: Strings.close,
                            variant: DsfrButtonVariant.secondary,
                            size: DsfrComponentSize.md,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
