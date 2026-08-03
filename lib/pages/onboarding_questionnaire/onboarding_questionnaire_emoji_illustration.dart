import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: SizedBox.square(
        dimension: 48,
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: 24,
              height: 32 / 24,
              // Force color emoji on iOS for dingbats like ✈️ (U+2708).
              fontFamily: defaultTargetPlatform == TargetPlatform.iOS ? 'Apple Color Emoji' : null,
            ),
          ),
        ),
      ),
    );
  }
}
