import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

class SuccessDialogAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SuccessDialogAppBar({super.key, required this.title, this.height = PrimaryAppBar.toolBarHeight});

  final String title;

  /// A11y 8.2 : passer une hauteur qui suit la taille du texte (`textScaler.scale`) pour que le titre tienne.
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  State<SuccessDialogAppBar> createState() => _SuccessDialogAppBarState();
}

class _SuccessDialogAppBarState extends State<SuccessDialogAppBar> {
  bool _leadingFocused = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final titleColor = DsfrColorDecisions.textTitleGrey(context);
    final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
    // Même bouton que celui qu'AppBar choisirait (fermer pour une page plein écran), avec le focus DSFR.
    final route = ModalRoute.of(context);
    final canPop = route?.impliesAppBarDismissal ?? false;
    final useClose = route is PageRoute && route.fullscreenDialog;
    final buttonStyle = IconButton.styleFrom(focusColor: DsfrColorDecisions.backgroundTransparent(context));

    return AppBar(
      toolbarHeight: widget.height,
      // A11y 2.3 : contour de focus DSFR à la place du voile gris de Material.
      leading: canPop
          ? Center(
              child: DsfrFocusWidget(
                isFocused: _leadingFocused,
                child: Focus(
                  canRequestFocus: false,
                  skipTraversal: true,
                  onFocusChange: (focused) => setState(() => _leadingFocused = focused),
                  child: useClose ? CloseButton(style: buttonStyle) : BackButton(style: buttonStyle),
                ),
              ),
            )
          : null,
      titleSpacing: DsfrSpacings.s2w,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: backgroundColor,
      iconTheme: IconThemeData(color: titleColor),
      title: Semantics(
        header: true,
        child: Tooltip(
          message: title,
          excludeFromSemantics: true,
          // A11y 8.2 : à 200 %, le titre passe sur deux lignes au lieu d'être coupé.
          child: Text(
            title,
            style: DsfrTextStyle.headline4(color: titleColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
