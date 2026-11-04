import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';
import 'package:pass_emploi_app/ui/text_styles.dart';
import 'package:pass_emploi_app/utils/accessibility_utils.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';

class CardTitle extends StatelessWidget {
  const CardTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      // A11y 8.1 : « H/F » explicité.
      semanticsLabel: title.toOffreTitleForScreenReaders(),
      overflow: TextOverflow.ellipsis,
      // A11y : ensure title is not cut when user has text scale
      maxLines: A11yUtils.withTextScale(context) ? 6 : 3,
      style: TextStyles.textBaseBold.copyWith(fontSize: 16, color: context.content),
    );
  }
}
