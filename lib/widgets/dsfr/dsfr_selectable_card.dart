import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

class DsfrSelectableCard extends StatelessWidget {
  const DsfrSelectableCard({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final radius = const BorderRadius.all(Radius.circular(4));
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? DsfrColorDecisions.backgroundDefaultGreyActive(context)
            : DsfrColorDecisions.backgroundDefaultGrey(context),
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DsfrSpacings.s3w),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textTitleBlueFrance(context)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
