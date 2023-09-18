import 'package:flutter_chat_app_with_mysql/core/domain/use_cases/stream_users_to_talk.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/user_entity.dart';
import 'package:flutter_chat_app_with_mysql/injection_container.dart';


class UsersToTalkToController {

  Stream<List<UserEntity>> stream() {
    return getIt.get<UsersToTalkTo>().call();
  }

}