import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/shadows.dart';

class CardContainer extends StatefulWidget {
  final Widget child;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final Color? backgroundColor;
  final Color? splashColor;
  final EdgeInsets padding;
  final bool withShadow;
  final DecorationImage? image;
  final Gradient? gradient;
  final Border? border;

  CardContainer({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    Color? splashColor,
    this.padding = const EdgeInsets.all(Margins.spacing_base),
    this.withShadow = true,
    this.image,
    this.gradient,
    this.border,
  }) : splashColor = splashColor ?? AppColors.primary.withValues(alpha: 0.2);

  @override
  State<CardContainer> createState() => _CardContainerState();
}

class _CardContainerState extends State<CardContainer> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    final onTap = widget.onTap;
    final onLongPress = widget.onLongPress;
    final gradient = widget.gradient;
    final BorderRadius cardBorderRadius = BorderRadius.circular(Dimens.radius_base);
    final bg = widget.backgroundColor ?? context.bg;

    // a11y 10.2 : to avoid useless tap trigger we should remove inkwell
    final childWithPadding = Padding(padding: widget.padding, child: child);
    // A11y 2.3 : contour de focus DSFR autour de la carte, à la place du voile gris de Material (1,3:1).
    return DsfrFocusWidget(
      isFocused: _focused,
      borderRadius: cardBorderRadius,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: gradient != null ? null : bg,
          borderRadius: cardBorderRadius,
          boxShadow: widget.withShadow ? [Shadows.radius_base] : [],
          border: widget.border,
          image: widget.image,
          gradient: gradient,
        ),
        child: (onTap == null && onLongPress == null)
            ? childWithPadding
            : Material(
                clipBehavior: Clip.hardEdge,
                color: gradient != null ? AppColors.transparent : bg,
                borderRadius: cardBorderRadius,
                child: InkWell(
                  borderRadius: cardBorderRadius,
                  onTap: onTap,
                  onLongPress: onLongPress != null
                      ? () {
                          HapticFeedback.heavyImpact();
                          onLongPress.call();
                        }
                      : null,
                  splashColor: widget.splashColor,
                  focusColor: Colors.transparent,
                  onFocusChange: (focused) => setState(() => _focused = focused),
                  child: childWithPadding,
                ),
              ),
      ),
    );
  }
}
