import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.receiverId,
    required super.text,
    super.type,
    super.mediaUrl,
    super.mediaDuration,
    required super.timestamp,
    super.deletedFor,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedTime;
    final rawTime = map['timestamp'] ?? map['created_at'];
    if (rawTime is Timestamp) {
      parsedTime = rawTime.toDate();
    } else if (rawTime is String) {
      parsedTime = DateTime.tryParse(rawTime) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    final rawDeletedFor = map['deletedFor'] ?? map['deleted_for'];
    final List<String> parsedDeletedFor = [];
    if (rawDeletedFor is List) {
      for (final item in rawDeletedFor) {
        parsedDeletedFor.add(item.toString());
      }
    }

    return MessageModel(
      id: id,
      senderId: (map['senderId'] ?? map['sender_id'] ?? '').toString(),
      senderName: (map['senderName'] ?? map['sender_name'] ?? '').toString(),
      receiverId: (map['receiverId'] ?? map['receiver_id'] ?? '').toString(),
      text: (map['text'] ?? '').toString(),
      type: (map['type'] ?? 'text').toString(),
      mediaUrl: (map['mediaUrl'] ?? map['media_url']) as String?,
      mediaDuration: (map['mediaDuration'] ?? map['media_duration']) as int?,
      timestamp: parsedTime,
      deletedFor: parsedDeletedFor,
    );
  }

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MessageModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'text': text,
      'type': type,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (mediaDuration != null) 'mediaDuration': mediaDuration,
      if (deletedFor.isNotEmpty) 'deletedFor': deletedFor,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toSupabaseMap(String chatId) {
    return {
      'chat_id': chatId,
      'sender_id': senderId,
      'sender_name': senderName,
      'receiver_id': receiverId,
      'text': text,
      'type': type,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (mediaDuration != null) 'media_duration': mediaDuration,
      'deleted_for': deletedFor,
    };
  }
}
