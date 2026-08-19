import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/models/offre_type.dart';
import 'package:pass_emploi_app/models/rendezvous.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/cards/base_cards/widgets/card_pillule.dart';

/// Couleurs + icône pour une catégorie / type de carte (DsfrTag).
class DsfrCategoryStyle {
  final IconData? icon;
  final Color Function(BuildContext context) backgroundColor;
  final Color Function(BuildContext context) textColor;

  const DsfrCategoryStyle({
    this.icon,
    required this.backgroundColor,
    required this.textColor,
  });

  static DsfrCategoryStyle info({IconData icon = DsfrIcons.businessBriefcaseFill}) => DsfrCategoryStyle(
    icon: icon,
    backgroundColor: DsfrColorDecisions.backgroundContrastInfo,
    textColor: DsfrColorDecisions.textDefaultInfo,
  );

  static DsfrCategoryStyle news({IconData icon = DsfrIcons.businessCalendarEventFill}) => DsfrCategoryStyle(
    icon: icon,
    backgroundColor: DsfrColorDecisionsExtension.backgroundContrastNew,
    textColor: DsfrColorDecisionsExtension.textDefaultNew,
  );

  static DsfrCategoryStyle purple({IconData icon = DsfrIcons.userUserFill}) => DsfrCategoryStyle(
    icon: icon,
    backgroundColor: _purpleBackground,
    textColor: _purpleForeground,
  );

  static DsfrCategoryStyle grey({IconData? icon}) => DsfrCategoryStyle(
    icon: icon,
    backgroundColor: DsfrColorDecisions.backgroundContrastGrey,
    textColor: DsfrColorDecisions.textLabelGrey,
  );

  static Color _purpleBackground(BuildContext context) {
    return DsfrColorDecisions.isLightMode(context) ? DsfrColors.purpleGlycine950 : DsfrColors.purpleGlycine125;
  }

  static Color _purpleForeground(BuildContext context) {
    return DsfrColorDecisions.isLightMode(context) ? DsfrColors.purpleGlycineSun319 : DsfrColors.purpleGlycineMoon630;
  }
}

extension CardPilluleTypeDsfr on CardPilluleType {
  (DsfrBadgeType, String) toActionDsfrBadge() {
    return switch (this) {
      CardPilluleType.todo || CardPilluleType.doing => (DsfrBadgeType.information, Strings.doingPillule),
      CardPilluleType.done => (DsfrBadgeType.success, Strings.donePillule),
      CardPilluleType.canceled => (DsfrBadgeType.warning, Strings.canceledPillule),
      CardPilluleType.late => (DsfrBadgeType.error, Strings.latePillule),
    };
  }

  (DsfrBadgeType, String) toDemarcheDsfrBadge() {
    return switch (this) {
      CardPilluleType.todo => (DsfrBadgeType.information, Strings.todoPillule),
      CardPilluleType.doing => (DsfrBadgeType.information, Strings.doingPillule),
      CardPilluleType.done => (DsfrBadgeType.success, Strings.donePillule),
      CardPilluleType.late => (DsfrBadgeType.error, Strings.latePillule),
      CardPilluleType.canceled => (DsfrBadgeType.warning, Strings.canceledPillule),
    };
  }

  String toSemanticLabel() {
    return switch (this) {
      CardPilluleType.todo => Strings.doingPillule,
      CardPilluleType.doing => Strings.doingPillule,
      CardPilluleType.done => Strings.donePillule,
      CardPilluleType.late => Strings.latePillule,
      CardPilluleType.canceled => Strings.canceledPillule,
    };
  }
}

extension RendezvousTypeCodeDsfr on RendezvousTypeCode {
  DsfrCategoryStyle get categoryStyle {
    return switch (this) {
      RendezvousTypeCode.ENTRETIEN_INDIVIDUEL_CONSEILLER ||
      RendezvousTypeCode.ENTRETIEN_PARTENAIRE => DsfrCategoryStyle.purple(icon: DsfrIcons.userUserFill),
      RendezvousTypeCode.ATELIER ||
      RendezvousTypeCode.INFORMATION_COLLECTIVE ||
      RendezvousTypeCode.ACTIVITE_EXTERIEURES => DsfrCategoryStyle.news(icon: DsfrIcons.businessCalendarEventFill),
      RendezvousTypeCode.VISITE ||
      RendezvousTypeCode.PRESTATION ||
      RendezvousTypeCode.AUTRE => DsfrCategoryStyle.news(icon: DsfrIcons.businessCalendarEventFill),
    };
  }
}

extension OffreTypeDsfr on OffreType {
  String get dsfrTagLabel {
    return switch (this) {
      OffreType.emploi => Strings.emploiTag,
      OffreType.alternance => Strings.alternanceTag,
      OffreType.immersion => Strings.immersionTag,
      OffreType.serviceCivique => Strings.serviceCiviqueTag,
    };
  }

  String toAlerteTagLabel() => dsfrTagLabel;

  DsfrCategoryStyle get categoryStyle => DsfrCategoryStyle.grey(icon: DsfrIcons.businessBriefcaseFill);
}

/// Tag de catégorie / type (icône métier + couleurs sémantiques).
class DsfrCategoryTag extends StatelessWidget {
  final String label;
  final DsfrCategoryStyle style;
  final String? semanticsLabel;
  final bool uppercase;

  const DsfrCategoryTag({
    super.key,
    required this.label,
    required this.style,
    this.semanticsLabel,
    this.uppercase = true,
  });

  factory DsfrCategoryTag.emploiCategory({required String label}) {
    return DsfrCategoryTag(label: label, style: DsfrCategoryStyle.info());
  }

  factory DsfrCategoryTag.evenement({
    required String label,
    RendezvousTypeCode? typeCode,
  }) {
    return DsfrCategoryTag(
      label: label,
      style: typeCode?.categoryStyle ?? DsfrCategoryStyle.news(),
    );
  }

  factory DsfrCategoryTag.offre(OffreType type) {
    return DsfrCategoryTag(label: type.dsfrTagLabel, style: type.categoryStyle);
  }

  factory DsfrCategoryTag.secondary({
    required String label,
    IconData? icon,
    String? semanticsLabel,
  }) {
    return DsfrCategoryTag(
      label: label,
      style: DsfrCategoryStyle.grey(icon: icon),
      semanticsLabel: semanticsLabel,
      uppercase: false,
    );
  }

  factory DsfrCategoryTag.meta({
    required String label,
    IconData? icon,
    String? semanticsLabel,
  }) {
    return DsfrCategoryTag(
      label: label,
      style: DsfrCategoryStyle.grey(icon: icon),
      semanticsLabel: semanticsLabel,
      uppercase: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel = uppercase ? label.toUpperCase() : label;
    final color = style.textColor(context);
    final icon = style.icon;

    return Semantics(
      label: semanticsLabel ?? label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.backgroundColor(context),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: icon != null
              ? const EdgeInsets.symmetric(horizontal: 4, vertical: 4)
              : const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  displayLabel,
                  style: DsfrTextStyle.bodySmBold(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Badge de statut (terminé, en retard, annulé…).
class DsfrStatusBadge extends StatelessWidget {
  final String label;
  final DsfrBadgeType type;
  final bool excludeSemantics;

  const DsfrStatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.excludeSemantics = false,
  });

  factory DsfrStatusBadge.fromPillule({
    required CardPilluleType pillule,
    required bool forDemarche,
    bool excludeSemantics = false,
  }) {
    final (type, label) = forDemarche ? pillule.toDemarcheDsfrBadge() : pillule.toActionDsfrBadge();
    return DsfrStatusBadge(label: label, type: type, excludeSemantics: excludeSemantics);
  }

  factory DsfrStatusBadge.canceled({bool excludeSemantics = false}) {
    return DsfrStatusBadge(
      label: Strings.rendezvousCardAnnule,
      type: DsfrBadgeType.warning,
      excludeSemantics: excludeSemantics,
    );
  }

  factory DsfrStatusBadge.complet({bool excludeSemantics = false}) {
    return DsfrStatusBadge(
      label: Strings.eventComplet,
      type: DsfrBadgeType.warning,
      excludeSemantics: excludeSemantics,
    );
  }

  factory DsfrStatusBadge.nouveau({bool excludeSemantics = false}) {
    return DsfrStatusBadge(
      label: Strings.newPillule,
      type: DsfrBadgeType.news,
      excludeSemantics: excludeSemantics,
    );
  }

  factory DsfrStatusBadge.beta({bool excludeSemantics = false}) {
    return DsfrStatusBadge(
      label: Strings.betaTag,
      type: DsfrBadgeType.news,
      excludeSemantics: excludeSemantics,
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = DsfrBadge(
      label: label,
      type: type,
      size: DsfrComponentSize.sm,
    );
    if (excludeSemantics) return ExcludeSemantics(child: badge);
    return badge;
  }
}
