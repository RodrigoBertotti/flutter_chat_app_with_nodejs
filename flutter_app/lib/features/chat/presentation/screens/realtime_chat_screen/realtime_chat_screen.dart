import 'dart:async';
import 'package:flutter_chat_app_with_mysql/core/widgets/center_content_widget.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/controllers/realtime_chat_page_controller.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/controllers/send_message_controller.dart';
import 'package:flutter_chat_app_with_mysql/screen_routes.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/connection_status_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/my_appbar_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/my_multiline_text_field.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/chat_list_item_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/widgets/chat_item_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/auth_repo.dart';
import 'package:flutter_chat_app_with_mysql/injection_container.dart';
import 'package:flutter_chat_app_with_mysql/main.dart';
import 'dart:math' as math;
import '../../../../call/presentation/screens/call_screen.dart';
import '../../widgets/typing_indicator_widget.dart';

class RealtimeChatScreenArgs {
  int userId;
  String fullName;
  RealtimeChatScreenArgs({required this.userId, required this.fullName});
}

class RealtimeChatScreen extends StatefulWidget {
  static const String route = '/chat';

  const RealtimeChatScreen({super.key});

  @override
  State<RealtimeChatScreen> createState() => _RealtimeChatScreenState();
}

class _RealtimeChatScreenState extends State<RealtimeChatScreen> {
  late final SendMessageController sendMessageController;
  final ScrollController scrollController = ScrollController();
  late final RealtimeChatPageController messagesController;
  late final RealtimeChatScreenArgs args;
  late final StreamSubscription<bool> keyboardSubscription;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    if (initialized) {
      print("args already initialized");
      return;
    }
    initialized = true;
    assert(ModalRoute.of(context)!.settings.arguments != null, "Please, inform the arguments. More info on https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments#4-navigate-to-the-widget");
    args = ModalRoute.of(context)!.settings.arguments as RealtimeChatScreenArgs;

    messagesController = RealtimeChatPageController(userId: args.userId);
    sendMessageController = SendMessageController(text: '', receiverUserId: args.userId);

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBarWidget(
          withBackground: true,
          context: context,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 20, color: Colors.blue[100]),
                    SizedBox(width: 5,),
                    Flexible(
                      child: Text(args.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                          )
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RequestCallIcon(userId: args.userId, iconData: Icons.call, videoCall: false, fullName: args.fullName),
                    SizedBox(width: 20,),
                    RequestCallIcon(userId: args.userId, iconData: Icons.video_call_rounded, videoCall: true, fullName: args.fullName),
                  ],
                )
              )
            ],
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Color(0xff4984f2),
                        Color(0xff87b3ff),
                      ]
                  )
              ),
              child: CenterContentWidget(
                withBackground: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // AJUSTAR typing

                        // adcionar falha ao enviar mensagem

                        Expanded(
                          child: StreamBuilder<List<ChatListItemEntity>>(
                              stream: messagesController.streamChatItems(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                goToBottom();

                                return ListView.builder(
                                  clipBehavior: Clip.none,
                                  controller: scrollController,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Padding(
                                      padding: index < snapshot.data!.length - 1
                                          ? EdgeInsets.zero
                                          : const EdgeInsets.only(bottom: 15),
                                      child: ChatItemWidget(
                                        key: ValueKey(index),
                                        chatItem: snapshot.data![index],
                                      ),
                                    );
                                  },
                                );
                              }),
                        ),
                        Align(
                          alignment: const Alignment(0, 1),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: ValueListenableBuilder(
                              valueListenable: sendMessageController.showTextSentIconNotifier,
                              builder: (context, showTextSentIcon, _) => ValueListenableBuilder<bool>(
                                valueListenable: sendMessageController.hasTextToSendNotifier,
                                builder: (context, hasTextToSend, _) {
                                  return MyMultilineTextField(
                                    controller: sendMessageController,
                                    hintText: 'Type your message here...',
                                    onSubmitted: (_) => sendMessageController.sendMessage(),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: _AnimatedSuffixIconForMessage(
                                          sendEnabled: hasTextToSend,
                                          showTextSentIcon: showTextSentIcon,
                                          sendMessage: sendMessageController.sendMessage
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                )
              ),
            ),
            Positioned(
              left: math.max(kMargin, (MediaQuery
                  .of(context)
                  .size
                  .width - kPageContentWidth) / 2) + 10,
              top: 10,
              child: ConnectionStatusWidget(),
            ),
          ],
        )
    );
  }

  int? get loggedUserId => getIt.get<AuthRepo>().loggedUserId;

  bool sentByLoggedUser(ChatListItemEntity data) => (data is MessageChatListItemEntity && data.message.senderUserId == loggedUserId) && data is! TypingIndicatorWidget;

  void goToBottom() {
    for (int i=1;i<=8;i++){
      Future.delayed(Duration(milliseconds: i * 50), (){
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    }
  }
}

class _AnimatedSuffixIconForMessage extends StatelessWidget {
  final void Function() sendMessage;
  final bool sendEnabled;
  final bool showTextSentIcon;

  const _AnimatedSuffixIconForMessage(
      {required this.showTextSentIcon,
      required this.sendEnabled,
      required this.sendMessage,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kIconSize,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: () {
          if (showTextSentIcon) {
            return const Icon(
              // Icons.input_rounded,
              // Icons.mail_rounded,
              // Icons.near_me_rounded,
              Icons.outbond_rounded,
              color: Colors.white,
              size: kIconSize,
            );
            // return const Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.indigo, size: kIconSize,);
          }
          if (!sendEnabled) {
            return const SizedBox();
          }
          return InkWell(
              onTap: sendMessage,
              child: Ink(
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: kIconSize,
                ),
              ));
        }(),
      ),
    );
  }
}

class RequestCallIcon extends StatelessWidget {
  final int userId;
  final bool videoCall;
  final IconData iconData;
  final String fullName;

  const RequestCallIcon({required this.userId, required this.iconData, required this.videoCall, required this.fullName, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(ScreenRoutes.requestCall,
            arguments: CallScreenArgs(
              remoteUserId: userId,
              callDirection: CallDirection.requestingCall,
              videoCall: videoCall,
              remoteUserFullName: fullName,
            )
        );
      },
      child: Ink(
        child: Icon(iconData, size: 20, color: Colors.white),
      ),
    );
  }
}

