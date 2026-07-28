import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/pages/notifications_center/notifications_center_page.dart';
import 'package:pass_emploi_app/pages/profil/profil_page.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/profile_button.dart';

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
              style: DsfrTextStyle.headline6(color: DsfrColorDecisions.textTitleBlueFrance(context)),
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
  final bool withProfileButton;
  final bool withAutofocusA11y;

  const PrimaryAppBar({
    super.key,
    required this.title,
    this.canPop = false,
    this.actionButton,
    this.withProfileButton = true,
    this.withAutofocusA11y = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: toolBarHeight,
      leading: canPop ? BackButton(color: AppColorsSpecifics.primaryAppBarFgColor(context)) : null,
      scrolledUnderElevation: 0,
      backgroundColor: AppColorsSpecifics.primaryAppBarBackgroundColor(context),
      title: Semantics(
        header: true,
        focusable: withAutofocusA11y,
        child: Tooltip(
          message: title,
          excludeFromSemantics: true,
          child: AutoFocusA11y(
            enabled: withAutofocusA11y,
            child: Text(
              title,
              style: TextStyles.primaryAppBar(context),
              overflow: TextOverflow.fade,
            ),
          ),
        ),
      ),
      elevation: 0,
      centerTitle: false,
      actions: [
        if (actionButton != null) ...[
          actionButton!,
          SizedBox(width: Margins.spacing_base),
        ],
        if (withProfileButton) ...[
          ProfileButton(),
          SizedBox(width: Margins.spacing_base),
        ],
      ],
    );
  }

  static const toolBarHeight = 64.0;

  @override
  Size get preferredSize => Size.fromHeight(toolBarHeight);
}

class SecondaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final Widget? leading;
  final List<Widget>? actions;

  const SecondaryAppBar({super.key, required this.title, this.backgroundColor, this.leading, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: toolBarHeight,
      titleSpacing: 0,
      iconTheme: IconThemeData(color: context.content),
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      surfaceTintColor: AppColors.transparent,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor ?? context.bg,
      title: Semantics(
        header: true,
        child: Tooltip(
          message: title,
          excludeFromSemantics: true,
          child: Text(
            title,
            style: TextStyles.secondaryAppBar(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  static const toolBarHeight = 56.0;

  @override
  Size get preferredSize => Size.fromHeight(toolBarHeight);
}

class ModeDemoAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.warningLighten,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: Margins.spacing_base, horizontal: Margins.spacing_m),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              AppIcons.info_rounded,
              color: AppColors.warning,
            ),
            SizedBox(width: Margins.spacing_base),
            Expanded(
              child: Text(
                Strings.modeDemoAppBarLabel,
                style: TextStyles.textBaseBoldWithColor(AppColors.warning),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
