import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';

class OffreDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OffreDetailsAppBar({
    super.key,
    this.actions = const [],
  });

  final List<Widget> actions;

  static const double _toolbarHeight = 48;

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);
    return AppBar(
      primary: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: backgroundColor,
      toolbarHeight: _toolbarHeight,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: DsfrSpacings.s1w,
      leadingWidth: 140,
      leading: Align(
        alignment: Alignment.centerLeft,
        child: DsfrButton(
          label: Strings.back,
          icon: DsfrIcons.systemArrowLeftSLine,
          variant: DsfrButtonVariant.tertiaryWithoutBorder,
          size: DsfrComponentSize.md,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
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

class OffreDetailsPageTitle extends StatelessWidget {
  const OffreDetailsPageTitle(this.title, {super.key});

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
