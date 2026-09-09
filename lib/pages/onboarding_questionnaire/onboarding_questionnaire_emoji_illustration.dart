import 'package:flutter/material.dart';
import 'package:pass_emploi_app/widgets/dsfr/emoji_tile.dart';

class OnboardingQuestionnaireEmojiIllustration extends StatelessWidget {
  const OnboardingQuestionnaireEmojiIllustration({
    super.key,
    required this.emoji,
    required this.backgroundColor,
  });

  final String emoji;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return EmojiTile(
      emoji: emoji,
      backgroundColor: backgroundColor,
      size: 48,
      emojiSize: 24,
      borderRadius: 15,
    );
  }
}
