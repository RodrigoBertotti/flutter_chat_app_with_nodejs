import 'dart:developer';
import 'package:askless/domain/services/authenticate_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/button_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/center_content_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/connection_status_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/expanded_section_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/my_appbar_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/widgets/my_multiline_text_field.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/user_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/repositories/messages_repo.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/use_cases/listen_to_conversations.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/use_cases/stream_users_to_talk.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/controllers/users_to_talk_to_controller.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/screens/realtime_chat_screen/realtime_chat_screen.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/widgets/logout_button_widget.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/widgets/message_status_widget.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/auth_repo.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/use_cases/logout.dart';
import 'package:flutter_chat_app_with_mysql/injection_container.dart';
import 'package:flutter_chat_app_with_mysql/main.dart';
import 'package:flutter_chat_app_with_mysql/screen_routes.dart';
import 'package:intl/intl.dart';



class RealtimeConversationsScreen extends StatefulWidget {
  static const String route = '/conversations';

  const RealtimeConversationsScreen({Key? key}) : super(key: key);

  @override
  State<RealtimeConversationsScreen> createState() => _RealtimeConversationsScreenState();

}

class _RealtimeConversationsScreenState extends State<RealtimeConversationsScreen> {
  final TextEditingController searchController = TextEditingController();
  _RealtimeConversationsScreenState() : super();

  bool startedConversationsIsExpanded = true;
  bool allContactsIsExpanded = true;

  final usersToTalkToController = UsersToTalkToController();

  void _clearText() {
    setState(() {
      searchController.text = '';
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchController.addListener(() {
        setState(() {
          startedConversationsIsExpanded = allContactsIsExpanded = true;
        });
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // final double contentHeight = MediaQuery.of(context).size.height - 82;
    final double contentHeight = MediaQuery.of(context).size.height - 105;


    return Stack(
      children: [
        Scaffold(
            appBar: MyAppBarWidget(
              context: context,
              withBackground: true,
              // child: Text('Conversations', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kPageContentWidth),
                child: Row(
                  children: [
                    Expanded(
                      child:  MyMultilineTextField(
                        hintText: 'Search for conversations',
                        controller: searchController,
                        fillColor: Colors.blue[800],
                        maxLines: 1,
                        suffixIcon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: searchController.text.isEmpty
                              ? Icon(Icons.search_rounded, color: Colors.blue[900]!, size: 27)
                              : InkWell(
                            onTap: _clearText,
                            child: Ink(
                              child: const Icon(Icons.clear_rounded, color: Colors.white, size: 27,),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: LogoutButtonWidget(),
                    ),
                  ],
                ),
              ),
            ),
            body: CenterContentWidget(
                withBackground: true,
                // child: Stack(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(height: contentHeight, width: MediaQuery.of(context).size.width,),
                    SingleChildScrollView(
                      clipBehavior: Clip.none,
                      child: Column(
                        children: [
                          StreamBuilder(
                            stream: getIt.get<ListenToConversationsWithMessages>().call(),
                            builder: (context, conversationsSnapshot) {
                              if(conversationsSnapshot.hasError){
                                log("An error occurred on ListenToConversationsWithMessages: ${conversationsSnapshot.error ?? "null"}");
                                return Container();
                              }
                              if(!conversationsSnapshot.hasData || conversationsSnapshot.data!.isEmpty){
                                return Container();
                              }
                              final conversations = conversationsSnapshot.data!
                                  .where((element) => element.lastMessage?.text.toLowerCase().contains(searchController.text.toLowerCase()) == true
                                  || element.user.fullName.toLowerCase().contains(searchController.text.toLowerCase())
                              );
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Subtitle(title: 'Conversations (${conversations.length.toString()})', isExpanded: startedConversationsIsExpanded, toggleExpand: (expand){setState(() {startedConversationsIsExpanded = expand;});}),
                                  ExpandedSection(
                                    expand: startedConversationsIsExpanded,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 7, bottom: 10),
                                      child: Column(
                                        children: [
                                          ...conversations.mapIndexed((index, conversation) => Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8),
                                            child: _ConversationItem(
                                              userId:  conversation.user.userId,
                                              fullName: conversation.user.fullName,
                                              message: conversation.lastMessage,
                                              isTyping: conversation.isTyping,
                                              unreadMessagesAmount: conversation.unreadMessagesAmount,
                                            ),
                                          )).toList(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          StreamBuilder(
                            stream: usersToTalkToController.stream(),
                            builder: (context, snapshotContacts) {
                              if(snapshotContacts.hasError){
                                log("An error occurred on FutureBuilder ReadAllContacts: ${snapshotContacts.error ?? "null"} ${snapshotContacts.data ?? "null"}");
                                return SizedBox(
                                  height: contentHeight,
                                  child: const Center(child: Text("An error occurred. Please try again later", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),),
                                );
                              }
                              if(!snapshotContacts.hasData){
                                return SizedBox(
                                  height: contentHeight,
                                  child: Center(child: CircularProgressIndicator(color: Colors.blue[100],),),
                                );
                              }
                              final contacts = snapshotContacts.data!
                                  .where((element) => ("${element.firstName} ${element.lastName}").toLowerCase().contains(searchController.text.toLowerCase()))
                                  .where((element) => element.userId != getIt.get<AuthenticateService>().userId);

                              if(contacts.isEmpty){
                                return SizedBox(
                                    height: contentHeight,
                                    child: Column(
                                      mainAxisAlignment: searchController.text.isEmpty
                                          ? MainAxisAlignment.center
                                          : MainAxisAlignment.start,
                                      children: [
                                        const Text("No user to talk to", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18), textAlign: TextAlign.center,),
                                        const SizedBox(height: 10,),
                                        Text(searchController.text.isEmpty
                                            ? "Create another account and start playing :)"
                                            : "No user matches the filter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15), textAlign: TextAlign.center,),
                                        const SizedBox(height: 22,),
                                        ButtonWidget(text: 'LOGOUT', isSmall: true, onPressed: () {
                                          getIt.get<Logout>().call().then((_) {
                                            Navigator.of(context).pushNamedAndRemoveUntil(ScreenRoutes.login, (route) => false);
                                          });
                                        },)
                                      ],
                                    )
                                );
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Subtitle(title: 'Contacts (${contacts.length.toString()})', isExpanded: allContactsIsExpanded, toggleExpand: (expand){setState(() {allContactsIsExpanded = expand;});}),
                                  ExpandedSection(
                                    expand: allContactsIsExpanded,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 8,),
                                        ...contacts.map((user) => Padding(padding: const EdgeInsets.symmetric(vertical: 8,), child:  _ConversationItem(userId: user.userId, fullName: user.fullName,),)).toList(),
                                        const SizedBox(height: 18,),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                )
            )
        ),
        const Positioned(
          bottom: 10,
          right: 16,
          child: Material(
            type: MaterialType.transparency,
            child: ConnectionStatusWidget(),
          ),
        ),
      ],
    );
  }
}


class _ConversationItem extends StatelessWidget {
  final int unreadMessagesAmount;
  final String fullName;
  final int userId;
  final bool isTyping;
  final MessageEntity? message;
  int get loggedUserId => getIt.get<AuthRepo>().loggedUserId!;
  bool get isLeftSide => message?.senderUserId != loggedUserId;

  const _ConversationItem({required this.fullName, this.message, required this.userId, this.isTyping = false, this.unreadMessagesAmount = 0, Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(ScreenRoutes.chat, arguments: RealtimeChatScreenArgs(userId: userId, fullName: fullName));
      },
      child: Ink(
        child: Container(
          decoration: BoxDecoration(color: Colors.blue[100]!.withOpacity(.15), borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.only(top: 12, right: 18, left: 18, bottom: 6),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.blue,
                        border: Border.all(color: Colors.white, width: 1)
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(fullName, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: unreadMessagesAmount == 0 ? FontWeight.w600 : FontWeight.w700, fontSize: 18, color: Colors.white)),
                            if(message?.sentAt != null)
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(DateFormat('HH:mm').format(message!.sentAt!), style: TextStyle(color: unreadMessagesAmount == 0 ? Colors.grey[100] : Colors.white, fontSize: 12, fontWeight: unreadMessagesAmount == 0 ? FontWeight.w500 : FontWeight.w800),),
                                ),
                              )
                          ],
                        ),
                        if(isTyping)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('typing...',style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xff08c239))),
                          ),
                        if(message?.text.isNotEmpty == true && !isTyping)
                          Row(
                            children: [
                              if (message!.senderUserId == loggedUserId)
                                Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: MessageStatusWidget(message: message!)
                                ),
                              Expanded(
                                child: Text(message!.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, color: Colors.white)),
                              ),
                              if(unreadMessagesAmount > 0)
                                Builder(
                                  builder: (context) {
                                    const double kSize = 23;
                                    return Container(
                                      width: kSize,
                                      height: kSize,
                                      margin: const EdgeInsets.only(left: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff08c239),
                                        borderRadius: BorderRadius.circular(kSize / 2),
                                      ),
                                      child: Center(
                                        child: Text((unreadMessagesAmount > 9 ? '+9' : unreadMessagesAmount.toString()), style: const TextStyle(color: Colors.white, fontSize: 0.6*kSize, fontWeight: FontWeight.w800)),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 7,),
            ],
          ),
        ),
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  final String title;
  final ValueChanged<bool> toggleExpand;
  final bool isExpanded;

  const _Subtitle({Key? key, required this.title, required this.toggleExpand, required this.isExpanded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => toggleExpand(!isExpanded),
        child: Ink(
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(isExpanded ? 'HIDE' : 'SHOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                    Icon(isExpanded ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined , color: Colors.white, size: 22,),
                    const SizedBox(width: 7,),
                    Expanded(child: Container(height: 1, color: Colors.blue[100],)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 2),
                child: Text(title, style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              Expanded(child: Container(height: 1, color: Colors.blue[100],)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineSeparator extends StatelessWidget {
  const _LineSeparator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(margin: EdgeInsets.only(left: 62), height: 1, color: Colors.blue[100],),
        const SizedBox(height: 5,),
      ],
    );
  }
}
