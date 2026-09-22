import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width, this.color});
  final double? width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SvgPicture.asset(
        Drawables.appLogo,
        semanticsLabel: Strings.logoDescription,
        width: width,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      ),
    );
  }
}
