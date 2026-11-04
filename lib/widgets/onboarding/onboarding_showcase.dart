import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/onboarding/onboarding_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';
import 'package:showcaseview/showcaseview.dart';

class ShowcaseWrapper extends StatelessWidget {
  const ShowcaseWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onStart: (index, __) {},
      onFinish: () {
        StoreProvider.of<AppState>(context).dispatch(ResetOnboardingShowcaseAction());
      },
      builder: (context) {
        return child;
      },
    );
  }
}

enum ShowcaseSource { message, action, offre, evenement, planAction }

class OnboardingShowcase extends StatefulWidget {
  const OnboardingShowcase({super.key, required this.child, required this.source, this.bottom = false});
  final Widget child;
  final ShowcaseSource source;
  final bool bottom;

  @override
  State<OnboardingShowcase> createState() => _OnboardingShowcaseState();
}

class _OnboardingShowcaseState extends State<OnboardingShowcase> {
  final GlobalKey key = GlobalKey();

  bool shown = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) =>
          (switch (widget.source) {
            ShowcaseSource.message => store.state.onboardingState.showMessageOnboarding,
            ShowcaseSource.action => store.state.onboardingState.showActionOnboarding,
            ShowcaseSource.offre => store.state.onboardingState.showOffreOnboarding,
            ShowcaseSource.evenement => store.state.onboardingState.showEvenementOnboarding,
            ShowcaseSource.planAction => store.state.onboardingState.showPlanActionOnboarding,
          }) &&
          (store.state.onboardingState.onboarding?.showOnboarding ?? false),
      builder: (context, show) {
        if (!show) return widget.child;

        final title = switch (widget.source) {
          ShowcaseSource.message => Strings.onboardingShowcaseMessageTitle,
          ShowcaseSource.action => Strings.onboardingShowcaseActionTitle,
          ShowcaseSource.offre => Strings.onboardingShowcaseOffreTitle,
          ShowcaseSource.evenement => Strings.onboardingShowcaseEvenementTitle,
          ShowcaseSource.planAction => Strings.onboardingShowcasePlanActionTitle,
        };
        final description = switch (widget.source) {
          ShowcaseSource.message => Strings.onboardingShowcaseMessageDescription,
          ShowcaseSource.action => Strings.onboardingShowcaseActionDescription,
          ShowcaseSource.offre => Strings.onboardingShowcaseOffreDescription,
          ShowcaseSource.evenement => Strings.onboardingShowcaseEvenementDescription,
          ShowcaseSource.planAction => Strings.onboardingShowcasePlanActionDescription,
        };

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (show && !shown) {
            shown = true;
            // A11y 5.1 / 10.2 : avec un lecteur d'écran, pas de calque de mise en avant (page accessible derrière lui,
            // cible sans nom ni rôle) : son contenu est annoncé et l'étape est marquée comme vue.
            if (A11yUtils.withScreenReader(context)) {
              A11yUtils.announce('$title. $description'.removeEmojisForScreenReaders());
              StoreProvider.of<AppState>(context).dispatch(ResetOnboardingShowcaseAction());
            } else {
              ShowCaseWidget.of(context).startShowCase([key]);
            }
          }
        });
        return Showcase(
          targetBorderRadius: BorderRadius.circular(Dimens.radius_base),
          tooltipPosition: widget.bottom ? TooltipPosition.bottom : TooltipPosition.top,
          title: title,
          description: description,
          tooltipBackgroundColor: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
          tooltipBorderRadius: BorderRadius.zero,
          titleTextStyle: TextStyles.textMBold.copyWith(
            color: DsfrColorDecisions.textInvertedBlueFrance(context),
          ),
          descTextStyle: TextStyles.textBaseRegular.copyWith(
            color: DsfrColorDecisions.textInvertedBlueFrance(context),
          ),
          key: key,
          titleAlignment: Alignment.centerLeft,
          descriptionAlignment: Alignment.centerLeft,
          tooltipPadding: const EdgeInsets.all(Margins.spacing_base),
          child: widget.child,
        );
      },
    );
  }
}
