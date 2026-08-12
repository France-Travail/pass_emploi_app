import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class FiltreButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final int? filtresCount;

  const FiltreButton({super.key, this.onPressed, this.filtresCount});

  @override
  Widget build(BuildContext context) {
    final label = filtresCount != null && filtresCount! > 0
        ? "${Strings.filtrer} ($filtresCount)"
        : Strings.filtrer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width - DsfrSpacings.s2w * 2,
        child: DsfrButton(
          label: label,
          icon: DsfrIcons.mediaEqualizerLine,
          variant: DsfrButtonVariant.primary,
          size: DsfrComponentSize.lg,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
