import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/app_icons.dart';
import 'package:pass_emploi_app/ui/dimens.dart';
import 'package:pass_emploi_app/ui/margins.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';

enum CardPilluleType {
  todo,
  doing,
  done,
  late,
  canceled;

  CardPillule toActionCardPillule({bool excludeSemantics = false}) {
    return switch (this) {
      CardPilluleType.todo => CardPillule.actionTodo(excludeSemantics),
      CardPilluleType.doing => CardPillule.actionTodo(excludeSemantics),
      CardPilluleType.done => CardPillule.actionDone(excludeSemantics),
      CardPilluleType.late => CardPillule.actionLate(excludeSemantics),
      CardPilluleType.canceled => CardPillule.actionDone(excludeSemantics),
    };
  }

  CardPillule toDemarcheCardPillule({bool excludeSemantics = false}) {
    return switch (this) {
      CardPilluleType.todo => CardPillule.demarcheTodo(excludeSemantics),
      CardPilluleType.doing => CardPillule.demarcheDoing(excludeSemantics),
      CardPilluleType.done => CardPillule.demarcheDone(excludeSemantics),
      CardPilluleType.late => CardPillule.demarcheLate(excludeSemantics),
      CardPilluleType.canceled => CardPillule.demarcheCanceled(excludeSemantics),
    };
  }

  String toSemanticLabel() {
    return switch (this) {
      CardPilluleType.todo => Strings.doingPillule,
      CardPilluleType.doing => Strings.doingPillule,
      CardPilluleType.done => Strings.donePillule,
      CardPilluleType.late => Strings.latePillule,
      CardPilluleType.canceled => Strings.donePillule,
    };
  }
}

class _CardPilluleColors {
  final Color background;
  final Color content;

  const _CardPilluleColors({
    required this.background,

    required this.content,
  });

  /// Shorthand for pillules that don't need dark-mode adaptation.
  const _CardPilluleColors.fixed({required this.background, required this.content});
}

class CardPillule extends StatelessWidget {
  final String text;
  final bool excludeSemantics;
  final IconData? icon;
  final _CardPilluleColors _colors;

  /// Generic constructor — callers supply explicit colors; no dark-mode adaptation.
  CardPillule({
    required this.text,
    required Color contentColor,
    required Color backgroundColor,
    required this.excludeSemantics,
    this.icon,
  }) : _colors = _CardPilluleColors.fixed(background: backgroundColor, content: contentColor);

  CardPillule.newNotification([this.excludeSemantics = false])
    : text = Strings.newPillule,
      _colors = const _CardPilluleColors(
        background: AppColors.warningLighten,

        content: AppColors.warning,
      ),
      icon = null;

  CardPillule.actionTodo([this.excludeSemantics = false])
    : text = Strings.doingPillule,
      _colors = const _CardPilluleColors(
        background: AppColors.accent1Lighten,

        content: AppColors.accent1,
      ),
      icon = null;

  CardPillule.actionDone([this.excludeSemantics = false])
    : text = Strings.donePillule,
      _colors = const _CardPilluleColors(
        background: AppColors.successLighten,

        content: AppColors.success,
      ),
      icon = null;

  CardPillule.actionLate([this.excludeSemantics = false])
    : text = Strings.latePillule,
      _colors = const _CardPilluleColors(
        background: AppColors.warningLighten,

        content: AppColors.warning,
      ),
      icon = null;

  CardPillule.demarcheTodo([this.excludeSemantics = false])
    : text = Strings.todoPillule,
      _colors = const _CardPilluleColors(
        background: AppColors.accent3Lighten,

        content: AppColors.primaryDarken,
      ),
      icon = null;

  CardPillule.demarcheDoing([this.excludeSemantics = false])
    : text = Strings.doingPillule,
      _colors = const _CardPilluleColors(
        background: AppColors.accent1Lighten,

        content: AppColors.accent1,
      ),
      icon = null;

  CardPillule.demarcheDone([this.excludeSemantics = false])
    : text = Strings.donePillule,
      _colors = const _CardPilluleColors(
        background: AppColors.successLighten,

        content: AppColors.success,
      ),
      icon = null;

  CardPillule.demarcheLate([this.excludeSemantics = false])
    : text = Strings.latePillule,
      _colors = const _CardPilluleColors(
        background: AppColors.warningLighten,

        content: AppColors.warning,
      ),
      icon = null;

  CardPillule.demarcheCanceled([this.excludeSemantics = false])
    : text = Strings.canceledPillule,
      _colors = const _CardPilluleColors(
        background: AppColors.accent3Lighten,

        content: AppColors.primaryDarken,
      ),
      icon = AppIcons.block;

  CardPillule.evenementCanceled([this.excludeSemantics = false])
    : text = Strings.rendezvousCardAnnule,
      _colors = const _CardPilluleColors(
        background: AppColors.primaryLighten,
        content: AppColors.primaryCej,
      ),
      icon = AppIcons.block;

  @override
  Widget build(BuildContext context) {
    final fgcolor = context.isDarkTheme ? AppColors.contentLight : _colors.content;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.radius_l),
        color: _colors.background,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Margins.spacing_s, vertical: Margins.spacing_xs),
        child: Semantics(
          excludeSemantics: excludeSemantics,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fgcolor, size: Dimens.icon_size_base),
                SizedBox(width: Margins.spacing_xs),
              ],
              Text(text, style: TextStyles.textXsBold().copyWith(color: fgcolor)),
            ],
          ),
        ),
      ),
    );
  }
}
