import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pass_emploi_app/ui/strings.dart';

/// Nom « 1jeune1solution » avec le surlignage vert, centré.
class CejWordmark extends StatelessWidget {
  const CejWordmark({super.key});

  static const _textWidth = 335.0;
  static const _textHeight = 40.0;
  static const _zigzagWidth = 316.0;
  static const _zigzagHeight = 42.0;
  static const _zigzagCenterDx = 8.0;
  static const _zigzagCenterDy = 10.0;

  @override
  Widget build(BuildContext context) {
    final zigzagLeft = (_textWidth - _zigzagWidth) / 2 + _zigzagCenterDx;
    final zigzagTop = _textHeight / 2 + _zigzagCenterDy - _zigzagHeight / 2;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: _textWidth,
        height: _textHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: zigzagLeft,
              top: zigzagTop,
              child: Transform.rotate(
                angle: -5 * math.pi / 180,
                child: ExcludeSemantics(
                  child: SvgPicture.asset('assets/splash_zigzag_cej.svg'),
                ),
              ),
            ),
            SizedBox(
              width: _textWidth,
              height: _textHeight,
              child: Text(
                Strings.splashAppName,
                textAlign: TextAlign.center,
                style: DsfrTextStyle.headline1(color: DsfrColors.grey50)
                    .copyWith(height: _textHeight / 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
