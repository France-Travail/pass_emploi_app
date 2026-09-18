import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/widgets/offre_details/offre_details_tag.dart';

class OffreDetailsHeader extends StatelessWidget {
  const OffreDetailsHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.dateLabel,
    this.leading,
    this.tags = const [],
    this.metaLabel,
  });

  final String title;
  final String? subtitle;
  final String? dateLabel;
  final Widget? leading;
  final List<OffreDetailsTag> tags;
  final String? metaLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.artworkDecorativeBlueFrance(context),
        borderRadius: BorderRadius.circular(DsfrSpacings.s1w),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DsfrColorDecisions.backgroundDefaultGrey(context),
          borderRadius: BorderRadius.circular(DsfrSpacings.s1w),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: DsfrColorDecisions.borderDefaultBlueFrance(context),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(DsfrSpacings.s3w - 4, DsfrSpacings.s3v, DsfrSpacings.s3w, DsfrSpacings.s3w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (dateLabel != null) ...[
                        Text(
                          dateLabel!,
                          style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultGrey(context)),
                        ),
                        const SizedBox(height: DsfrSpacings.s1w),
                      ],
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(height: DsfrSpacings.s1w),
                      ],
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: DsfrSpacings.s1w),
                        Text(
                          subtitle!,
                          style: DsfrTextStyle.bodyMd(
                            color: DsfrColorDecisions.textActionHighBlueFrance(context),
                          ),
                        ),
                      ],
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: DsfrSpacings.s1w),
                        Wrap(
                          spacing: DsfrSpacings.s1w,
                          runSpacing: DsfrSpacings.s1w,
                          children: tags,
                        ),
                      ],
                      if (metaLabel != null) ...[
                        const SizedBox(height: DsfrSpacings.s1w),
                        Text(
                          metaLabel!,
                          style: DsfrTextStyle.bodyXs(color: DsfrColorDecisions.textTitleGrey(context)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
