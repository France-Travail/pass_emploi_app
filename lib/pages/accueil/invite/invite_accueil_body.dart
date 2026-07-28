import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/pages/accueil/invite/invite_action_plan_section.dart';
import 'package:pass_emploi_app/pages/accueil/invite/onboarding_questionnaire_progress_card.dart';
import 'package:pass_emploi_app/presentation/accueil/invite_accueil_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';
import 'package:pass_emploi_app/widgets/retry.dart';

class InviteAccueilBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: StoreConnector<AppState, InviteAccueilViewModel>(
        onInit: (store) => store.dispatch(ActionPlanRequestAction()),
        converter: InviteAccueilViewModel.create,
        distinct: true,
        builder: (context, viewModel) {
          return CustomScrollView(
            slivers: [
              PrimarySliverAppbar(title: viewModel.greeting, withNewNotifications: false),
              SliverToBoxAdapter(child: _Content(viewModel: viewModel)),
            ],
          );
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.viewModel});

  final InviteAccueilViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.displayState == DisplayState.LOADING) {
      return const Padding(
        padding: EdgeInsets.all(Margins.spacing_xl),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (viewModel.displayState == DisplayState.FAILURE) {
      return Padding(
        padding: const EdgeInsets.all(Margins.spacing_base),
        child: Retry(Strings.inviteAccueilPlanFailure, viewModel.retryGenerate),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(Margins.spacing_base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (viewModel.showQuestionnaireCard && viewModel.mode == InviteAccueilMode.incomplet) ...[
            OnboardingQuestionnaireProgressCard(
              answers: viewModel.answers,
              onResume: viewModel.resumeOnboarding,
            ),
            const SizedBox(height: Margins.spacing_base),
          ],
          Text(
            Strings.inviteAccueilPlanTitle,
            style: DsfrTextStyle.headline3(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
          const SizedBox(height: Margins.spacing_base),
          Text(
            viewModel.planSubtitle,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
          const SizedBox(height: Margins.spacing_base),
          InviteActionPlanSection(
            plan: viewModel.plan,
            locked: viewModel.showLockedPlan,
            onToggleDone: viewModel.toggleDone,
            onDelete: viewModel.deleteAction,
          ),
          if (viewModel.showQuestionnaireCard && viewModel.mode == InviteAccueilMode.partiel) ...[
            const SizedBox(height: Margins.spacing_base),
            OnboardingQuestionnaireProgressCard(
              answers: viewModel.answers,
              onResume: viewModel.resumeOnboarding,
            ),
          ],
          if (viewModel.showRetryGenerate) ...[
            const SizedBox(height: Margins.spacing_base),
            DsfrButton(
              label: Strings.inviteAccueilRetryPlan,
              variant: DsfrButtonVariant.secondary,
              size: DsfrComponentSize.lg,
              onPressed: viewModel.retryGenerate,
            ),
          ],
          if (viewModel.showModifierButton) ...[
            const SizedBox(height: Margins.spacing_base),
            DsfrButton(
              label: Strings.inviteAccueilModifier,
              icon: DsfrIcons.designEditLine,
              variant: DsfrButtonVariant.secondary,
              size: DsfrComponentSize.lg,
              onPressed: viewModel.resumeOnboarding,
            ),
          ],
          if (viewModel.showExplorerTip) ...[
            const SizedBox(height: Margins.spacing_base),
            DecoratedBox(
              decoration: BoxDecoration(
                color: DsfrColorDecisions.backgroundActionLowBlueFrance(context),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Margins.spacing_base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.inviteAccueilExplorerTipTitle,
                      style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleBlueFrance(context)),
                    ),
                    Text(
                      Strings.inviteAccueilExplorerTipBody,
                      style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textTitleBlueFrance(context)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (viewModel.showConseillerCta) ...[
            const SizedBox(height: Margins.spacing_base),
            Material(
              color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: () {
                  // Not implemented yet
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(Margins.spacing_base),
                  child: Row(
                    children: [
                      Icon(DsfrIcons.userUserLine, color: DsfrColorDecisions.textInvertedBlueFrance(context)),
                      const SizedBox(width: Margins.spacing_base),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Strings.inviteAccueilConseillerTitle,
                              style: DsfrTextStyle.bodyMdBold(
                                color: DsfrColorDecisions.textInvertedBlueFrance(context),
                              ),
                            ),
                            Text(
                              Strings.inviteAccueilConseillerBody,
                              style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textInvertedBlueFrance(context)),
                            ),
                          ],
                        ),
                      ),
                      Icon(DsfrIcons.systemArrowRightSLine, color: DsfrColorDecisions.textInvertedBlueFrance(context)),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: Margins.spacing_xl),
        ],
      ),
    );
  }
}
