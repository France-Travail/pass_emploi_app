import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/widgets/default_app_bar.dart';

class SuccessDialogAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SuccessDialogAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(PrimaryAppBar.toolBarHeight);

  @override
  Widget build(BuildContext context) {
    final titleColor = DsfrColorDecisions.textTitleGrey(context);
    final backgroundColor = DsfrColorDecisions.backgroundDefaultGrey(context);

    return AppBar(
      toolbarHeight: PrimaryAppBar.toolBarHeight,
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
          child: Text(
            title,
            style: DsfrTextStyle.headline4(color: titleColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
