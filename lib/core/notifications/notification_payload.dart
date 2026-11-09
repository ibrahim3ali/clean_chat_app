import 'dart:convert';
import '../../features/auth/domain/entities/user_entity.dart';

class NotificationPayload {
  final String senderId;
  final String senderName;
  final String senderEmail;

  const NotificationPayload({
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderEmail': senderEmail,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      senderEmail: map['senderEmail'] as String? ?? '',
    );
  }

  factory NotificationPayload.fromJson(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return NotificationPayload.fromMap(map);
    } catch (_) {
      return const NotificationPayload(
        senderId: '',
        senderName: '',
        senderEmail: '',
      );
    }
  }

  UserEntity toUserEntity() {
    return UserEntity(
      uid: senderId,
      name: senderName,
      email: senderEmail,
      isOnline: true,
    );
  }
}
