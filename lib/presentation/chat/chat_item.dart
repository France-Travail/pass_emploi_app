import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:pass_emploi_app/models/chat/message.dart';
import 'package:pass_emploi_app/models/chat/sender.dart';

sealed class ChatItem extends Equatable {
  final String messageId;
  final bool shouldAnimate;

  ChatItem(this.messageId, {this.shouldAnimate = false});

  @override
  List<Object?> get props => [messageId, shouldAnimate];
}

class DayItem extends ChatItem {
  final String dayLabel;

  DayItem(this.dayLabel) : super('');

  @override
  List<Object?> get props => [messageId, dayLabel];
}

class InformationItem extends ChatItem {
  final String title;
  final String description;

  InformationItem(this.title, this.description) : super('');

  @override
  List<Object?> get props => [messageId, title, description];
}

class DeletedMessageItem extends ChatItem {
  DeletedMessageItem(super.messageId, this.sender, this.content);

  final Sender sender;
  final String content;

  @override
  List<Object?> get props => [messageId];
}

sealed class MessageItem extends ChatItem {
  final String content;
  final String caption;
  final bool isCaptionError;

  MessageItem(super.messageId, bool shouldAnimate, this.content, this.caption, this.isCaptionError)
      : super(shouldAnimate: shouldAnimate);

  @override
  List<Object?> get props => [
        messageId,
        content,
        caption,
        isCaptionError,
        shouldAnimate,
      ];
}

class TextMessageItem extends MessageItem {
  final Sender sender;

  TextMessageItem({
    required String messageId,
    required String content,
    required String caption,
    required this.sender,
    bool isCaptionError = false,
    bool shouldAnimate = false,
  }) : super(messageId, shouldAnimate, content, caption, isCaptionError);

  @override
  List<Object?> get props => [messageId, content, caption, isCaptionError, shouldAnimate, sender];
}

abstract class PartageMessageItem extends MessageItem {
  final String idPartage;
  final String titrePartage;
  final Sender sender;

  PartageMessageItem(
    super.messageId,
    super.content,
    super.caption,
    super.isCaptionError,
    super.shouldAnimate,
    this.idPartage,
    this.titrePartage,
    this.sender,
  );

  @override
  List<Object?> get props =>
      [messageId, content, caption, isCaptionError, shouldAnimate, idPartage, titrePartage, sender];
}

class OffreMessageItem extends PartageMessageItem {
  final OffreType type;

  OffreMessageItem({
    required String messageId,
    required String content,
    required String caption,
    required Sender sender,
    required String idPartage,
    required String titrePartage,
    required this.type,
    bool isCaptionError = false,
    bool shouldAnimate = false,
  }) : super(messageId, shouldAnimate, content, caption, isCaptionError, idPartage, titrePartage, sender);

  @override
  List<Object?> get props =>
      [messageId, content, caption, isCaptionError, shouldAnimate, sender, idPartage, titrePartage, type];
}

class EventMessageItem extends PartageMessageItem {
  EventMessageItem({
    required String messageId,
    required String content,
    required String caption,
    required Sender sender,
    required String idPartage,
    required String titrePartage,
    bool isCaptionError = false,
    bool shouldAnimate = false,
  }) : super(messageId, shouldAnimate, content, caption, isCaptionError, idPartage, titrePartage, sender);

  @override
  List<Object?> get props =>
      [messageId, content, caption, isCaptionError, shouldAnimate, sender, idPartage, titrePartage];
}

class EvenementEmploiMessageItem extends PartageMessageItem {
  EvenementEmploiMessageItem({
    required String messageId,
    required String content,
    required String caption,
    required Sender sender,
    required String idPartage,
    required String titrePartage,
    bool isCaptionError = false,
    bool shouldAnimate = false,
  }) : super(messageId, shouldAnimate, content, caption, isCaptionError, idPartage, titrePartage, sender);

  @override
  List<Object?> get props =>
      [messageId, content, caption, isCaptionError, shouldAnimate, sender, idPartage, titrePartage];
}

class SessionMiloMessageItem extends PartageMessageItem {
  SessionMiloMessageItem({
    required String messageId,
    required String content,
    required String caption,
    required Sender sender,
    required String idPartage,
    required String titrePartage,
    bool isCaptionError = false,
    bool shouldAnimate = false,
  }) : super(messageId, shouldAnimate, content, caption, isCaptionError, idPartage, titrePartage, sender);

  @override
  List<Object?> get props =>
      [messageId, content, caption, isCaptionError, shouldAnimate, sender, idPartage, titrePartage];
}

sealed class PieceJointeItem extends ChatItem {
  final String caption;
  final bool isCaptionError;

  PieceJointeItem({
    required String messageId,
    bool shouldAnimate = false,
    required this.caption,
    this.isCaptionError = false,
  }) : super(messageId, shouldAnimate: shouldAnimate);
}

class PieceJointeMessageItem extends PieceJointeItem {
  final Sender sender;
  final String pieceJointeId;
  final String? message;
  final String filename;

  PieceJointeMessageItem({
    required super.messageId,
    super.shouldAnimate,
    required this.sender,
    required this.pieceJointeId,
    required this.message,
    required this.filename,
    required super.caption,
    super.isCaptionError,
  });

  @override
  List<Object?> get props => [
        sender,
        messageId,
        pieceJointeId,
        message,
        filename,
        shouldAnimate,
        caption,
        isCaptionError,
      ];
}

class PieceJointeImageItem extends PieceJointeItem {
  final String pieceJointeId;
  final String pieceJointeName;

  PieceJointeImageItem({
    required super.messageId,
    super.shouldAnimate = false,
    required this.pieceJointeId,
    required this.pieceJointeName,
    required super.caption,
    super.isCaptionError,
  });

  @override
  List<Object?> get props => [
        messageId,
        pieceJointeId,
        pieceJointeName,
        shouldAnimate,
        caption,
        isCaptionError,
      ];
}

class LocalImageMessageItem extends ChatItem {
  final String imagePath;
  final String caption;
  final bool showLoading;
  final bool isCaptionError;
  final IconData? captionSuffixIcon;

  LocalImageMessageItem({
    required String messageId,
    required this.imagePath,
    required this.caption,
    required this.showLoading,
    this.isCaptionError = false,
    this.captionSuffixIcon,
    bool shouldAnimate = false,
  }) : super(messageId, shouldAnimate: shouldAnimate);

  @override
  List<Object?> get props => [messageId, caption, showLoading, isCaptionError, shouldAnimate];
}

class LocalFileMessageItem extends ChatItem {
  final String caption;
  final String fileName;
  final bool showLoading;
  final bool isCaptionError;
  final IconData? captionSuffixIcon;

  LocalFileMessageItem({
    required String messageId,
    required this.caption,
    required this.fileName,
    required this.showLoading,
    this.isCaptionError = false,
    this.captionSuffixIcon,
    bool shouldAnimate = false,
  }) : super(messageId, shouldAnimate: shouldAnimate);

  @override
  List<Object?> get props => [messageId, caption, fileName, showLoading, isCaptionError, shouldAnimate];
}

class ActionMessageItem extends PartageMessageItem {
  ActionMessageItem({
    required String messageId,
    required String content,
    required String caption,
    required Sender sender,
    required String idPartage,
    required String titrePartage,
    bool isCaptionError = false,
    bool shouldAnimate = false,
  }) : super(messageId, shouldAnimate, content, caption, isCaptionError, idPartage, titrePartage, sender);

  @override
  List<Object?> get props =>
      [messageId, content, caption, isCaptionError, shouldAnimate, sender, idPartage, titrePartage];
}
