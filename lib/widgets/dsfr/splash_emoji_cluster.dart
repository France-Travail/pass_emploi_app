import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/widgets/dsfr/emoji_tile.dart';

class SplashEmojiCluster extends StatelessWidget {
  const SplashEmojiCluster({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _PositionedEmoji(
            left: 0,
            top: 8,
            angleDegrees: -7,
            child: EmojiTile(
              emoji: '💼',
              backgroundColor: DsfrColors.greenEmeraude950,
              size: 64,
              emojiSize: 30,
            ),
          ),
          _PositionedEmoji(
            left: 194,
            top: 0,
            angleDegrees: 6,
            child: EmojiTile(
              emoji: '🧭',
              backgroundColor: DsfrColors.blueCumulus950,
              size: 64,
              emojiSize: 30,
            ),
          ),
          _PositionedEmoji(
            left: 271,
            top: 76,
            angleDegrees: -5,
            child: EmojiTile(
              emoji: '🎓',
              backgroundColor: DsfrColors.purpleGlycine950,
              size: 52,
              emojiSize: 30,
            ),
          ),
          _PositionedEmoji(
            left: 124,
            top: 68,
            angleDegrees: 8,
            child: EmojiTile(
              emoji: '🚀',
              backgroundColor: DsfrColors.pinkTuile950,
              size: 56,
              emojiSize: 30,
            ),
          ),
          _PositionedEmoji(
            left: 27,
            top: 108,
            angleDegrees: -9,
            child: EmojiTile(
              emoji: '🤝',
              backgroundColor: DsfrColors.yellowTournesol950,
              size: 48,
              emojiSize: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionedEmoji extends StatelessWidget {
  const _PositionedEmoji({
    required this.left,
    required this.top,
    required this.angleDegrees,
    required this.child,
  });

  final double left;
  final double top;
  final double angleDegrees;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: angleDegrees * math.pi / 180,
        child: child,
      ),
    );
  }
}
