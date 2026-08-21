import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/string_a11y_extensions.dart';

Color chatBubbleBackground(BuildContext context, {required bool isMyMessage}) {
  return isMyMessage
      ? DsfrColorDecisions.backgroundActionHighBlueFrance(context)
      : DsfrColorDecisions.backgroundDefaultGreyActive(context);
}

Color chatBubbleForeground(BuildContext context, {required bool isMyMessage}) {
  return isMyMessage
      ? DsfrColorDecisions.textInvertedGrey(context)
      : DsfrColorDecisions.textTitleGrey(context);
}

TextStyle chatBubbleTextStyle(BuildContext context, {required bool isMyMessage}) {
  return DsfrTextStyle.bodySm(color: chatBubbleForeground(context, isMyMessage: isMyMessage));
}

class ChatMessageContainer extends StatelessWidget {
  const ChatMessageContainer({
    super.key,
    required this.content,
    required this.caption,
    required this.captionColor,
    required this.isMyMessage,
    required this.isPj,
    this.captionSuffixIcon,
  });

  final Widget content;
  final String caption;
  final Color? captionColor;
  final bool isMyMessage;
  final bool isPj;
  final IconData? captionSuffixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DsfrSpacings.s1v),
      child: Column(
        crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _ChatBubble(
            isPj: isPj,
            isMyMessage: isMyMessage,
            child: content,
          ),
          SizedBox(height: DsfrSpacings.s1v),
          Row(
            mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Caption(caption, captionColor ?? DsfrColorDecisions.textDefaultGrey(context)),
              if (captionSuffixIcon != null) ...[
                SizedBox(width: DsfrSpacings.s1w),
                Icon(
                  captionSuffixIcon,
                  size: DsfrSpacings.s2w,
                  color: captionColor ?? DsfrColorDecisions.textDefaultGrey(context),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.isMyMessage, required this.child, required this.isPj});

  final bool isPj;
  final bool isMyMessage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isMyMessage ? Strings.chatA11yMessageFromMe : Strings.chatA11yMessageFromMyConseiller,
      child: Container(
        margin: EdgeInsets.only(
          left: isMyMessage ? 77.0 : 0,
          right: !isMyMessage ? 77.0 : 0,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: DsfrSpacings.s2w,
          vertical: isPj ? DsfrSpacings.s1w : DsfrSpacings.s3v,
        ),
        decoration: BoxDecoration(
          color: chatBubbleBackground(context, isMyMessage: isMyMessage),
          borderRadius: BorderRadius.all(Radius.circular(DsfrSpacings.s1v)),
        ),
        child: child,
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  final String text;
  final Color color;

  const _Caption(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DsfrTextStyle.bodySm(color: color),
      semanticsLabel: text.toTimeAndDurationForScreenReaders(),
    );
  }
}

/// Bouton d'action dans une bulle : fond blanc pour rester lisible
/// sur les bulles conseiller (gris) et jeune (bleu France).
class ChatBubbleActionButton extends StatelessWidget {
  const ChatBubbleActionButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textColor = DsfrColorDecisions.textTitleGrey(context);
    return ColoredBox(
      color: DsfrColorDecisions.backgroundDefaultGrey(context),
      child: DsfrRawButton(
        variant: DsfrButtonVariant.tertiaryWithoutBorder,
        size: DsfrComponentSize.md,
        foregroundColor: textColor,
        onPressed: onPressed,
        child: icon == null
            ? Text(
                label,
                textAlign: TextAlign.center,
                style: DsfrTextStyle.bodyMdBold(color: textColor),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: DsfrSpacings.s2w, color: textColor),
                  const SizedBox(width: DsfrSpacings.s1w),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: DsfrTextStyle.bodyMdBold(color: textColor),
                  ),
                ],
              ),
      ),
    );
  }
}
