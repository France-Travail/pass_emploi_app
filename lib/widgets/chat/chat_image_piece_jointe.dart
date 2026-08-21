import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dsfr/flutter_dsfr.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pass_emploi_app/features/chat/piece_jointe/piece_jointe_actions.dart';
import 'package:pass_emploi_app/presentation/chat/chat_item.dart';
import 'package:pass_emploi_app/presentation/chat/piece_jointe_view_model.dart';
import 'package:pass_emploi_app/presentation/display_state.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:pass_emploi_app/widgets/chat/chat_message_container.dart';
import 'package:pass_emploi_app/widgets/chat/chat_piece_jointe.dart';

class ChatImagePieceJointe extends StatelessWidget {
  const ChatImagePieceJointe(this.item);
  final PieceJointeImageItem item;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, PieceJointeViewModel>(
      onInit: (store) {
        store.dispatch(PieceJointeFromIdRequestAction(item.pieceJointeId, item.pieceJointeName, isImage: true));
      },
      converter: (store) => PieceJointeViewModel.create(store, PieceJointeImagePreviewSource()),
      builder: (context, viewModel) => _Body(item: item, viewModel: viewModel),
      distinct: true,
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.item, required this.viewModel});
  final PieceJointeImageItem item;
  final PieceJointeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ChatMessageContainer(
      content: switch (viewModel.displayState.call(item.pieceJointeId)) {
        DisplayState.CONTENT => _Content(viewModel.imagePath?.call(item.pieceJointeId)),
        DisplayState.LOADING => _Loading(),
        DisplayState.FAILURE => _Failure(),
        DisplayState.EMPTY => _Failure(),
      },
      isPj: true,
      isMyMessage: true,
      caption: item.caption,
      captionColor: item.captionColor,
    );
  }
}

class _Content extends StatelessWidget {
  const _Content(this.imagePath);
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    if (imagePath == null) return _Failure();
    return ClipRRect(
      borderRadius: BorderRadius.circular(DsfrSpacings.s1v),
      child: Image.file(File(imagePath!)),
    );
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DsfrColorDecisions.backgroundContrastGrey(context),
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s2w),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              DsfrIcons.mediaImageLine,
              color: DsfrColorDecisions.textMentionGrey(context),
              size: DsfrSpacings.s4w,
            ),
            CircularProgressIndicator(
              color: DsfrColorDecisions.backgroundActionHighBlueFrance(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DsfrColorDecisions.backgroundContrastGrey(context),
        borderRadius: BorderRadius.circular(DsfrSpacings.s1v),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsfrSpacings.s1w),
        child: FileWasDeleted(),
      ),
    );
  }
}
