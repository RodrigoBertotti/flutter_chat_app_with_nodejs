import '../../domain/entities/tokens_entity.dart';



class TokensModel extends TokensEntity {
  static const _kAccessToken = "accessToken";
  static const _kRefreshToken = "refreshToken";
  static const _kUserId = "userId";
  static const _kAccessTokenExpirationMsSinceEpoch = "accessTokenExpirationMsSinceEpoch";

  TokensModel({
    required String accessToken,
    required String refreshToken,
    required int loggedUserId,
    required DateTime accessTokenExpiration
  }) : super (
    userId: loggedUserId,
    accessToken: accessToken,
    refreshToken: refreshToken,
    accessTokenExpiration: accessTokenExpiration,
  );

  static TokensModel fromMap (output) {
    return TokensModel(
      accessToken: output[_kAccessToken],
      refreshToken: output[_kRefreshToken],
      loggedUserId: output[_kUserId],
      accessTokenExpiration: DateTime.fromMillisecondsSinceEpoch(output[_kAccessTokenExpirationMsSinceEpoch])
    );
  }

}