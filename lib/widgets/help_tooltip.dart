import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

class HelpTooltip extends StatelessWidget {
  final String message;
  final IconData icon;

  const HelpTooltip({
    super.key,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message,
      child: Semantics(
        excludeSemantics: true,
        child: Tooltip(
          message: message,

          triggerMode: TooltipTriggerMode.tap,
          // A11y 8.7 : l'infobulle reste affichée jusqu'à ce que l'utilisateur touche ailleurs.
          showDuration: Duration(minutes: 5),
          exitDuration: Duration(seconds: 3),
          // Apparence de l'infobulle DSFR (DsfrTooltip), sans changer le nom lu ni la durée d'affichage.
          textStyle: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textDefaultGrey(context)),
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DsfrColorDecisions.backgroundOverlapGrey(context),
            border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
          ),
          child: Icon(
            icon,
            color: DsfrColorDecisions.textActionHighBlueFrance(context),
          ),
        ),
      ),
    );
  }
}
