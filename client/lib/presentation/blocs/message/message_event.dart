import 'package:equatable/equatable.dart';
import 'package:sigmail_client/data/models/message/create_message_model.dart';
import 'package:sigmail_client/data/models/message/message_model.dart';
import 'package:cross_file/cross_file.dart';
import 'package:sigmail_client/domain/enums/attachment_type.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends MessageEvent {
  final String chatId;
  final int pageNumber;
  final int pageSize;

  const LoadMessages(this.chatId, {this.pageNumber = 1, this.pageSize = 50});

  @override
  List<Object?> get props => [chatId, pageNumber, pageSize];
}

// Событие для добавления нового сообщения, полученного через Stream (SignalR)
class InternalMessageReceived extends MessageEvent {
  final MessageModel message;

  const InternalMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

// Событие для отправки нового сообщения
class SendNewMessage extends MessageEvent {
  final CreateMessageModel createMessageModel;

  const SendNewMessage(this.createMessageModel);

  @override
  List<Object> get props => [createMessageModel];
}

// Новое событие для отправки файла
class SendAttachmentEvent extends MessageEvent {
  final XFile file;
  final String chatId;
  final AttachmentType attachmentType;
  final String? messageText;

  const SendAttachmentEvent({
    required this.file,
    required this.chatId,
    required this.attachmentType,
    this.messageText, 
  });

  @override
  List<Object?> get props => [file, chatId, attachmentType, messageText];
} 