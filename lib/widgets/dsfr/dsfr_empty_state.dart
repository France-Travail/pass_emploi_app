import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/ui/drawables.dart';

class DsfrEmptyState extends StatelessWidget {
  const DsfrEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.illustrationAsset,
    this.illustrationWidth = 160,
    this.buttonLabel,
    this.onButtonPressed,
    this.buttonIcon,
    this.padding,
    this.centered = false,
  });

  final String title;
  final String? subtitle;
  final String? illustrationAsset;
  final double illustrationWidth;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;
  final IconData? buttonIcon;
  final EdgeInsetsGeometry? padding;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(child: _illustration(illustrationAsset ?? Drawables.illustrationRechercheEmpty, illustrationWidth)),
        const SizedBox(height: DsfrSpacings.s3w),
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: DsfrSpacings.s1w),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textDefaultGrey(context)),
          ),
        ],
        if (buttonLabel != null && onButtonPressed != null) ...[
          const SizedBox(height: DsfrSpacings.s3w),
          DsfrButton(
            label: buttonLabel!,
            icon: buttonIcon,
            variant: DsfrButtonVariant.primary,
            size: DsfrComponentSize.lg,
            onPressed: onButtonPressed,
          ),
        ],
      ],
    );

    final horizontalPadding = padding ?? const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w);

    if (!centered) {
      return Padding(padding: horizontalPadding, child: content);
    }

    return SafeArea(
      child: Padding(
        padding: horizontalPadding,
        child: Center(
          child: SingleChildScrollView(
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _illustration(String asset, double width) {
    if (asset.endsWith('.svg')) {
      return SvgPicture.asset(
        asset,
        width: width,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      );
    }
    return Image.asset(
      asset,
      width: width,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}
