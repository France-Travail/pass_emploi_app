import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class FilterButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;
  final VoidCallback? onReset;

  const FilterButton({
    required this.isEnabled,
    required this.onPressed,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsfrSpacings.s2w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsfrButton(
            label: Strings.applyFiltres,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: isEnabled ? onPressed : null,
          ),
          if (onReset != null) ...[
            const SizedBox(height: DsfrSpacings.s2w),
            DsfrButton(
              label: Strings.resetFiltres,
              variant: DsfrButtonVariant.secondary,
              size: DsfrComponentSize.lg,
              onPressed: isEnabled ? onReset : null,
            ),
          ],
        ],
      ),
    );
  }
}
