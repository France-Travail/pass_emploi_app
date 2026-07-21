import 'package:flutter/material.dart';

class InviteOnboardingEmojiIllustration extends StatelessWidget {
  const InviteOnboardingEmojiIllustration({
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
            style: const TextStyle(fontSize: 24, height: 32 / 24),
          ),
        ),
      ),
    );
  }
}
