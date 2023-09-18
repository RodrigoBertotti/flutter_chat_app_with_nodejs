
enum SendStatus {
  pending,
  sendSuccessfully,
  sendFailed,
}

class MessageEntity {
  final String messageId;
  final String text;
  final DateTime? sentAt;
  final DateTime createdAt;
  DateTime? receivedAt;
  DateTime? readAt;
  SendStatus sendStatus;
  int senderUserId;
  int receiverUserId;

  // TIMESTAMPS DAS MENSAGENS ESTÃO MUDANDO PARECE, AGUARDE UM MINUTO E VEJA

  MessageEntity({
    required this.messageId,
    required this.text,
    required this.senderUserId,
    required this.receiverUserId,
    required this.createdAt,
    this.sentAt,
    this.receivedAt,
    this.readAt,
    required this.sendStatus,
  }) {
    assert(text.isNotEmpty == true);
  }

  MessageEntity copyWith({SendStatus? sendStatus}) {
    return MessageEntity(messageId: messageId, text: text, senderUserId: senderUserId, receiverUserId: receiverUserId, createdAt: createdAt, sendStatus: sendStatus ?? this.sendStatus);
  }


}
