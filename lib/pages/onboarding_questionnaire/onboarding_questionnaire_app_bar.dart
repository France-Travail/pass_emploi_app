import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class OnboardingQuestionnaireAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  const OnboardingQuestionnaireAppBar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<OnboardingQuestionnaireAppBar> createState() =>
      _OnboardingQuestionnaireAppBarState();
}

class _OnboardingQuestionnaireAppBarState
    extends State<OnboardingQuestionnaireAppBar> {
  bool _backFocused = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      // A11y 2.3 : contour de focus DSFR à la place du voile gris de Material (1,2:1).
      leading: Center(
        child: DsfrFocusWidget(
          isFocused: _backFocused,
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onFocusChange: (focused) => setState(() => _backFocused = focused),
            child: IconButton(
              tooltip: Strings.onboardingQuestionnaireBack,
              focusColor: DsfrColorDecisions.backgroundTransparent(context),
              icon: Icon(
                DsfrIcons.systemArrowLeftSLine,
                color: DsfrColorDecisions.textActionHighBlueFrance(context),
              ),
              onPressed: widget.onBack,
            ),
          ),
        ),
      ),
      // Le bouton porte déjà « Retour » : le libellé visible n'est pas un titre d'écran.
      excludeHeaderSemantics: true,
      title: ExcludeSemantics(
        child: Text(
          Strings.onboardingQuestionnaireBack,
          style: DsfrTextStyle.bodyMdBold(
            color: DsfrColorDecisions.textActionHighBlueFrance(context),
          ),
        ),
      ),
      titleSpacing: 0,
      centerTitle: false,
    );
  }
}
