import 'dart:async';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/entities/failures/failure.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/auth_repo.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/chat_content_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/sending_text_message_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/sending_typing_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/users_repo.dart';
import '../../../../core/data/data_sources/auth_local_ds.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/messages_repo.dart';
import '../data_sources/messages_local_ds.dart';
import '../data_sources/messages_remote_ds.dart';

const int _kTypingDurationMs = 800;

class MessagesRepoImpl extends MessagesRepo {
  final List<String> _messagesIdsWhereStatusIsPending = [];
  final MessagesRemoteDS messagesRemoteDataSource;
  final MessagesLocalDS messagesLocalDataSource;
  final UsersRepo usersRepository;
  final AuthRepo authRepo;

  MessagesRepoImpl({required this.messagesRemoteDataSource, required this.authRepo, required this.usersRepository, required this.messagesLocalDataSource }) {
    authRepo.addOnLogoutListener(() {
      _messagesIdsWhereStatusIsPending.clear();
      _listeningToIndividualConversationsByUserId.clear();
      conversationsUsersIds.clear();
      conversationsSenderUserId.clear();
      _waitBuildStreamsToComplete.clear();
      conversationsUsersIdsSubscription?.cancel();
      conversationsUsersIdsSubscription = null;
      _buildStreamsIsRunning = false;
    });
  }

  @override
  Stream<ChatContentEntity> messagesStream({required int userId}) {
    return _itemStream<ChatContentEntity>(userId: userId, latestEvent: () async {
      final messages = messagesLocalDataSource.getMessages(userId: userId);
      return ChatContentEntity(
        messages: messages,
        isTyping: isTyping(userId),
      );
    });
  }

  Future<void> checkIfNeedsToMakeRequestToApiTellingMessageWasRead () async {
    print ("checkIfNeedsToMakeRequestToApiTellingMessageWasRead");

    bool tryItAgain = false;
    for (final pendingRequestToApiTellingMessageWasRead in (await messagesLocalDataSource.getPendingRequestListToApiTellingMessagesWereRead())) {
      try {
        await messagesRemoteDataSource.notifyLoggedUserReadConversation(
            senderUserId: pendingRequestToApiTellingMessageWasRead.senderUserId,
            lastMessageReadHasBeenReceivedAt: pendingRequestToApiTellingMessageWasRead.dateTime.add(const Duration(milliseconds: 1000))
        );
        await messagesLocalDataSource.removePendingRequestToApiTellingMessageWasRead(senderUserId: pendingRequestToApiTellingMessageWasRead.senderUserId);
      } catch (e) {
        log('checkIfNeedsToMakeRequestToApiTellingMessageWasRead error: $e');
        if (e is Failure) {
          tryItAgain = true;
        } else {
          rethrow;
        }
      }
    }

    if (tryItAgain) {
      log('it will try again in a few seconds');
      Future.delayed(const Duration(seconds: 5), () => checkIfNeedsToMakeRequestToApiTellingMessageWasRead());
    }
  }

  StreamController<List<ConversationEntity>>? _allConversationsStreamController;
  StreamSubscription<List<int>>? conversationsUsersIdsSubscription;
  final Map<int,StreamSubscription<ConversationEntity>> _listeningToIndividualConversationsByUserId = {};
  List<int> conversationsUsersIds = [];
  final conversationsSenderUserId = <int, ConversationEntity>{};
  final List<Completer> _waitBuildStreamsToComplete = [];
  bool _buildStreamsIsRunning = false;

  Future<void> _buildStreams(List<int> partialUserIdList) async {
    if (!_started) {
      throw "_buildStreams: Please, call start() first";
    }
    if (_buildStreamsIsRunning) {
      final completer = Completer<void>();
      _waitBuildStreamsToComplete.add(completer);
      await completer.future;
    }

    conversationsUsersIds = (conversationsUsersIds..addAll(partialUserIdList)).toSet().toList().where((userId) => userId != getIt.get<AuthRepo>().loggedUserId).toList();

    try {
      if (conversationsUsersIds.isEmpty) {
        return _allConversationsStreamController!.add(conversationsSenderUserId.values.toList());
      }
      _buildStreamsIsRunning = true;

      for(final int userId in conversationsUsersIds){
        log ("-> userId: $userId");
        assert(userId != getIt.get<AuthRepo>().loggedUserId);
        final user = await usersRepository.readUser(userId);
        user.fold((failure) {
          log("Get conversation item failed: An error occurred when trying to get the user $userId, so we will ignore his conversation for now. $failure");
        }, (user) {
          _listeningToIndividualConversationsByUserId[userId] ??= _itemStream<ConversationEntity>(userId: userId, latestEvent: () async {
            final lastMessage = messagesLocalDataSource.getLastMessage(userId);
            // assert(lastMessage != null, 'lastMessage is null to ${userId}');
            return conversationsSenderUserId[userId] = ConversationEntity (
              lastMessage: _messagesIdsWhereStatusIsPending.contains(lastMessage?.messageId)
                  ? lastMessage!.copyWith(sendStatus: SendStatus.pending)
                  : lastMessage,
              isTyping: isTyping(userId),
              unreadMessagesAmount: messagesLocalDataSource.getUnreadMessagesAmount(userId: userId),
              user: user,
            );
          }).listen((event) {
            _allConversationsStreamController!.add(conversationsSenderUserId.values.toList());
          }, onError: (err) {
            log ("Ops! An error occurred when trying to listen to the user $userId");
            print(err);
          });

          _allConversationsStreamController!.add(conversationsSenderUserId.values.toList());
        });
      }
    } catch (e) {
      print(e);
    }

    _buildStreamsIsRunning = false;
    for (final completer in _waitBuildStreamsToComplete) { completer.complete(); }
    _waitBuildStreamsToComplete.clear();
  }

  @override
  Future<void> start() async {
    if (_started) {
      log("started already called");
      return;
    }
    log("STARTED messages called");
    _forceRefreshChatStream?.close();
    _forceRefreshChatStream = StreamController<RefreshChatStreamEvent>.broadcast();

    _allConversationsStreamController = StreamController<List<ConversationEntity>>.broadcast();
    _allConversationsStreamController!.onCancel = () {
      log("onCancel called for listening for conversations");
      for (final conversation in _listeningToIndividualConversationsByUserId.values) {
        try {
          conversation.cancel();
        }catch (e) {
          log("_listeningToIndividualChatsByUserId conversation cancel error: $e");
        }
      }
      _listeningToIndividualConversationsByUserId.clear();//

      conversationsUsersIdsSubscription?.cancel();
      conversationsUsersIdsSubscription = null;
      _forceRefreshChatStream?.close();
      _forceRefreshChatStream = null;
    };
    conversationsUsersIdsSubscription?.cancel();
    conversationsUsersIdsSubscription = messagesRemoteDataSource.streamConversationsWithUnreceivedMessages().listen(
        _buildStreams,
        onError: (err) {log("listeningToConversations error: $err"); try { print(err.stack); }catch(e){} },
        onDone: () { log("listeningToConversations onDone"); if(_allConversationsStreamController != null && _allConversationsStreamController!.isClosed == false) _allConversationsStreamController!.close(); }
    );

    checkIfNeedsToMakeRequestToApiTellingMessageWasRead();
  }

  bool get _started => _allConversationsStreamController != null;

  @override
  Future<void> close () {
    log("CLOSE called!!");
    _allConversationsStreamController?.close();
    _allConversationsStreamController = null;
    return messagesLocalDataSource.clear();
  }

  @override
  Stream<List<ConversationEntity>> conversationsStream() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!_started) {
        throw "Please, call start() first";
      }
      _buildStreams(messagesLocalDataSource.getConversationsUsersIds());
    });

    return _allConversationsStreamController!.stream;
  }

  StreamController<RefreshChatStreamEvent>? _forceRefreshChatStream;


  /// Updates the local datasource and returns a stream combining all streams each chat should listen to, like
  /// whether the other user is typing or not,
  /// if some message received an update (in case the message been received or read),
  /// the text messages themselves,
  /// and also, a listener that will be triggered each time the logged user sends a new message
  Stream<T> _itemStream<T>({
    required int userId,
    required Future<T> Function() latestEvent
  }) {
    if (!_started){
      throw "please, call start()";
    }
    final StreamController<T> ctrl = StreamController();

    void refresh () {
      latestEvent().then((value) {
        log("REFRESHING CHAT / CONVERSATION CONTENT WITH $value");

        if (value is ChatContentEntity){
          final messages = value.messages.map((e) {
            if (_messagesIdsWhereStatusIsPending.contains(e.messageId)) {
              return e.copyWith(sendStatus: SendStatus.pending);
            }
            return e;
          }).toList();
          ctrl.add(ChatContentEntity(
              messages: messages,
              isTyping: value.isTyping
          ) as T);
        } else if (value is ConversationEntity) {
          ctrl.add(ConversationEntity(
              isTyping: value.isTyping,
              user: value.user,
              unreadMessagesAmount: value.unreadMessagesAmount,
              lastMessage: _messagesIdsWhereStatusIsPending.contains(value.lastMessage?.messageId)
                  ? value.lastMessage!.copyWith(sendStatus: SendStatus.pending)
                  : value.lastMessage
          ) as T);
        } else {
          throw "Unknown type for event value (_itemStream)";
        }
      });
    }

    print ("listenToTypingSubscription CALLED");
    final listenToTypingSubscription = messagesRemoteDataSource
        .typingStream(typingUserId: userId)
        .listen((event) {
          print(">>> TYPING!!! typingUserId is $userId");
      _updateTyping(
          typingUserId: userId,
          refreshTyping: refresh,
          onNotTypingCallback: () {
            if(!ctrl.isClosed) {
              refresh();
            }
          }
      );
    }, onDone: () => log('listenToTyping done'), onError: (e) { log('listenToTyping error: $e'); print(e); });

    log("messagesStreamSubscription");
    final messagesStreamSubscription = messagesRemoteDataSource
        .messagesStream(userId: userId)
        .listen((event) async  {
      if (_typing[userId] != null){
        for (final callback in _typing[userId]!.onNotTypingCallbackList) {
          callback();
        }
        _typing.remove(userId);
      }
      await messagesLocalDataSource.putMessageList(messageList: event);
      refresh();
    }, onDone: () => log('messagesStream done'), onError: (e) {log('messagesStream error: $e'); print(e); });

    final refreshChatStreamSubscription = _forceRefreshChatStream!
        .stream.where((event) => event.userId == userId)
        .listen((_) => refresh(), onDone: () => log('refreshChatStream done'), onError: (e) => log('refreshChatStream error: $e'));

    final messageWereUpdatedSubscription = messagesRemoteDataSource
        .messagesWereUpdated(userId: userId)
        .listen((event) async  {
        for (int i=0;i<event.length;i++) {
          log ('message ${event[i].text} has been updated -> sentAt: ${event[i].sentAt?.toString()} receivedAt: ${event[i].receivedAt?.toString()} readAt: ${event[i].readAt?.toString()}');
          assert(event[i].sentAt != null);
          event[i].sendStatus = SendStatus.sendSuccessfully;
          _messagesIdsWhereStatusIsPending.remove(event[i].messageId);
        }
        await messagesLocalDataSource.putMessageList(messageList: event);
        refresh();
      },
      onDone: () => log('messageWereUpdatedSubscription done'),
      onError: (e) {
        log('messageWereUpdatedSubscription error: $e');
        print(e);
      }
    );

    ctrl.onCancel = (() {
      log("ctrl.onCancel");
      try { listenToTypingSubscription.cancel(); } catch (e) { log("listenToTypingSubscription error: $e"); }
      try { messagesStreamSubscription.cancel(); } catch (e) { log("messagesStreamSubscription error: $e"); }
      try { refreshChatStreamSubscription.cancel(); } catch (e) { log("refreshChatStreamSubscription error: $e"); }
      try { messageWereUpdatedSubscription.cancel(); } catch (e) { log("messageWereUpdatedSubscription error: $e"); }
    });

    refresh(); // sending the first result instantaneously

    return ctrl.stream;
  }

  @override
  Future<Either<Failure, void>> notifyLoggedUserIsTyping({required SendingTypingEntity data}) async {
    try {
      await messagesRemoteDataSource.notifyLoggedUserIsTyping(data: data);
      return right(null);
    } catch (e) {
      if(e is Failure){
        return left(e);
      }
      rethrow;
    }
  }

  @override
  Future<Either<Failure, void>> notifyLoggedUserReadConversation({required int userId}) async {
    try {
      print("notifyLoggedUserReadConversation");
      final readAt = DateTime.now();
      await messagesLocalDataSource.putPendingRequestToApiTellingMessageWasRead(senderUserId: userId, dateTime: readAt);
      final messages = messagesLocalDataSource.getMessages(userId: userId).where((element) => element.senderUserId == userId && element.readAt == null).toList();
      for (MessageEntity message in messages) {
        message.readAt = readAt;
      }
      await messagesLocalDataSource.putMessageList(messageList: messages);
      assert (!messagesLocalDataSource.getMessages(userId: userId).any((element) => element.readAt == null && element.senderUserId == userId));
      _forceRefreshChatStream!.add(RefreshChatStreamEvent(userId: userId));

      checkIfNeedsToMakeRequestToApiTellingMessageWasRead();

      return right(null);
    } catch (e) {
      if(e is Failure){
        return left(e);
      }
      rethrow;
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({required SendingMessageEntity message}) async {
    final localMessage = MessageEntity(
        createdAt: DateTime.now(),
        messageId: message.messageId,
        text: message.text,
        senderUserId: authRepo.loggedUserId!,
        receiverUserId: message.receiverUserId,
        sendStatus: SendStatus.sendFailed
    );

    void refreshChat () => _forceRefreshChatStream!.add(RefreshChatStreamEvent(userId: message.receiverUserId));

    try {
      assert(localMessage.messageId.isNotEmpty);

      await messagesLocalDataSource.putMessageList(messageList: [ localMessage ]);
      _messagesIdsWhereStatusIsPending.add(localMessage.messageId);
      refreshChat();

      final messageResponseFromServer = await messagesRemoteDataSource.sendMessage(message: message,);

      assert(messageResponseFromServer.sentAt != null);
      assert(messageResponseFromServer.messageId == localMessage.messageId);

      messageResponseFromServer.sendStatus = SendStatus.sendSuccessfully;

      await messagesLocalDataSource.putMessageList(messageList: [ messageResponseFromServer ]);
      _messagesIdsWhereStatusIsPending.remove(localMessage.messageId);
      refreshChat();
      return right(null);
    } catch (e) {
      if(e is Failure){
        localMessage.sendStatus = SendStatus.sendFailed;
        await messagesLocalDataSource.putMessageList(messageList: [ localMessage ]);
        _messagesIdsWhereStatusIsPending.remove(localMessage.messageId);
        refreshChat();
        return left(e);
      }
      rethrow;
    }
  }

  final Map<int, _TypingValue> _typing = {};
  bool isTyping(int userId2) {
    final res = (_typing[userId2]?.turnToNotTypingAt?.millisecondsSinceEpoch ?? 0) > DateTime.now().millisecondsSinceEpoch;
    log ("isTyping: $res");
    return res;
  }

  void _updateTyping({required int typingUserId, required void Function() onNotTypingCallback, required void Function() refreshTyping}) {
    if(_typing[typingUserId] == null){
      _typing[typingUserId] = _TypingValue();
    }
    _typing[typingUserId]!.turnToNotTypingAt = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + _kTypingDurationMs);
    _typing[typingUserId]!.onNotTypingCallbackList.add(onNotTypingCallback);
    final List<void Function ()> checkIfUserIsNotTypingAnymore = [(){}];
    checkIfUserIsNotTypingAnymore[0] = () {
      if(_typing[typingUserId] != null && (_typing[typingUserId]!.turnToNotTypingAt?.millisecondsSinceEpoch ?? 0) <= DateTime.now().millisecondsSinceEpoch) {
        log("TYPING: not anymore!");
        for (void Function () callback in _typing[typingUserId]!.onNotTypingCallbackList) {
          callback();
        }
        _typing.remove(typingUserId);
        refreshTyping();
      }
    };
    refreshTyping();
    _typing[typingUserId]?.lastFuture = Timer(const Duration(milliseconds: _kTypingDurationMs + 5), checkIfUserIsNotTypingAnymore[0]);
  }
}

class RefreshChatStreamEvent {
  final int userId;

  RefreshChatStreamEvent({required this.userId});
}
class _TypingValue {
  DateTime? turnToNotTypingAt;
  List<void Function ()> onNotTypingCallbackList = [];
  Timer? lastFuture;
  _TypingValue();
}
