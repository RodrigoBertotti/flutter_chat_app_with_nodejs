import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/auth_repo.dart';
import '../../../../injection_container.dart';
import 'delay_animate_switcher.dart';

class MessageStatusWidget extends StatelessWidget {
  final MessageEntity message;
  get checkIcon => Icon(Icons.check, size: 16, color: message.readAt != null ? Colors.blue[300] : Colors.green[50]);

  int get loggedUserId => getIt.get<AuthRepo>().loggedUserId!;
  bool get isLeftSide => message.senderUserId != loggedUserId;

  const MessageStatusWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isLeftSide && message.sendStatus == SendStatus.pending)
          Icon(Icons.access_time_outlined, color: Colors.green[50], size: 17),
        if (!isLeftSide && message.sendStatus == SendStatus.sendFailed)
          Icon(Icons.error_outline_rounded, color: Colors.red[300], size: 17),
        if(!isLeftSide && (message.sentAt != null || message.receivedAt != null || message.readAt != null))
          SizedBox(
            width: message.receivedAt != null || message.readAt != null ? 25 : null,
            child: Stack(
              children: [
                DelayAnimateSwitcher(
                  firstChild: Container(width: 18,),
                  secondChild: checkIcon,
                  animate: message.receivedAt == null ? false : (DateTime.now().millisecondsSinceEpoch - 1000 < message.receivedAt!.millisecondsSinceEpoch),
                ),
                if (message.receivedAt != null || message.readAt != null)
                  Align(
                    alignment: const Alignment(.85,0),
                    child: DelayAnimateSwitcher(
                        firstChild: Container(width: 18,),
                        secondChild: checkIcon,
                        animate: DateTime.now().millisecondsSinceEpoch - 1000 < message.sentAt!.millisecondsSinceEpoch,
                        delay: const Duration(milliseconds: 320)
                    ),
                  )
              ],
            ),
          )
      ],
    );
  }
}
