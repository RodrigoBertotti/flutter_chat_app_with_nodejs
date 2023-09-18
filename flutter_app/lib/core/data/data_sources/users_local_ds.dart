import 'package:flutter_chat_app_with_mysql/core/data/data_sources/hive_box_instance.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/data/models/user_model.dart';

class UsersLocalDS {
  static const String _kUsersKeyPrefix = "user_";
  static const String _kUsersIdsSaved = "usersIdsSaved";

  late final HiveBoxInstance _hive;

  UsersLocalDS({required HiveBoxInstance hiveBoxInstance}) {
    _hive = hiveBoxInstance;
  }

  UserModel? readUserLocally(int userId) {
    final res = _hive.box.get(_getUserKey(userId));
    if (res == null){
      return null;
    }
    return UserModel.fromMap(res);
  }

  List<UserModel>? getUsersToTalkLocally() {
    final List<UserModel> res = [];
    final userIds = _hive.box.get(_kUsersIdsSaved);
    if(userIds == null) {
      return null;
    }
    for(final userId in List<int>.from(userIds)) {
      final user = _hive.box.get(_getUserKey(userId));
      assert(user != null);
      res.add(UserModel.fromMap(user));
    }
    return res..sort((a,b){
      return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
    });
  }

  String _getUserKey(int userId) => "$_kUsersKeyPrefix$userId";

  Future<void> saveUsersLocally(List<UserModel> usersRemoteRes) async {
    final usersIds = List.from(_hive.box.get(_kUsersIdsSaved, defaultValue: []));
    for (final user in usersRemoteRes) {
      await _hive.box.put(_getUserKey(user.userId), user.toMap());
      if(!usersIds.contains(user.userId)) {
        usersIds.add(user.userId);
      }
    }
    _hive.box.put(_kUsersIdsSaved, usersIds);
  }
  
}