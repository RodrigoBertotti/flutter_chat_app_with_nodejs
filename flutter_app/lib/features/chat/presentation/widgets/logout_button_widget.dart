import 'package:flutter/material.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/presentation/controllers/logout_controller.dart';

class LogoutButtonWidget extends StatelessWidget {
  final logoutController = LogoutController();

  LogoutButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        logoutController.logout(context);
      },
      child: Ink(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: BorderRadius.circular(10)
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Icon(Icons.logout_outlined, color: Colors.blue[50]!,),
        ),
      ),
    );
  }
}
