import '../../../../features.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    super.isOnline,
    super.fcmToken,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      isOnline: map['isOnline'] as bool? ?? false,
      fcmToken: map['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'isOnline': isOnline,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      name: entity.name,
      isOnline: entity.isOnline,
      fcmToken: entity.fcmToken,
    );
  }
}
