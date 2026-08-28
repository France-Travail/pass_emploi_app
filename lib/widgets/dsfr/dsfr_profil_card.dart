import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class DsfrProfilCard extends StatelessWidget {
  const DsfrProfilCard({
    super.key,
    required this.leading,
    required this.title,
    this.description,
    this.onTap,
    this.showChevron,
    this.semanticsLink = false,
    this.semanticsLabel,
  });

  final Widget leading;
  final String title;
  final String? description;
  final VoidCallback? onTap;
  final bool? showChevron;
  final bool semanticsLink;
  final String? semanticsLabel;

  bool get _showChevron => showChevron ?? onTap != null;

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
          child: InkWell(
            onTap: onTap,
            customBorder: shape,
            child: Padding(
              padding: const EdgeInsets.all(DsfrSpacings.s3v),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: DsfrSpacings.s3v),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: DsfrTextStyle.bodyMdBold(color: DsfrColorDecisions.textTitleBlueFrance(context)),
                        ),
                        if (description != null)
                          Text(
                            description!,
                            style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textTitleGrey(context)),
                          ),
                      ],
                    ),
                  ),
                  if (_showChevron)
                    Icon(
                      DsfrIcons.systemArrowRightSLine,
                      size: 16,
                      color: DsfrColorDecisions.textTitleBlueFrance(context),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DsfrProfilCardIcon extends StatelessWidget {
  const DsfrProfilCardIcon({
    super.key,
    required this.icon,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: SizedBox.square(
        dimension: 48,
        child: Icon(
          icon,
          size: 24,
          color: DsfrColorDecisions.textTitleBlueFrance(context),
        ),
      ),
    );
  }
}

class DsfrProfilCardImage extends StatelessWidget {
  const DsfrProfilCardImage({
    super.key,
    required this.imageAsset,
    this.backgroundColor,
    this.fit = BoxFit.cover,
  });

  final String imageAsset;
  final Color? backgroundColor;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? DsfrColorDecisions.backgroundContrastGrey(context),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        child: SizedBox.square(
          dimension: 48,
          child: Image.asset(imageAsset, fit: fit),
        ),
      ),
    );
  }
}
