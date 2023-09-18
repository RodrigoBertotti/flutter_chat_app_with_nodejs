


class TokensEntity {
  final String accessToken;
  final String refreshToken;
  final int userId;
  final DateTime accessTokenExpiration;

  TokensEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.accessTokenExpiration
  });
}