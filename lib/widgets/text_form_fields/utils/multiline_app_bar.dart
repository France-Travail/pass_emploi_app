import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';

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
          child: DsfrButton(
            label: Strings.back,
            icon: DsfrIcons.systemArrowLeftSLine,
            variant: DsfrButtonVariant.tertiaryWithoutBorder,
            size: DsfrComponentSize.md,
            onPressed: onCloseButtonPressed,
          ),
        ),
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(Margins.spacing_base, 0, Margins.spacing_base, Margins.spacing_s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(title!, style: TextStyles.textBaseBold.copyWith(color: context.content)),
                ),
                if (hint != null) Text(hint!, style: TextStyles.textSRegularWithColor(context.content)),
              ],
            ),
          ),
      ],
    );
  }
}
