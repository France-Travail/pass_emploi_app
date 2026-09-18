import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class OnboardingQuestionnaireAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OnboardingQuestionnaireAppBar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        tooltip: Strings.onboardingQuestionnaireBack,
        icon: Icon(
          DsfrIcons.systemArrowLeftSLine,
          color: DsfrColorDecisions.textActionHighBlueFrance(context),
        ),
        onPressed: onBack,
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
