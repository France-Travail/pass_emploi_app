import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
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
            Icon(
              DsfrIcons.communicationChat2Line,
              size: DsfrSpacings.s8w,
              color: DsfrColorDecisions.textMentionGrey(context),
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
