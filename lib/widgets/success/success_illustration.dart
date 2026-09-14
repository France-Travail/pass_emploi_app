import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/ui/drawables.dart';

class SuccessIllustration extends StatelessWidget {
  const SuccessIllustration({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        Drawables.illustrationSuccess,
        width: size,
        height: size,
        excludeFromSemantics: true,
      ),
    );
  }
}
