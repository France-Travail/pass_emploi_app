import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/ft_ia_tutorial/ft_ia_tutorial_actions.dart';
import 'package:pass_emploi_app/presentation/ft_ia_tutorial_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:showcaseview/showcaseview.dart';

class FtIaShowcaseWrapper extends StatelessWidget {
  const FtIaShowcaseWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use, TODO: migrate to ShowcaseView.register() before showcaseview 6
    return ShowCaseWidget(
      onStart: (index, _) {},
      onFinish: () {
        StoreProvider.of<AppState>(context).dispatch(FtIaTutorialSeenAction());
      },
      builder: (context) {
        return child;
      },
    );
  }
}

class FtIaShowcase extends StatefulWidget {
  const FtIaShowcase({super.key, required this.child});
  final Widget child;

  @override
  State<FtIaShowcase> createState() => _FtIaShowcaseState();
}

class _FtIaShowcaseState extends State<FtIaShowcase> {
  final GlobalKey key = GlobalKey();

  bool shown = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, FtIaTutorialViewModel>(
      converter: (store) => FtIaTutorialViewModel.create(store),
      builder: (context, vm) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (vm.isVisible && !shown) {
            shown = true;
            // A11y 5.1 / 10.2 (audit RAAM du 15/10/2026) : le calque de mise en avant (showcaseview) laisse la page
            // accessible derrière lui et pose sur la cible une zone tactile sans nom ni rôle. Avec un lecteur d'écran,
            // la nouveauté est annoncée et le bouton reste utilisable directement, sans calque.
            if (A11yUtils.withScreenReader(context)) {
              A11yUtils.announce(Strings.iaFtShowcaseTitle);
              vm.onSeen();
            } else {
              // ignore: deprecated_member_use, TODO: migrate to ShowcaseView.get() before showcaseview 6
              ShowCaseWidget.of(context).startShowCase([key]);
            }
          }
        });
        return Showcase(
          targetBorderRadius: BorderRadius.circular(Dimens.radius_base),
          tooltipPosition: TooltipPosition.top,
          title: Strings.iaFtShowcaseTitle,
          description: null,
          // Même bulle que OnboardingShowcase.
          tooltipBackgroundColor: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
          tooltipBorderRadius: BorderRadius.zero,
          titleTextStyle: DsfrTextStyle.bodyXlBold(color: DsfrColorDecisions.textInvertedBlueFrance(context)),
          descTextStyle: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textInvertedBlueFrance(context)),
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
