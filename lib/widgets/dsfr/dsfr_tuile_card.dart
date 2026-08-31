import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/ui/strings.dart';

const _pictoColumnWidth = 82.0;
const _leadingSize = 40.0;

class DsfrTuileCard extends StatelessWidget {
  const DsfrTuileCard({
    super.key,
    required this.leading,
    required this.title,
    this.description,
    this.onTap,
    this.onDismiss,
    this.dismissSemanticLabel,
    this.semanticsLink = false,
    this.semanticsLabel,
  });

  final Widget leading;
  final String title;
  final String? description;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final String? dismissSemanticLabel;
  final bool semanticsLink;
  final String? semanticsLabel;

  bool get _isTappable => onTap != null;

  bool get _isLink => _isTappable && semanticsLink;

  String get _resolvedSemanticsLabel {
    if (semanticsLabel != null) return semanticsLabel!;
    return [
      title,
      if (description != null && description!.isNotEmpty) description!,
      if (_isLink) Strings.openInNewTab,
    ].join('. ');
  }

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(4));
    final shape = RoundedRectangleBorder(
      borderRadius: radius,
      side: BorderSide(color: DsfrColorDecisions.borderDefaultGrey(context)),
    );

    return Semantics(
      container: true,
      button: _isTappable && !_isLink,
      link: _isLink,
      label: _resolvedSemanticsLabel,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: DsfrColorDecisions.backgroundDefaultGrey(context),
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PictoColumn(child: leading),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(DsfrSpacings.s2w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (onDismiss != null) ...[
                          DsfrButton(
                            label: Strings.close,
                            icon: DsfrIcons.systemCloseLine,
                            iconLocation: DsfrButtonIconLocation.right,
                            iconSemanticLabel: dismissSemanticLabel,
                            variant: DsfrButtonVariant.tertiaryWithoutBorder,
                            size: DsfrComponentSize.sm,
                            onPressed: onDismiss,
                          ),
                          const SizedBox(height: DsfrSpacings.s3v),
                        ],
                        _Content(
                          title: title,
                          description: description,
                          onTap: onTap,
                          shape: shape,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PictoColumn extends StatelessWidget {
  const _PictoColumn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _pictoColumnWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s1w, vertical: DsfrSpacings.s2w),
        child: Center(child: child),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.title,
    required this.description,
    required this.onTap,
    required this.shape,
  });

  final String title;
  final String? description;
  final VoidCallback? onTap;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleBlueFrance(context)),
              ),
              if (description != null) ...[
                const SizedBox(height: DsfrSpacings.s1w),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        description!,
                        style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
                      ),
                    ),
                    const SizedBox(width: DsfrSpacings.s1w),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Icon(
                        DsfrIcons.systemArrowRightSLine,
                        size: 16,
                        color: DsfrColorDecisions.textTitleBlueFrance(context),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DsfrTuileCardIcon extends StatelessWidget {
  const DsfrTuileCardIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: _leadingSize,
      color: DsfrColorDecisions.textTitleBlueFrance(context),
    );
  }
}

class DsfrTuileCardImage extends StatelessWidget {
  const DsfrTuileCardImage({
    super.key,
    required this.imageAsset,
    this.fit = BoxFit.contain,
  });

  final String imageAsset;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _leadingSize,
      child: Image.asset(imageAsset, fit: fit),
    );
  }
}

class DsfrTuileCardSvg extends StatelessWidget {
  const DsfrTuileCardSvg({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _leadingSize,
      child: SvgPicture.asset(
        asset,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          DsfrColorDecisions.textTitleBlueFrance(context),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
