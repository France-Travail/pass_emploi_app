import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

class MultilineAppBar extends StatelessWidget {
  final String? title;
  final String? hint;
  final VoidCallback onCloseButtonPressed;

  const MultilineAppBar({this.title, required this.onCloseButtonPressed, this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: BackLabelButton(onPressed: onCloseButtonPressed),
        ),
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(DsfrSpacings.s2w, 0, DsfrSpacings.s2w, DsfrSpacings.s1w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title!,
                    style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                ),
                if (hint != null)
                  Text(hint!, style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context))),
              ],
            ),
          ),
      ],
    );
  }
}
