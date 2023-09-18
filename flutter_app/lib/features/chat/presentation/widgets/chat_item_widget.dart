import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/chat_list_item_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/widgets/message_widget.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/widgets/typing_indicator_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/auth_repo.dart';
import 'package:flutter_chat_app_with_mysql/injection_container.dart';
import 'separator_date_for_messages_widget.dart';

class ChatItemWidget  extends StatelessWidget {
  final ChatListItemEntity chatItem;

  const ChatItemWidget ({required this.chatItem, Key? key}) : super(key: key);

  int get loggedUserId => getIt.get<AuthRepo>().loggedUserId!;

  @override
  Widget build(BuildContext context) {
    if (chatItem is SeparatorDateForMessages) {
      return SeparatorDateForMessagesWidget(
        dateTime: (chatItem as SeparatorDateForMessages).date,
      );
    }
    if (chatItem is MessageChatListItemEntity) {
      return MessageSideWidget(message: (chatItem as MessageChatListItemEntity).message, key: ValueKey((chatItem as MessageChatListItemEntity).message.messageId),);
    }
    if (chatItem is TypingIndicatorChatListItemEntity) {
      return const TypingIndicatorWidget(margin: EdgeInsets.only(top: 7),);
    }
    throw "TODO: ${chatItem.toString()}";
  }
}
