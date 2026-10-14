import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/ui/drawables.dart';
import 'package:pass_emploi_app/ui/strings.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width, this.color, this.excludeFromSemantics = true});
  final double? width;
  final Color? color;

  /// A11y 1.2 : à passer à `false` quand le logo est le seul endroit de l'écran qui nomme le service
  /// (connexion, premier lancement). Ailleurs, le nom est déjà écrit à côté et le logo reste ignoré.
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    final logo = SvgPicture.asset(
      Drawables.appLogo,
      semanticsLabel: Strings.logoDescription,
      width: width,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
    return excludeFromSemantics ? ExcludeSemantics(child: logo) : logo;
  }
}
