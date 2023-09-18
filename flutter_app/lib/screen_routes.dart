import 'package:flutter/material.dart';
import 'features/call/presentation/screens/call_screen.dart';
import 'features/chat/presentation/screens/realtime_chat_screen/realtime_chat_screen.dart';
import 'features/chat/presentation/screens/realtime_conversations_screen/realtime_conversations_screen.dart';
import 'features/loading/screens/loading_screen.dart';
import 'features/login_and_registration/screens/login_and_registration_screen.dart';

class ScreenRoutes {
  /// home route
  static const loading = LoadingScreen.route;
  static const login = LoginAndRegistrationScreen.route;
  static const conversations = RealtimeConversationsScreen.route;
  static const chat = RealtimeChatScreen.route;
  static const requestCall = CallScreen.route;
}

Map<String, Widget Function(BuildContext)> screenRoutes = {
  ScreenRoutes.loading: (context) =>  const LoadingScreen(),
  ScreenRoutes.login: (context) =>  const LoginAndRegistrationScreen(),
  ScreenRoutes.chat: (context) =>  const RealtimeChatScreen(),
  ScreenRoutes.conversations: (context) => const RealtimeConversationsScreen(),
  ScreenRoutes.requestCall: (context) => const CallScreen(),
};