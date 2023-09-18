import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/use_cases/notify_logged_user_is_typing.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/use_cases/send_message.dart';
import 'package:flutter_chat_app_with_mysql/injection_container.dart';

class SendMessageController extends TextEditingController {
  final hasTextToSendNotifier = ValueNotifier<bool>(false);
  final showTextSentIconNotifier = ValueNotifier<bool>(false);
  final int receiverUserId;
  String _previousText = "";

  SendMessageController({String? text, required this.receiverUserId}) : super(text: text) {
    addListener(() {
      if (_previousText != this.text && this.text.isNotEmpty) {
        getIt<NotifyLoggedUserIsTyping>().call(receiverUserId: receiverUserId);
      }
      hasTextToSendNotifier.value = this.text.isNotEmpty;
      _previousText = this.text;
    });
  }

  void sendMessage() {
    if (text.isEmpty) {
      log('No text to send');
      return;
    }

    getIt.get<SendMessage>().call(text: text, receiverUserId: receiverUserId);

    clear();
    showTextSentIconNotifier.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      showTextSentIconNotifier.value = false;
    });
  }
}