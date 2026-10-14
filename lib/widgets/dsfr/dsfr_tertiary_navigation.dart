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
    this.badgeCountByTabIndex = const {},
  });

  final List<String> labels;
  final TabController? controller;
  final Map<int, int> badgeCountByTabIndex;

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
      // A11y 2.3 : au focus clavier, contour DSFR autour du libellé (voir _tab) à la place du fond bleu pâle (1,3:1).
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
          return hoverColor;
        }
        return Colors.transparent;
      }),
      tabs: [
        for (var i = 0; i < labels.length; i++) _tab(labels[i], badgeCountByTabIndex[i] ?? 0),
      ],
    );
  }

  Tab _tab(String label, int badgeCount) {
    final content = badgeCount <= 0
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: DsfrSpacings.s1w),
              DsfrBadge(
                label: badgeCount > 9 ? '9+' : '$badgeCount',
                type: DsfrBadgeType.news,
                size: DsfrComponentSize.sm,
                backgroundCustomColor: DsfrColors.purpleGlycine950,
                textCustomColor: DsfrColors.purpleGlycineSun319,
              ),
            ],
          );
    // Le focus clavier est porté par l'InkWell de l'onglet, juste au-dessus : on le lit pour tracer le contour DSFR.
    return Tab(
      child: Builder(
        builder: (context) => DsfrFocusWidget(
          isFocused: Focus.maybeOf(context)?.hasPrimaryFocus ?? false,
          child: content,
        ),
      ),
    );
  }
}
