import 'package:dartz/dartz.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/entities/failures/failure.dart';
import '../entities/sending_typing_entity.dart';
import '../repositories/messages_repo.dart';


class NotifyLoggedUserIsTyping {
  final MessagesRepo messagesRepository;

  NotifyLoggedUserIsTyping({required this.messagesRepository});

  Future<Either<Failure, void>> call({required int receiverUserId}) {
    return messagesRepository.notifyLoggedUserIsTyping(data: SendingTypingEntity(receiverUserId: receiverUserId));
  }
}