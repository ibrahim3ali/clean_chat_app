import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../features.dart';



class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.receiverId,
    required super.text,
    required super.timestamp,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parsedTime;
    final rawTime = data['timestamp'];
    if (rawTime is Timestamp) {
      parsedTime = rawTime.toDate();
    } else if (rawTime is String) {
      parsedTime = DateTime.tryParse(rawTime) ?? DateTime.now();
    } else {
      parsedTime = DateTime.now();
    }

    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: parsedTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
