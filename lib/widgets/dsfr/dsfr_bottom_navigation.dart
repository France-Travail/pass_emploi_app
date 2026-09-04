import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pass_emploi_app/ui/drawables.dart';

/// Bottom navigation DSFR (navbar mobile).
///
/// Item actif : barre Bleu France en haut (2px), icône + libellé `bodyXsBold`.
/// Item inactif : `textMentionGrey`, `bodyXs`.
class DsfrBottomNavigation extends StatelessWidget {
  const DsfrBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<DsfrBottomNavigationItem> items;

  /// Figma inset top separator: `rgba(118, 123, 168, 0.2)`.
  static const Color _topSeparator = Color(0x33767BA8);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        border: const Border(top: BorderSide(color: _topSeparator)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _DsfrBottomNavigationTile(
                  item: items[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DsfrBottomNavigationItem {
  const DsfrBottomNavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.withBadge = false,
    this.tileWrapper,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool withBadge;
  final Widget Function(Widget child)? tileWrapper;
}

class _DsfrBottomNavigationTile extends StatelessWidget {
  const _DsfrBottomNavigationTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final DsfrBottomNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? DsfrColorDecisions.textActiveBlueFrance(context)
        : DsfrColorDecisions.textMentionGrey(context);
    final labelStyle = selected
        ? DsfrTextStyle.bodyXsBold(color: color)
        : DsfrTextStyle.bodyXs(color: color);

    Widget icon = SizedBox(
      width: DsfrSpacings.s3w,
      height: DsfrSpacings.s3w,
      child: Icon(
        selected ? item.activeIcon : item.icon,
        size: DsfrSpacings.s3w,
        color: color,
      ),
    );

    if (item.withBadge) {
      icon = Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          Positioned(
            top: -1,
            right: -2,
            child: SvgPicture.asset(Drawables.badge),
          ),
        ],
      );
    }

    Widget tile = Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return DsfrColorDecisions.backgroundOpenBlueFrance(context);
          }
          return Colors.transparent;
        }),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: selected
                    ? DsfrColorDecisions.borderPlainBlueFrance(context)
                    : Colors.transparent,
                width: DsfrSpacings.s0v5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(height: DsfrSpacings.s1v),
                ExcludeSemantics(
                  child: Text(
                    item.label,
                    style: labelStyle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (item.tileWrapper != null) {
      tile = item.tileWrapper!(tile);
    }

    return tile;
  }
}
