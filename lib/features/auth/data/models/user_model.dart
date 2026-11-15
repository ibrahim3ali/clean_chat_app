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
      uid: (map['uid'] ?? map['id'] ?? uid).toString(),
      email: (map['email'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      isOnline: (map['isOnline'] ?? map['is_online']) as bool? ?? false,
      fcmToken: (map['fcmToken'] ?? map['fcm_token']) as String?,
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

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': uid,
      'email': email,
      'name': name,
      'is_online': isOnline,
      if (fcmToken != null) 'fcm_token': fcmToken,
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
