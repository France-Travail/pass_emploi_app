import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class EmptyChatPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s3w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              Drawables.pictogramCommunity,
              width: 80,
              height: 80,
              excludeFromSemantics: true,
            ),
            const SizedBox(height: DsfrSpacings.s2w),
            Text(
              Strings.chatEmpty,
              style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            Text(
              Strings.chatEmptySubtitle,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
