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
    this.maxHeightFactor = 0.92,
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
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
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
                padding: const EdgeInsets.fromLTRB(
                  DsfrSpacings.s1w,
                  DsfrSpacings.s2w,
                  DsfrSpacings.s1w,
                  0,
                ),
                child: Row(
                  children: [
                    if (leading != null) leading!,
                    const Spacer(),
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
                      DsfrSpacings.s2w,
                      DsfrSpacings.s2w,
                      DsfrSpacings.s2w,
                    ),
                    child: child,
                  ),
                ),
              if (actions != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DsfrSpacings.s2w,
                    DsfrSpacings.s4w,
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
