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
    // A11y 8.2 (audit RAAM du 15/10/2026) : quand les onglets ne tiennent plus sur la largeur (texte agrandi), ils
    // passent sur plusieurs lignes au lieu de défiler hors de l'écran.
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 2 * DsfrSpacings.s1w;
        if (_tabsWidth(context) <= availableWidth) return _scrollableTabBar(context);
        return _WrappedTabs(
          labels: labels,
          controller: controller ?? DefaultTabController.of(context),
          badgeCountByTabIndex: badgeCountByTabIndex,
        );
      },
    );
  }

  double _tabsWidth(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    var width = 0.0;
    for (var i = 0; i < labels.length; i++) {
      final painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: DsfrTextStyle.bodyMdBold(color: Colors.black),
        ),
        textScaler: textScaler,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      width += painter.width + 2 * DsfrSpacings.s2w;
      if ((badgeCountByTabIndex[i] ?? 0) > 0) width += DsfrSpacings.s1w + textScaler.scale(DsfrSpacings.s3w);
      painter.dispose();
    }
    return width;
  }

  Widget _scrollableTabBar(BuildContext context) {
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
    final content = _tabContent(label, badgeCount);
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

Widget _tabContent(String label, int badgeCount, {TextStyle? style}) {
  if (badgeCount <= 0) return Text(label, style: style);
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(child: Text(label, style: style)),
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
}

/// Onglets sur plusieurs lignes, synchronisés avec le [TabController] (même restitution que le TabBar Material :
/// « sélectionné », libellé, « Onglet 2 sur 3 »).
class _WrappedTabs extends StatelessWidget {
  const _WrappedTabs({required this.labels, required this.controller, required this.badgeCountByTabIndex});

  final List<String> labels;
  final TabController controller;
  final Map<int, int> badgeCountByTabIndex;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: DsfrColorDecisions.borderDefaultGrey(context))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s1w),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => Wrap(
            children: [
              for (var i = 0; i < labels.length; i++)
                _WrappedTab(
                  label: labels[i],
                  badgeCount: badgeCountByTabIndex[i] ?? 0,
                  selected: controller.index == i,
                  semanticsLabel: MaterialLocalizations.of(context).tabLabel(tabIndex: i + 1, tabCount: labels.length),
                  onTap: () => controller.animateTo(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WrappedTab extends StatefulWidget {
  const _WrappedTab({
    required this.label,
    required this.badgeCount,
    required this.selected,
    required this.semanticsLabel,
    required this.onTap,
  });

  final String label;
  final int badgeCount;
  final bool selected;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  State<_WrappedTab> createState() => _WrappedTabState();
}

class _WrappedTabState extends State<_WrappedTab> with MaterialStateMixin<_WrappedTab> {
  @override
  Widget build(BuildContext context) {
    final activeColor = DsfrColorDecisions.textActiveBlueFrance(context);
    final style = widget.selected
        ? DsfrTextStyle.bodyMdBold(color: activeColor)
        : DsfrTextStyle.bodyMd(color: DsfrColorDecisions.textActionHighGrey(context));
    return Semantics(
      container: true,
      selected: widget.selected,
      label: '${widget.label}, ${widget.semanticsLabel}',
      onTap: widget.onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: widget.onTap,
        onFocusChange: updateMaterialState(WidgetState.focused),
        focusColor: DsfrColorDecisions.backgroundTransparent(context),
        hoverColor: DsfrColorDecisions.backgroundOpenBlueFrance(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DsfrSpacings.s6w),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DsfrSpacings.s2w),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: widget.selected ? activeColor : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s3v),
                child: DsfrFocusWidget(
                  isFocused: isFocused,
                  child: _tabContent(widget.label, widget.badgeCount, style: style),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
