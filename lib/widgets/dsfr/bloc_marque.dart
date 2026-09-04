import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class BlocMarque extends StatelessWidget {
  const BlocMarque({super.key, this.height = 70});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: Strings.republiqueFrancaise,
      image: true,
      child: SvgPicture.asset(
        isDark ? Drawables.blocMarqueDark : Drawables.blocMarqueLight,
        height: height,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
