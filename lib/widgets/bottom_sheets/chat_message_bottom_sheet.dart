import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/analytics/analytics_constants.dart';
import 'package:pass_emploi_app/pages/chat_edit_message_page.dart';
import 'package:pass_emploi_app/presentation/chat/chat_item.dart';
import 'package:pass_emploi_app/presentation/chat/chat_message_bottom_sheet_view_model.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/a11y/auto_focus.dart';
import 'package:pass_emploi_app/widgets/dsfr/dsfr_bottom_sheet.dart';

class ChatMessageBottomSheet extends StatelessWidget {
  const ChatMessageBottomSheet({super.key, required this.chatItem});

  final ChatItem chatItem;

  static void show(BuildContext context, ChatItem chatItem) {
    showDsfrBottomSheet(
      context: context,
      name: AnalyticsScreenNames.chat,
      builder: (context) => ChatMessageBottomSheet(chatItem: chatItem),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ChatMessageBottomSheetViewModel>(
      converter: (store) => ChatMessageBottomSheetViewModel.create(store, chatItem.messageId),
      builder: (context, viewModel) {
        return DsfrBottomSheet(
          shrinkWrap: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DsfrSpacings.s2w,
              DsfrSpacings.s2w,
              DsfrSpacings.s2w,
              DsfrSpacings.s2w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AutoFocusA11y(
                  child: Semantics(
                    header: true,
                    child: Text(
                      Strings.chatMessageBottomSheetTitle,
                      style: DsfrTextStyle.headline4(
                        color: DsfrColorDecisions.textTitleGrey(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: DsfrSpacings.s3w),
                ..._actions(viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _actions(ChatMessageBottomSheetViewModel viewModel) {
    final actions = <Widget>[
      if (viewModel.withCopyOption) _CopyMessageButton(viewModel.content),
      if (viewModel.withEditOption) _EditMessageButton(viewModel.onEdit, viewModel.content),
      if (viewModel.withDeleteOption) _DeleteMessageButton(viewModel.onDelete),
    ];

    return [
      for (var i = 0; i < actions.length; i++) ...[
        if (i > 0) const SizedBox(height: DsfrSpacings.s1w),
        actions[i],
      ],
    ];
  }
}

class _CopyMessageButton extends StatelessWidget {
  const _CopyMessageButton(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DsfrButton(
      icon: DsfrIcons.documentClipboardLine,
      label: Strings.chatCopyMessage,
      variant: DsfrButtonVariant.tertiary,
      size: DsfrComponentSize.lg,
      onPressed: () {
        Clipboard.setData(ClipboardData(text: text)).then((value) {
          if (context.mounted) Navigator.pop(context);
        });
      },
    );
  }
}

class _EditMessageButton extends StatelessWidget {
  const _EditMessageButton(this.onEditMessage, this.content);

  final void Function(String) onEditMessage;
  final String content;

  @override
  Widget build(BuildContext context) {
    return DsfrButton(
      icon: DsfrIcons.designPencilLine,
      label: Strings.chatEditMessage,
      variant: DsfrButtonVariant.tertiary,
      size: DsfrComponentSize.lg,
      onPressed: () async {
        final updatedContent = await Navigator.of(context).push(ChatEditMessagePage.route(content));
        if (updatedContent != null) {
          onEditMessage(updatedContent);
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
    );
  }
}

class _DeleteMessageButton extends StatelessWidget {
  const _DeleteMessageButton(this.onDelete);

  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return DsfrButton(
      icon: DsfrIcons.systemDeleteBinLine,
      label: Strings.chatDeleteMessage,
      variant: DsfrButtonVariant.secondary,
      size: DsfrComponentSize.lg,
      foregroundColor: DsfrColorDecisions.textDefaultError(context),
      onPressed: () {
        onDelete();
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
    );
  }
}
