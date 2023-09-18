


class UserEntity {
  final int userId;
  final String firstName;
  final String lastName;

  UserEntity({required this.userId, required this.firstName, required this.lastName});

  String get fullName => "$firstName $lastName";
}