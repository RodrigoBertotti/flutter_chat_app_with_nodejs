import '../../domain/entities/user_entity.dart';


class UserModel extends UserEntity {
  /// Field names:
  static const String _kUserId = "userId";
  static const String _kFirstName = "firstName";
  static const String _kLastName = "lastName";

  UserModel({required int userId, required String firstName, required String lastName})
      : super(userId: userId, firstName: firstName, lastName: lastName,);

  static UserModel fromMap(map) {
    return UserModel(
      userId: map[_kUserId],
      firstName: map[_kFirstName],
      lastName: map[_kLastName],
    );
  }

  static List<UserModel> fromList(List list) {
    return list.map((data) => UserModel.fromMap(data)).toList();
  }

  Map<String, dynamic> toMap() => {
    _kUserId: userId,
    _kFirstName: firstName,
    _kLastName: lastName
  };

}