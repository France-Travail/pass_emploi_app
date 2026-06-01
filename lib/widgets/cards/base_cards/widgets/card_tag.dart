import 'package:flutter/material.dart';
import 'package:pass_emploi_app/models/offre_type.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';

class _CardTagColors {
  final Color backgroundLight;
  final Color contentLight;

  const _CardTagColors({
    required this.backgroundLight,
    required this.contentLight,
  });

  Color background(BuildContext context) => backgroundLight;
  Color content(BuildContext context) => contentLight;
}

class CardTag extends StatelessWidget {
  final String text;
  final IconData? icon;
  final String? semanticsLabel;
  final _CardTagColors _colors;

  /// Generic constructor — callers supply explicit colors; no dark-mode adaptation.
  CardTag({
    required this.text,
    required Color backgroundColor,
    required Color contentColor,
    this.icon,
    this.semanticsLabel,
  }) : _colors = _CardTagColors(
         backgroundLight: backgroundColor,
         contentLight: contentColor,
       );

  CardTag.evenement({
    required this.text,
  }) : icon = AppIcons.event,
       _colors = const _CardTagColors(
         backgroundLight: AppColors.accent1Lighten,
         contentLight: AppColors.additional3,
       ),
       semanticsLabel = null;

  CardTag.warning({
    required this.text,
  }) : icon = null,
       _colors = const _CardTagColors(
         backgroundLight: AppColors.warningLighten,

         contentLight: AppColors.warning,
       ),
       semanticsLabel = null;

  CardTag.secondary({
    required this.text,
    this.icon,
    this.semanticsLabel,
  }) : _colors = const _CardTagColors(
         backgroundLight: AppColors.primaryLighten,

         contentLight: AppColors.primaryCej,
       );

  CardTag.emploi()
    : icon = Icons.business_center_outlined,
      text = Strings.emploiTag,
      _colors = const _CardTagColors(
        backgroundLight: AppColors.additional2Lighten,

        contentLight: AppColors.accent3,
      ),
      semanticsLabel = null;

  CardTag.alternance()
    : icon = Icons.business_center_outlined,
      text = Strings.alternanceTag,
      _colors = const _CardTagColors(
        backgroundLight: AppColors.additional4Lighten,

        contentLight: AppColors.accent3,
      ),
      semanticsLabel = null;

  CardTag.immersion()
    : icon = Icons.business_center_outlined,
      text = Strings.immersionTag,
      _colors = const _CardTagColors(
        backgroundLight: AppColors.accent3Lighten,

        contentLight: AppColors.accent3,
      ),
      semanticsLabel = null;

  CardTag.serviceCivique()
    : icon = Icons.business_center_outlined,
      text = Strings.serviceCiviqueTag,
      _colors = const _CardTagColors(
        backgroundLight: AppColors.additional5Lighten,

        contentLight: AppColors.accent3,
      ),
      semanticsLabel = null;

  CardTag.disabledWorkersWelcome()
    : icon = null,
      text = Strings.disabledWorkersWelcome,
      _colors = const _CardTagColors(
        backgroundLight: AppColors.additional4Lighten,

        contentLight: AppColors.contentLight,
      ),
      semanticsLabel = null;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.radius_base),
        color: _colors.background(context),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_s, vertical: Margins.spacing_xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: Dimens.icon_size_base, color: _colors.content(context)),
              SizedBox(width: Margins.spacing_xs),
            ],
            Flexible(
              child: Text(
                text,
                semanticsLabel: semanticsLabel,
                style: TextStyles.textXsBold().copyWith(color: _colors.content(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension OffreTypeTagExt on OffreType {
  CardTag toCardTag() {
    return switch (this) {
      OffreType.emploi => CardTag.emploi(),
      OffreType.alternance => CardTag.alternance(),
      OffreType.immersion => CardTag.immersion(),
      OffreType.serviceCivique => CardTag.serviceCivique(),
    };
  }

  String toAlerteTagLabel() {
    return switch (this) {
      OffreType.emploi => Strings.emploiTag,
      OffreType.alternance => Strings.alternanceTag,
      OffreType.immersion => Strings.immersionTag,
      OffreType.serviceCivique => Strings.serviceCiviqueTag,
    };
  }
}
