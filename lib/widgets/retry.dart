import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/media_sizes.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class Retry extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;
  final String? buttonLabel;
  final bool small;

  const Retry(this.text, this.onRetry, {this.buttonLabel, this.small = false});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final isCompact = height < MediaSizes.height_xs;
    final illustrationSize = isCompact ? 80.0 : 160.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!small) ...[
              SvgPicture.asset(
                Drawables.illustrationWarning,
                width: illustrationSize,
                height: illustrationSize,
                excludeFromSemantics: true,
              ),
              SizedBox(height: isCompact ? DsfrSpacings.s2w : DsfrSpacings.s3w),
            ],
            Text(
              Strings.error,
              style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DsfrSpacings.s1w),
            Text(
              text,
              style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DsfrSpacings.s3w),
            DsfrButton(
              label: buttonLabel ?? Strings.retry,
              icon: DsfrIcons.systemRefreshLine,
              variant: DsfrButtonVariant.primary,
              size: DsfrComponentSize.lg,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
