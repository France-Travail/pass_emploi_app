import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';

Future<T?> showDsfrBottomSheet<T>({
  required BuildContext context,
  required String name,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: DsfrColorDecisions.backgroundTransparent(context),
    barrierColor: DsfrColorDecisions.backgroundOverlayGrey(context),
    barrierLabel: Strings.bottomSheetBarrierLabel,
    elevation: 0,
    shape: const RoundedRectangleBorder(),
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    useSafeArea: false,
    routeSettings: RouteSettings(name: name),
    builder: (context) => Theme(
      data: isDarkMode ? DsfrThemeData.dark() : DsfrThemeData.light(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: builder(context),
        ),
      ),
    ),
  );
}

class DsfrBottomSheet extends StatelessWidget {
  const DsfrBottomSheet({
    super.key,
    required this.child,
    this.leading,
    this.actions,
    this.isDismissible = true,
    this.closeLabel,
    this.maxHeightFactor = 0.80,
    this.shrinkWrap = false,
  });

  final Widget child;
  final Widget? leading;
  final Widget? actions;
  final bool isDismissible;
  final String? closeLabel;
  final double maxHeightFactor;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    // A11y 8.2 et 11.9 : clavier ouvert, la fenêtre ne dépasse plus sous la barre d'état, et les boutons du bas
    // défilent avec le contenu pour laisser la place au champ en cours de saisie.
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final keyboardOpen = keyboardHeight > 0;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final availableHeight = screenHeight - keyboardHeight - MediaQuery.paddingOf(context).top;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: math.max(0, math.min(screenHeight * maxHeightFactor, availableHeight)),
      ),
      child: Material(
        color: DsfrColorDecisions.backgroundDefaultGrey(context),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DsfrSpacings.s1w,
                  vertical: DsfrSpacings.s2w,
                ),
                // A11y 8.2 : à 200 %, « Fermer » passe sous le bouton de gauche au lieu de déborder de l'écran.
                child: Wrap(
                  alignment: leading != null ? WrapAlignment.spaceBetween : WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: DsfrSpacings.s1w,
                  children: [
                    if (leading != null) leading!,
                    if (isDismissible)
                      DsfrButton(
                        label: closeLabel ?? Strings.close,
                        icon: DsfrIcons.systemCloseLine,
                        iconLocation: DsfrButtonIconLocation.right,
                        variant: DsfrButtonVariant.tertiaryWithoutBorder,
                        size: DsfrComponentSize.sm,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
              ),
              if (shrinkWrap)
                child
              else
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      DsfrSpacings.s2w,
                      0,
                      DsfrSpacings.s2w,
                      DsfrSpacings.s2w,
                    ),
                    // Le contenu reste au même endroit de l'arbre : le champ garde le focus quand le clavier s'ouvre.
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        child,
                        if (keyboardOpen && actions != null) ...[
                          const SizedBox(height: DsfrSpacings.s2w),
                          actions!,
                        ],
                      ],
                    ),
                  ),
                ),
              if (actions != null && (shrinkWrap || !keyboardOpen))
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DsfrSpacings.s2w,
                    0,
                    DsfrSpacings.s2w,
                    DsfrSpacings.s2w,
                  ),
                  child: actions,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DsfrBottomSheetMoreActionsButton extends StatelessWidget {
  const DsfrBottomSheetMoreActionsButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DsfrButton(
      label: Strings.moreActions,
      icon: DsfrIcons.systemMoreLine,
      iconLocation: DsfrButtonIconLocation.right,
      variant: DsfrButtonVariant.tertiaryWithoutBorder,
      size: DsfrComponentSize.sm,
      onPressed: onPressed,
    );
  }
}

class DsfrDetailIconLine extends StatelessWidget {
  const DsfrDetailIconLine({
    super.key,
    required this.icon,
    required this.text,
    this.semanticsLabel,
  });

  final IconData icon;
  final String text;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              icon,
              size: 16,
              color: DsfrColorDecisions.textDefaultGrey(context),
            ),
          ),
          const SizedBox(width: DsfrSpacings.s1w),
          Expanded(
            child: ExcludeSemantics(
              excluding: semanticsLabel != null,
              child: Text(
                text,
                style: DsfrTextStyle.bodyMd(
                  color: DsfrColorDecisions.textDefaultGrey(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
