import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/pages/etre_accompagne/etre_accompagne_page.dart';
import 'package:pass_emploi_app/presentation/etre_accompagne/etre_accompagne_tracking.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';

/// Tuile « Être accompagné par un conseiller ? » de l'accueil invité, vers « Être accompagné ».
class InviteConseillerTile extends StatelessWidget {
  const InviteConseillerTile({super.key});

  @override
  Widget build(BuildContext context) {
    final titleColor = DsfrColorDecisions.textTitleBlueFrance(context);
    // A11y : un seul nœud bouton, lu en une fois (titre puis description).
    return Semantics(
      container: true,
      button: true,
      label: '${Strings.inviteAccueilConseillerTitle}, ${Strings.inviteAccueilConseillerBody}',
      onTap: () => _onTap(context),
      excludeSemantics: true,
      // A11y 2.3 : contour de focus DSFR à la place du voile gris ; le Focus englobant signale celui de l'InkWell.
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        child: Builder(
          builder: (context) => DsfrFocusWidget(
            isFocused: Focus.of(context).hasFocus,
            borderRadius: BorderRadius.circular(4),
            child: Material(
              color: DsfrColorDecisions.artworkDecorativeBlueFrance(context),
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: () => _onTap(context),
                borderRadius: BorderRadius.circular(4),
                focusColor: DsfrColorDecisions.backgroundTransparent(context),
                child: Padding(
                  padding: const EdgeInsets.all(Margins.spacing_base),
                  child: Row(
                    children: [
                      Image.asset('assets/dsfr/avatar.webp', width: 54, height: 54, excludeFromSemantics: true),
                      const SizedBox(width: Margins.spacing_base),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Strings.inviteAccueilConseillerTitle,
                              style: DsfrTextStyle.bodyMdBold(color: titleColor),
                            ),
                            Text(
                              Strings.inviteAccueilConseillerBody,
                              style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textMentionGrey(context)),
                            ),
                          ],
                        ),
                      ),
                      Icon(DsfrIcons.systemArrowRightSLine, color: titleColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    const EtreAccompagneTrackingEvent.tuile().send();
    Navigator.of(context).push(EtreAccompagnePage.materialPageRoute());
  }
}
