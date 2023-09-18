import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/sending_text_message_entity.dart';

class SendingMessageModel extends SendingMessageEntity {
  /// Field names:
  static const String _kMessageId = "messageId";
  static const String _kText = "text";
  static const String _kReceiverUserId = "receiverUserId";

  SendingMessageModel({required String messageId, required String text, required int receiverUserId}) : super(messageId: messageId, receiverUserId: receiverUserId, text: text,);

  SendingMessageModel.fromEntity(SendingMessageEntity entity) : super(messageId: entity.messageId, text: entity.text, receiverUserId: entity.receiverUserId);

  Map<String, dynamic> toMap () => {
    _kMessageId: messageId,
    _kText: text,
    _kReceiverUserId: receiverUserId,
  };

}