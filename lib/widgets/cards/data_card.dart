import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/image_source.dart';
import 'package:pass_emploi_app/models/offre_emploi.dart';
import 'package:pass_emploi_app/pages/offre_page.dart';
import 'package:pass_emploi_app/presentation/offre_emploi/offre_emploi_origin_view_model.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/utils/date_derniere_consultation_provider.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_event_card.dart';
import 'package:pass_emploi_app/widgets/favori_heart.dart';

class DataCard<T> extends StatelessWidget {
  final Widget? leading;
  final String titre;
  final String? category;
  final String? sousTitre;
  final String? lieu;
  final String? date;
  final String? contractType;
  final String? duration;
  final String? secteurActivite;
  final VoidCallback onTap;
  final String? id;
  final OffrePage? from;
  final Origin? origin;
  final Widget? additionalChild;
  final bool withFavori;

  const DataCard({
    super.key,
    this.leading,
    required this.titre,
    required this.sousTitre,
    required this.lieu,
    required this.onTap,
    this.date,
    this.id,
    this.from,
    this.category,
    this.origin,
    this.contractType,
    this.duration,
    this.secteurActivite,
    this.additionalChild,
    this.withFavori = true,
  });

  @override
  Widget build(BuildContext context) {
    return DateDerniereActionProvider(
      id: id ?? "",
      builder: (dateActionViewModel) {
        final contractLabel = _contractLabel();
        final mention = dateActionViewModel.datePostulation != null
            ? Strings.offrePostulatedSeen(dateActionViewModel.datePostulation!)
            : dateActionViewModel.dateDerniereConsultation != null
            ? Strings.offreLastSeen(dateActionViewModel.dateDerniereConsultation!)
            : null;

        return Material(
          color: DsfrColorDecisions.backgroundDefaultGrey(context),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              border: Border.all(color: DsfrColorDecisions.borderDefaultGrey(context)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: _semanticsLabel(contractLabel, mention),
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (origin != null) ...[
                              Padding(
                                padding: const EdgeInsets.all(DsfrSpacings.s3v),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: _Logo(origin: origin),
                                ),
                              ),
                            ],
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  origin != null ? 0 : DsfrSpacings.s3v,
                                  DsfrSpacings.s3v,
                                  DsfrSpacings.s3v,
                                  DsfrSpacings.s3v,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      titre,
                                      style: DsfrTextStyle.bodyMdBold(
                                        color: DsfrColorDecisions.textTitleGrey(context),
                                      ),
                                    ),
                                    if (sousTitre != null && sousTitre!.isNotEmpty)
                                      Text(
                                        sousTitre!,
                                        style: DsfrTextStyle.bodySm(
                                          color: DsfrColorDecisions.textTitleGrey(context),
                                        ),
                                      ),
                                    if (leading != null) ...[
                                      const SizedBox(height: DsfrSpacings.s1v),
                                      leading!,
                                    ],
                                    if (_hasComplements(contractLabel)) ...[
                                      const SizedBox(height: DsfrSpacings.s1v),
                                      ..._buildComplements(contractLabel),
                                    ],
                                    if (mention != null) ...[
                                      const SizedBox(height: DsfrSpacings.s1w),
                                      Text(
                                        mention,
                                        style: DsfrTextStyle.bodyXs(
                                          color: DsfrColorDecisions.textMentionGrey(context),
                                        ),
                                      ),
                                    ],
                                    if (additionalChild != null) ...[
                                      const SizedBox(height: DsfrSpacings.s1w),
                                      additionalChild!,
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (withFavori && id != null && from != null)
                    Align(
                      alignment: Alignment.topRight,
                      widthFactor: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: DsfrSpacings.s1w, right: DsfrSpacings.s1w),
                        child: FavoriHeart<T>(
                          offreId: id!,
                          a11yLabel: sousTitre != null ? '$titre ${sousTitre!}' : titre,
                          withBorder: false,
                          from: from!,
                          icon: DsfrIcons.systemStarLine,
                          iconActive: DsfrIcons.systemStarFill,
                          iconColor: DsfrColorDecisions.textActionHighBlueFrance(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String? _contractLabel() {
    final type = contractType?.trim();
    final duree = duration?.trim();
    if (type != null && type.isNotEmpty && duree != null && duree.isNotEmpty) {
      return "$type - $duree";
    }
    if (type != null && type.isNotEmpty) return type;
    if (duree != null && duree.isNotEmpty) return duree;
    return null;
  }

  bool _hasComplements(String? contractLabel) {
    return category?.isNotEmpty == true ||
        lieu?.isNotEmpty == true ||
        contractLabel != null ||
        secteurActivite?.isNotEmpty == true ||
        (date != null && date!.isNotEmpty);
  }

  List<Widget> _buildComplements(String? contractLabel) {
    final complements = <({IconData icon, String text})>[
      if (category?.isNotEmpty == true) (icon: DsfrIcons.systemInformationLine, text: category!),
      if (lieu?.isNotEmpty == true) (icon: DsfrIcons.mapMapPin2Line, text: lieu!),
      if (contractLabel != null) (icon: DsfrIcons.businessBriefcaseLine, text: contractLabel),
      if (secteurActivite?.isNotEmpty == true) (icon: DsfrIcons.systemInformationLine, text: secteurActivite!),
      if (date != null && date!.isNotEmpty) (icon: DsfrIcons.businessCalendarEventLine, text: date!),
    ];

    return [
      for (var i = 0; i < complements.length; i++) ...[
        if (i > 0) const SizedBox(height: DsfrSpacings.s1v),
        DsfrEventCardComplement(icon: complements[i].icon, text: complements[i].text),
      ],
    ];
  }

  String _semanticsLabel(String? contractLabel, String? mention) {
    return [
      titre,
      if (sousTitre?.isNotEmpty == true) sousTitre!,
      if (category?.isNotEmpty == true) category!,
      if (lieu?.isNotEmpty == true) lieu!,
      if (contractLabel != null) contractLabel,
      if (secteurActivite?.isNotEmpty == true) secteurActivite!,
      if (date?.isNotEmpty == true) date!,
      if (mention != null) mention,
    ].join('. ');
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.origin});

  final Origin? origin;

  @override
  Widget build(BuildContext context) {
    final originViewModel = OffreEmploiOriginViewModel.from(origin);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: DsfrColorDecisions.backgroundOpenBlueFrance(context)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: SizedBox.square(
          dimension: DsfrSpacings.s6w,
          child: switch (originViewModel?.source) {
            final NetworkImageSource network => Image.network(
              network.url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const _FallbackLogo(),
            ),
            final AssetsImageSource asset => Image.asset(asset.path, fit: BoxFit.contain),
            null => const _FallbackLogo(),
          },
        ),
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DsfrColorDecisions.backgroundContrastInfo(context),
      child: Center(
        child: Icon(
          DsfrIcons.systemInformationLine,
          color: DsfrColorDecisions.textTitleBlueFrance(context),
          size: DsfrSpacings.s3w,
        ),
      ),
    );
  }
}
