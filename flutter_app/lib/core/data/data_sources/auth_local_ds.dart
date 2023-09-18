import 'hive_box_instance.dart';


class AuthLocalDS {
  static const String _kLoggedUserId = "loggedUserId";
  static const String _kAccessToken = "accessToken";
  static const String _kAccessTokenExpiration = "accessTokenExpiration";
  static const String _kRefreshToken = "refreshToken";

  late final HiveBoxInstance _hive;

  AuthLocalDS({required HiveBoxInstance hiveBoxInstance}) {
    _hive = hiveBoxInstance;
  }

  int? get loggedUserId {
    final loggedUserId = _hive.box.get(_kLoggedUserId);
    if(loggedUserId == null){
      return null;
    }
    return int.parse(loggedUserId);
  }

  String? getAccessToken () => _hive.box.get(_kAccessToken);
  String? getRefreshToken () => _hive.box.get(_kRefreshToken);
  DateTime? getAccessTokenExpiration () => _hive.box.get(_kAccessTokenExpiration);

  Future<void> setLoggedUserId ({required int loggedUserId}) async => _hive.box.put(_kLoggedUserId, loggedUserId.toString());
  Future<void> setAccessToken ({required String accessToken}) async => _hive.box.put(_kAccessToken, accessToken);
  Future<void> setRefreshToken ({required String refreshToken}) async => _hive.box.put(_kRefreshToken, refreshToken);
  Future<void> setAccessTokenExpiration ({required DateTime accessTokenExpiration}) async => _hive.box.put(_kAccessTokenExpiration, accessTokenExpiration);

  Future<void> deleteAccessToken () async => _hive.box.delete(_kAccessToken);
  Future<void> deleteRefreshToken () async => _hive.box.delete(_kRefreshToken);
  Future<void> deleteLoggedUserId () async => _hive.box.delete(_kLoggedUserId);
  Future<void> deleteAccessTokenExpiration () async => _hive.box.delete(_kAccessTokenExpiration);

  Future<void> clear () async {
    await deleteAccessToken();
    await deleteAccessTokenExpiration();
    await deleteRefreshToken();
    await deleteLoggedUserId();
  }


  
}