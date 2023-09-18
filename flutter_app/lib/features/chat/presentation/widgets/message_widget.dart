import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/widgets/message_status_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/auth_repo.dart';
import 'package:flutter_chat_app_with_mysql/injection_container.dart';
import 'package:intl/intl.dart';
import 'balloon_widget.dart';
import 'delay_animate_switcher.dart';

class MessageSideWidget extends StatelessWidget {
  final MessageEntity message;

  int get loggedUserId => getIt.get<AuthRepo>().loggedUserId!;
  bool get isLeftSide => message.senderUserId != loggedUserId;

  const MessageSideWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {

    assert(message.sentAt != null || message.sendStatus != SendStatus.sendSuccessfully, 'SendStatus.sendSuccessfully can only be true if sentAt is not null');


    return BalloonWidget(
      isLeftSide: isLeftSide,
      centerChildConstraints: (currentConstraints) => BoxConstraints(
        minWidth: 0,
        maxWidth: currentConstraints.maxWidth * .43,
      ),
      centerChild: LayoutBuilder(
        builder: (context, constraints) {
          return IntrinsicWidth(
            child: Column (
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(message.text.isNotEmpty == true)
                      ...[
                        Flexible(
                          child: Text(message.text, style: TextStyle(fontSize: 15, color: !isLeftSide ? Colors.white : Colors.indigo)),
                        ),
                        SizedBox(
                          width: 28,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: MessageStatusWidget(message: message)
                            ),
                          ),
                        ),
                      ]
                  ],
                ),
                if (message.sentAt != null)
                  ...[
                    const SizedBox(height: 2,),
                    Row(
                      children: [
                        if (message.sendStatus == SendStatus.sendFailed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline_rounded, color: Colors.redAccent[300], size: 17),
                                const SizedBox(width: 3,),
                                Text('Failed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red[300]),),
                                const SizedBox(width: 7,),
                              ],
                            ),
                          ),
                        Expanded(child: Container()),
                        Text(DateFormat('HH:mm').format(message.sentAt!), style: TextStyle(color: isLeftSide ? Colors.grey[500] : Colors.green[50], fontSize: 10, fontWeight: FontWeight.w500),),
                      ],
                    ),
                  ],
                if (message.sentAt == null)
                  const SizedBox(height: 2,)
              ],
            ),
          );
        },
      ),
    );
  }
}

