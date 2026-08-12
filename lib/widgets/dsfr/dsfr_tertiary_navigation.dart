import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';

/// Navigation tertiaire DSFR — proche du [TabBar] Material.
///
/// Spec : https://www.systeme-de-design.gouv.fr/version-courante/fr/composants/navigation-tertiaire
///
/// Indicateur bas Bleu France, libellé actif Bleu France, séparateur gris.
/// Se synchronise avec un [TabController] (`DefaultTabController` / deep links).
class DsfrTertiaryNavigation extends StatelessWidget {
  const DsfrTertiaryNavigation({
    super.key,
    required this.labels,
    this.controller,
  });

  final List<String> labels;
  final TabController? controller;

  @override
  Widget build(BuildContext context) {
    final activeColor = DsfrColorDecisions.textActiveBlueFrance(context);
    final inactiveColor = DsfrColorDecisions.textActionHighGrey(context);
    final dividerColor = DsfrColorDecisions.borderDefaultGrey(context);
    final hoverColor = DsfrColorDecisions.backgroundOpenBlueFrance(context);

    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s1w),
      labelPadding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: activeColor, width: 2),
      ),
      dividerColor: dividerColor,
      dividerHeight: 1,
      labelColor: activeColor,
      unselectedLabelColor: inactiveColor,
      labelStyle: DsfrTextStyle.bodyMdBold(color: activeColor),
      unselectedLabelStyle: DsfrTextStyle.bodyMd(color: inactiveColor),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return hoverColor;
        }
        return Colors.transparent;
      }),
      tabs: [for (final label in labels) Tab(text: label)],
    );
  }
}
