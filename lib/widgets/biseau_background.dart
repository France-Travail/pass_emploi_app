import 'package:flutter/material.dart';
import 'package:pass_emploi_app/ui/app_colors.dart';

class BiseauBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bgColor = AppColorsSpecifics.primaryToGrey100(context);
    return Stack(
      children: [
        Container(color: bgColor),
        ClipPath(
          clipper: DiagonalClipper(),
          child: Container(
            color: context.isDarkTheme ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
