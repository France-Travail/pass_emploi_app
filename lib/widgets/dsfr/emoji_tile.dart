import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EmojiTile extends StatelessWidget {
  const EmojiTile({
    super.key,
    required this.emoji,
    required this.backgroundColor,
    this.size = 96,
    this.emojiSize,
    this.borderRadius = 16,
  });

  final String emoji;
  final Color backgroundColor;
  final double size;
  final double? emojiSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final resolvedEmojiSize = emojiSize ?? size * 0.48;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: resolvedEmojiSize,
              height: 1,
              // Force color emoji on iOS for dingbats.
              fontFamily: defaultTargetPlatform == TargetPlatform.iOS ? 'Apple Color Emoji' : null,
            ),
          ),
        ),
      ),
    );
  }
}
