import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/action_plan/action_plan_actions.dart';
import 'package:pass_emploi_app/pages/accueil/invite/invite_action_plan_empty_state.dart';
import 'package:pass_emploi_app/pages/accueil/invite/invite_action_plan_section.dart';
import 'package:pass_emploi_app/pages/accueil/invite/invite_discovery_tile.dart';
import 'package:pass_emploi_app/pages/accueil/invite/onboarding_questionnaire_progress_card.dart';
import 'package:pass_emploi_app/presentation/accueil/invite_accueil_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

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

    final questionnaireDescription = viewModel.mode == InviteAccueilMode.incomplet
        ? Strings.inviteAccueilQuestionnaireDescriptionIncomplet
        : Strings.inviteAccueilQuestionnaireDescription;

    return Padding(
      padding: const EdgeInsets.all(Margins.spacing_base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (viewModel.showDiscoveryTile) ...[
            InviteDiscoveryTile(
              progressPercent: viewModel.discoveryProgressPercent,
              isCompleted: viewModel.discoveryCompleted,
              onHide: viewModel.hideDiscovery,
            ),
            const SizedBox(height: Margins.spacing_s),
          ],
          if (viewModel.showQuestionnaireCard && viewModel.mode == InviteAccueilMode.incomplet) ...[
            OnboardingQuestionnaireProgressCard(
              answers: viewModel.answers,
              onResume: viewModel.resumeOnboarding,
              description: questionnaireDescription,
            ),
            const SizedBox(height: Margins.spacing_s),
          ],
          if (viewModel.showPlanSection) ...[
            Text(
              Strings.inviteAccueilPlanTitle,
              style: DsfrTextStyle.headline3(color: DsfrColorDecisions.textTitleGrey(context)),
            ),
            if (!viewModel.showPlanEmptyState) ...[
              const SizedBox(height: Margins.spacing_base),
              Text(
                viewModel.planSubtitle,
                style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleGrey(context)),
              ),
            ],
            const SizedBox(height: Margins.spacing_base),
            if (viewModel.showPlanEmptyState)
              InviteActionPlanEmptyState(
                kind: viewModel.planEmptyKind!,
                showRetry: viewModel.showRetryGenerate,
                showModifier: viewModel.showModifierButton,
                onRetry: viewModel.retryGenerate,
                onModifier: viewModel.resumeOnboarding,
              )
            else
              InviteActionPlanSection(
                plan: viewModel.plan,
                onToggleDone: viewModel.toggleDone,
                onDelete: viewModel.deleteAction,
              ),
          ],
          if (viewModel.showQuestionnaireCard && viewModel.mode == InviteAccueilMode.partiel) ...[
            const SizedBox(height: Margins.spacing_base),
            OnboardingQuestionnaireProgressCard(
              answers: viewModel.answers,
              onResume: viewModel.resumeOnboarding,
              description: questionnaireDescription,
            ),
          ],
          if (viewModel.showModifierButton && !viewModel.showPlanEmptyState) ...[
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
            const SizedBox(height: Margins.spacing_s),
            DecoratedBox(
              decoration: BoxDecoration(
                color: DsfrColorDecisions.backgroundDefaultGrey(context),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: DsfrColorDecisions.artworkDecorativeBlueFrance(context)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Margins.spacing_base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.inviteAccueilExplorerTipTitle,
                      style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                    ),
                    Text(
                      Strings.inviteAccueilExplorerTipBody,
                      style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textTitleGrey(context)),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (viewModel.showConseillerCta) ...[
            const SizedBox(height: Margins.spacing_base),
            Material(
              color: DsfrColorDecisions.artworkDecorativeBlueFrance(context),
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
                      Image.asset(
                        'assets/dsfr/avatar.webp',
                        width: 54,
                        height: 54,
                      ),
                      const SizedBox(width: Margins.spacing_base),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Strings.inviteAccueilConseillerTitle,
                              style: DsfrTextStyle.bodyMdBold(
                                color: DsfrColorDecisions.textTitleBlueFrance(context),
                              ),
                            ),
                            Text(
                              Strings.inviteAccueilConseillerBody,
                              style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
                            ),
                          ],
                        ),
                      ),
                      Icon(DsfrIcons.systemArrowRightSLine, color: DsfrColorDecisions.textTitleBlueFrance(context)),
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
