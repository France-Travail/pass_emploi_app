import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

/// Badge DSFR « information » (petite taille, avec icône) dont le libellé passe à la ligne.
///
/// A11y 8.2 (audit RAAM du 15/10/2026) : `DsfrBadge` place son libellé dans une ligne non flexible ; texte agrandi,
/// « CANDIDATURE ENVOYÉE » était coupé. Même rendu, mais le libellé revient à la ligne au lieu de déborder.
class DsfrInformationBadge extends StatelessWidget {
  const DsfrInformationBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = DsfrColorDecisions.textDefaultInfo(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.backgroundContrastInfo(context),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(DsfrIcons.systemFrInfoFill, size: 16, color: color),
            ),
            Flexible(
              child: Text(label.toUpperCase(), style: DsfrTextStyle.bodySmBold(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
