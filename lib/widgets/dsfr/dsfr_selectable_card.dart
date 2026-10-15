import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

class DsfrSelectableCard extends StatefulWidget {
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
  State<DsfrSelectableCard> createState() => _DsfrSelectableCardState();
}

class _DsfrSelectableCardState extends State<DsfrSelectableCard> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final selected = widget.selected;
    final radius = const BorderRadius.all(Radius.circular(4));
    return Semantics(
      button: true,
      selected: selected,
      // A11y 2.3 : contour de focus DSFR à la place du voile gris de Material.
      child: DsfrFocusWidget(
        isFocused: _focused,
        borderRadius: radius,
        child: Material(
          color: selected
              ? DsfrColorDecisions.backgroundDefaultGreyActive(context)
              : DsfrColorDecisions.backgroundDefaultGrey(context),
          borderRadius: radius,
          child: InkWell(
            onTap: widget.onTap,
            focusColor: DsfrColorDecisions.backgroundTransparent(context),
            onFocusChange: (focused) => setState(() => _focused = focused),
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
      ),
    );
  }
}
