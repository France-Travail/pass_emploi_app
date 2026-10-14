import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart' hide DsfrNotice;
import 'package:pass_emploi_app/pages/notifications_center/notifications_center_page.dart';
import 'package:pass_emploi_app/pages/profil/profil_page.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_notice.dart';

class PrimarySliverAppbar extends StatelessWidget {
  final String title;
  final bool withNewNotifications;
  const PrimarySliverAppbar({required this.title, required this.withNewNotifications});

  static const double toolbarHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      toolbarHeight: toolbarHeight,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      titleSpacing: DsfrSpacings.s2w,
      title: AutoFocusA11y(
        child: Semantics(
          header: true,
          child: Tooltip(
            message: title,
            excludeFromSemantics: true,
            child: Text(
              title,
              style: DsfrTextStyle.headline6(color: DsfrColorDecisions.textTitleGrey(context)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: DsfrSpacings.s2w),
      actions: [
        _CentreNotif(withNewNotifications),
        DsfrButton(
          icon: DsfrIcons.userAccountCircleLine,
          iconSemanticLabel: Strings.profilButtonSemanticsLabel,
          variant: DsfrButtonVariant.tertiaryWithoutBorder,
          size: DsfrComponentSize.md,
          onPressed: () => Navigator.of(context).push(ProfilPage.materialPageRoute()),
        ),
      ],
    );
  }
}

class _CentreNotif extends StatelessWidget {
  const _CentreNotif(this.withNewNotifications);

  final bool withNewNotifications;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DsfrButton(
          icon: DsfrIcons.mediaNotification3Line,
          iconSemanticLabel: Strings.notificationsCenterTooltip,
          variant: DsfrButtonVariant.tertiaryWithoutBorder,
          size: DsfrComponentSize.md,
          onPressed: () => Navigator.of(context).push(NotificationCenter.route()),
        ),
        if (withNewNotifications)
          Positioned(
            right: DsfrSpacings.s1w,
            top: DsfrSpacings.s1w,
            child: Container(
              width: DsfrSpacings.s1w,
              height: DsfrSpacings.s1w,
              decoration: BoxDecoration(
                color: DsfrColorDecisions.backgroundFlatWarning(context),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool canPop;
  final IconButton? actionButton;
  final bool withAutofocusA11y;

  const PrimaryAppBar({
    super.key,
    required this.title,
    this.canPop = false,
    this.actionButton,
    this.withAutofocusA11y = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: toolBarHeight,
      automaticallyImplyLeading: canPop,
      leading: canPop ? BackButton(color: DsfrColorDecisions.textTitleGrey(context)) : null,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      titleSpacing: DsfrSpacings.s2w,
      // A11y : AutoFocusA11y crée son propre nœud sémantique, il doit donc englober l'en-tête
      // (et non l'inverse) pour que le rôle « en-tête » reste porté par le titre.
      title: AutoFocusA11y(
        enabled: withAutofocusA11y,
        child: Semantics(
          header: true,
          child: Tooltip(
            message: title,
            excludeFromSemantics: true,
            child: Text(
              title,
              style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ),
      elevation: 0,
      centerTitle: false,
      actionsPadding: actionButton != null ? const EdgeInsets.only(right: DsfrSpacings.s2w) : EdgeInsets.zero,
      actions: [
        if (actionButton != null) actionButton!,
      ],
    );
  }

  static const toolBarHeight = 56.0;

  @override
  Size get preferredSize => Size.fromHeight(toolBarHeight);
}

class BackLabelButton extends StatefulWidget {
  const BackLabelButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const double _iconSize = 16;
  static const EdgeInsets _padding = EdgeInsets.symmetric(vertical: 8, horizontal: 16);

  /// Largeur nécessaire pour afficher « Retour » en entier à la taille de texte choisie dans les réglages.
  static double preferredWidth(BuildContext context) {
    final label = TextPainter(
      text: TextSpan(
        text: Strings.back,
        style: DsfrTextStyle.bodyMdMedium(color: DsfrColorDecisions.textTitleGrey(context)),
      ),
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    // Marge : le style de texte du TextButton ajoute un léger espacement entre les lettres.
    final width = label.width + _iconSize + DsfrSpacings.s1w + _padding.horizontal + DsfrSpacings.s1v;
    label.dispose();
    return width.ceilToDouble();
  }

  @override
  State<BackLabelButton> createState() => _BackLabelButtonState();
}

class _BackLabelButtonState extends State<BackLabelButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final color = DsfrColorDecisions.textTitleGrey(context);
    // A11y 2.3 : contour de focus DSFR à la place du voile gris de Material (1,2:1).
    return DsfrFocusWidget(
      isFocused: _focused,
      child: TextButton(
        onPressed: widget.onPressed,
        onFocusChange: (focused) => setState(() => _focused = focused),
        style:
            TextButton.styleFrom(
              foregroundColor: color,
              padding: BackLabelButton._padding,
              minimumSize: const Size(0, DsfrSpacings.s5w),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const RoundedRectangleBorder(),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.focused) ? Colors.transparent : null,
              ),
            ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(DsfrIcons.systemArrowLeftSLine, size: BackLabelButton._iconSize, color: color),
            const SizedBox(width: DsfrSpacings.s1w),
            Flexible(
              child: Text(
                Strings.back,
                style: DsfrTextStyle.bodyMdMedium(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BackAppBar({
    super.key,
    this.actions = const [],
  });

  final List<Widget> actions;

  static const double _toolbarHeight = 48;
  static const double _leadingWidth = 140;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      primary: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: DsfrColorDecisions.backgroundDefaultGrey(context),
      toolbarHeight: _toolbarHeight,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: DsfrSpacings.s1w,
      // A11y 8.2 : « Retour » n'est plus rogné quand le texte est agrandi.
      leadingWidth: math.max(_leadingWidth, BackLabelButton.preferredWidth(context)),
      leading: Align(
        alignment: Alignment.centerLeft,
        child: BackLabelButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
      actions: [
        for (final action in actions)
          Padding(
            padding: const EdgeInsets.only(right: DsfrSpacings.s1w),
            child: Center(child: action),
          ),
      ],
    );
  }
}

class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AutoFocusA11y(
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: DsfrTextStyle.headline4(color: DsfrColorDecisions.textTitleGrey(context)),
        ),
      ),
    );
  }
}

class SecondaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final Widget? leading;
  final List<Widget>? actions;

  const SecondaryAppBar({super.key, required this.title, this.backgroundColor, this.leading, this.actions});

  @override
  Widget build(BuildContext context) {
    final parentRoute = ModalRoute.of(context);
    final canPop = parentRoute?.canPop ?? Navigator.of(context).canPop();
    final isFullscreenDialog = parentRoute?.fullscreenDialog ?? false;
    final hasActions = actions != null && actions!.isNotEmpty;

    return AppBar(
      toolbarHeight: toolBarHeight,
      automaticallyImplyLeading: false,
      titleSpacing: DsfrSpacings.s1w,
      leadingWidth: DsfrSpacings.s8w,
      iconTheme: IconThemeData(color: DsfrColorDecisions.textActionHighBlueFrance(context)),
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: leading ?? (canPop ? _SecondaryAppBarLeadingButton(isClose: isFullscreenDialog) : null),
      actions: actions,
      actionsPadding: hasActions ? const EdgeInsets.only(right: DsfrSpacings.s2w) : EdgeInsets.zero,
      backgroundColor: backgroundColor ?? DsfrColorDecisions.backgroundDefaultGrey(context),
      title: Semantics(
        header: true,
        child: Tooltip(
          message: title,
          excludeFromSemantics: true,
          child: Text(
            title,
            style: DsfrTextStyle.headline5(color: DsfrColorDecisions.textTitleGrey(context)),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  static const toolBarHeight = 56.0;

  @override
  Size get preferredSize => Size.fromHeight(toolBarHeight);
}

class _SecondaryAppBarLeadingButton extends StatelessWidget {
  const _SecondaryAppBarLeadingButton({required this.isClose});

  final bool isClose;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: DsfrButton(
        icon: isClose ? DsfrIcons.systemCloseLine : DsfrIcons.systemArrowLeftSLine,
        iconSemanticLabel: isClose ? Strings.close : Strings.back,
        variant: DsfrButtonVariant.tertiaryWithoutBorder,
        size: DsfrComponentSize.md,
        iconColor: DsfrColorDecisions.textTitleGrey(context),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

class ModeDemoAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      // Même fond que le bandeau, pour la barre d'état.
      backgroundColor: DsfrColorDecisions.backgroundContrastInfo(context),
      // A11y : bandeau d'information, pas un titre de page.
      excludeHeaderSemantics: true,
      title: DsfrNotice(titre: Strings.modeDemoAppBarLabel),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
