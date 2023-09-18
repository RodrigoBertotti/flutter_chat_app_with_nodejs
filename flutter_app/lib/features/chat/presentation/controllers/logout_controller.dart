import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/use_cases/logout.dart';
import 'package:flutter_chat_app_with_mysql/screen_routes.dart';
import '../../../../injection_container.dart';

class LogoutController {

  void logout (BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(ScreenRoutes.login, (route) => false);
    Future.delayed(const Duration(milliseconds: 500), getIt.get<Logout>().call);
  }

}