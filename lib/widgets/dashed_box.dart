import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';

class DashedBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  DashedBox({
    required this.child,
    this.padding = const EdgeInsets.all(Margins.spacing_m),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? context.grey800;
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        dashPattern: [8, 8],
        radius: Radius.circular(Dimens.radius_base),
        color: resolvedColor,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
