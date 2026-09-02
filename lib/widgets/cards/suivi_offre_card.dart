import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/offre_emploi.dart';
import 'package:pass_emploi_app/models/offre_type.dart';
import 'package:pass_emploi_app/pages/offre_page.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/favori_heart.dart';

class SuiviOffreCard<T> extends StatelessWidget {
  const SuiviOffreCard({
    super.key,
    required this.id,
    required this.offreType,
    required this.title,
    required this.company,
    required this.place,
    required this.origin,
    required this.onTap,
    required this.showCandidatureBadge,
  });

  final String id;
  final OffreType offreType;
  final String title;
  final String? company;
  final String? place;
  final Origin? origin;
  final VoidCallback onTap;
  final bool showCandidatureBadge;

  @override
  Widget build(BuildContext context) {
    final subtitle = [company, place].whereType<String>().where((e) => e.isNotEmpty).join(' - ');
    final borderColor = DsfrColorDecisions.borderDefaultGrey(context);

    return Material(
      color: DsfrColorDecisions.backgroundDefaultGrey(context),
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DsfrSpacings.s3v),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: _semanticsLabel(subtitle),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _Logo(origin: origin),
                        const SizedBox(width: DsfrSpacings.s3v),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DsfrTag(
                                label: _typeLabel(offreType),
                                size: DsfrComponentSize.sm,
                                backgroundColor: DsfrColorDecisions.backgroundContrastGrey(context),
                                textColor: DsfrColorDecisions.textLabelGrey(context),
                              ),
                              const SizedBox(height: DsfrSpacings.s1v),
                              Text(
                                title,
                                style: DsfrTextStyle.bodyMdBold(
                                  color: DsfrColorDecisions.textTitleGrey(context),
                                ),
                              ),
                              if (subtitle.isNotEmpty) ...[
                                Text(
                                  subtitle,
                                  style: DsfrTextStyle.bodySm(
                                    color: DsfrColorDecisions.textTitleGrey(context),
                                  ),
                                ),
                              ],
                              if (showCandidatureBadge) ...[
                                const SizedBox(height: DsfrSpacings.s1v),
                                DsfrBadge(
                                  label: Strings.candidatureEnvoyee.toUpperCase(),
                                  type: DsfrBadgeType.information,
                                  size: DsfrComponentSize.sm,
                                  withIcon: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FavoriHeart<T>(
                offreId: id,
                a11yLabel: title,
                withBorder: false,
                from: OffrePage.offreFavoris,
                icon: DsfrIcons.systemStarLine,
                iconActive: DsfrIcons.systemStarFill,
                iconColor: DsfrColorDecisions.textActionHighBlueFrance(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _semanticsLabel(String subtitle) {
    final parts = [
      _typeLabel(offreType),
      title,
      if (subtitle.isNotEmpty) subtitle,
      if (showCandidatureBadge) Strings.candidatureEnvoyee,
    ];
    return parts.join('. ');
  }

  static String _typeLabel(OffreType type) {
    return switch (type) {
      OffreType.emploi => Strings.offreTypeEmploiLabel,
      OffreType.alternance => Strings.alternanceTag,
      OffreType.immersion => Strings.immersionTag,
      OffreType.serviceCivique => Strings.serviceCiviqueTag,
    };
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.origin});

  final Origin? origin;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: DsfrColorDecisions.backgroundOpenBlueFrance(context)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: SizedBox.square(
          dimension: DsfrSpacings.s6w,
          child: switch (origin) {
            final PartenaireOrigin partenaire => Image.network(
              partenaire.logoUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _FallbackLogo(),
            ),
            FranceTravailOrigin() => Image.asset(Drawables.franceTravailLogo, fit: BoxFit.contain),
            null => _FallbackLogo(),
          },
        ),
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DsfrColorDecisions.backgroundContrastInfo(context),
      child: Center(
        child: Icon(
          DsfrIcons.businessBriefcaseLine,
          color: DsfrColorDecisions.textTitleBlueFrance(context),
          size: DsfrSpacings.s3w,
        ),
      ),
    );
  }
}
