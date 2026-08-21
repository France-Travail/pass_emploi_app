import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:pass_emploi_app/presentation/chat/chat_item.dart';
import 'package:pass_emploi_app/widgets/chat/chat_message_container.dart';

class ChatLocalFile extends StatelessWidget {
  final LocalFileMessageItem message;

  const ChatLocalFile(this.message);

  @override
  Widget build(BuildContext context) {
    return ChatMessageContainer(
      caption: message.caption,
      captionColor: message.captionColor,
      captionSuffixIcon: message.captionSuffixIcon,
      isMyMessage: true,
      isPj: true,
      content: Row(
        children: [
          SizedBox.square(
            dimension: DsfrSpacings.s3w,
            child: CircularProgressIndicator(
              color: chatBubbleForeground(context, isMyMessage: true),
            ),
          ),
          SizedBox(width: DsfrSpacings.s1w),
          Expanded(
            child: Text(
              message.fileName,
              style: DsfrTextStyle.bodySmBold(color: chatBubbleForeground(context, isMyMessage: true)),
            ),
          ),
        ],
      ),
    );
  }
}
