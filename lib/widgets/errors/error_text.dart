import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

/// Message d'erreur DSFR : icône d'erreur et texte en rouge d'erreur.
class ErrorText extends StatelessWidget {
  final String text;

  const ErrorText(this.text) : super();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s1w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: DsfrComponentStateIcon(state: DsfrComponentStateEnum.error),
            ),
            const SizedBox(width: DsfrSpacings.s1v),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultError(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
