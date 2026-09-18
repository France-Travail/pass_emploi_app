import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/models/chat/sender.dart';
import 'package:pass_emploi_app/presentation/chat/piece_jointe_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/ui/strings.dart';
import 'package:pass_emploi_app/widgets/chat/chat_message_container.dart';

sealed class PieceJointeParams {
  final Sender sender;
  final String? content;
  final String caption;
  final Color? captionColor;
  final String filename;
  final String fileId;

  PieceJointeParams({
    required this.sender,
    required this.content,
    required this.caption,
    required this.captionColor,
    required this.filename,
    required this.fileId,
  });
}

class PieceJointeTypeIdParams extends PieceJointeParams {
  PieceJointeTypeIdParams({
    required super.sender,
    super.content,
    required super.caption,
    required super.captionColor,
    required super.filename,
    required super.fileId,
  });
}

class PieceJointeTypeUrlParams extends PieceJointeParams {
  final String url;

  PieceJointeTypeUrlParams({
    required super.sender,
    required super.caption,
    required super.captionColor,
    required super.filename,
    required super.fileId,
    required this.url,
  }) : super(content: null);
}

class ChatPieceJointe extends StatelessWidget {
  final PieceJointeParams params;

  const ChatPieceJointe(this.params);

  @override
  Widget build(BuildContext context) {
    final isMyMessage = params.sender.isJeune;
    final textStyle = chatBubbleTextStyle(context, isMyMessage: isMyMessage);
    return Focus(
      child: ChatMessageContainer(
        content: Column(
          crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (params.content != null) ...[
              SelectableText(params.content!, style: textStyle),
              SizedBox(height: DsfrSpacings.s1w),
            ],
            _PieceJointeName(params.filename, isMyMessage: isMyMessage),
            SizedBox(height: DsfrSpacings.s1w),
            _DownloadButton(params),
          ],
        ),
        isPj: true,
        isMyMessage: isMyMessage,
        caption: params.caption,
        captionColor: params.captionColor,
      ),
    );
  }
}

class _PieceJointeName extends StatelessWidget {
  final String filename;
  final bool isMyMessage;

  const _PieceJointeName(this.filename, {required this.isMyMessage});

  @override
  Widget build(BuildContext context) {
    return Text(
      filename,
      style: DsfrTextStyle.bodySmBold(color: chatBubbleForeground(context, isMyMessage: isMyMessage)),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final PieceJointeParams params;

  const _DownloadButton(this.params);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, PieceJointeViewModel>(
      converter: (store) => PieceJointeViewModel.create(store, PieceJointeDownloadButtonSource(sender: params.sender)),
      builder: (context, viewModel) => _Body(viewModel: viewModel, params: params),
      distinct: true,
    );
  }
}

class _Body extends StatelessWidget {
  final PieceJointeViewModel viewModel;
  final PieceJointeParams params;

  const _Body({required this.viewModel, required this.params});

  @override
  Widget build(BuildContext context) {
    return switch (viewModel.displayState(params.fileId)) {
      DisplayState.LOADING => Center(child: CircularProgressIndicator()),
      DisplayState.EMPTY => FileWasDeleted(),
      _ => _Button(viewModel: viewModel, params: params),
    };
  }
}

class _Button extends StatelessWidget {
  final PieceJointeViewModel viewModel;
  final PieceJointeParams params;

  const _Button({required this.viewModel, required this.params});

  @override
  Widget build(BuildContext context) {
    final success = viewModel.displayState(params.fileId) != DisplayState.FAILURE;
    void download() => switch (params) {
      final PieceJointeTypeIdParams params => viewModel.onDownloadTypeId(params.fileId, params.filename),
      final PieceJointeTypeUrlParams params => viewModel.onDownloadTypeUrl(
        params.url,
        params.fileId,
        params.filename,
      ),
    };
    return Semantics(
      button: true,
      label: success ? "${Strings.open} ${params.filename}" : Strings.retry,
      onTap: download,
      child: ExcludeSemantics(
        child: ChatBubbleActionButton(
          label: success ? Strings.open : Strings.retry,
          icon: DsfrIcons.systemDownloadLine,
          onPressed: download,
        ),
      ),
    );
  }
}

class FileWasDeleted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: DsfrSpacings.s1w),
          child: Icon(
            DsfrIcons.systemFrErrorFill,
            color: DsfrColorDecisions.textDefaultError(context),
          ),
        ),
        Flexible(
          child: Text(
            Strings.fileNotAvailableTitle,
            style: DsfrTextStyle.bodySm(color: DsfrColorDecisions.textDefaultError(context)),
          ),
        ),
      ],
    );
  }
}
