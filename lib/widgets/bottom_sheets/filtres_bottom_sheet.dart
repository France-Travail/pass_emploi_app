import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class FiltresBottomSheet extends StatelessWidget {
  const FiltresBottomSheet({
    super.key,
    required this.title,
    required this.body,
    this.maxHeightFactor = 0.9,
  });

  final String title;
  final Widget body;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
      ),
      child: Material(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DsfrSpacings.s2w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: DsfrButton(
                    label: Strings.close,
                    icon: DsfrIcons.systemCloseLine,
                    iconLocation: DsfrButtonIconLocation.right,
                    variant: DsfrButtonVariant.tertiaryWithoutBorder,
                    size: DsfrComponentSize.sm,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: DsfrSpacings.s1w),
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                  ),
                ),
                const SizedBox(height: DsfrSpacings.s2w),
                Flexible(child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
