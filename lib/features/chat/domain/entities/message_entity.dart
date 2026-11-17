import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String text;
  final String type; // 'text', 'image', 'video', 'audio'
  final String? mediaUrl;
  final int? mediaDuration;
  final DateTime timestamp;
  final List<String> deletedFor;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.text,
    this.type = 'text',
    this.mediaUrl,
    this.mediaDuration,
    required this.timestamp,
    this.deletedFor = const [],
  });

  bool get isText => type == 'text';
  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isAudio => type == 'audio';
  bool get isDeleted => type == 'deleted' || deletedFor.contains('everyone');

  MessageEntity copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? text,
    String? type,
    String? mediaUrl,
    int? mediaDuration,
    DateTime? timestamp,
    List<String>? deletedFor,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaDuration: mediaDuration ?? this.mediaDuration,
      timestamp: timestamp ?? this.timestamp,
      deletedFor: deletedFor ?? this.deletedFor,
    );
  }

  @override
  List<Object?> get props => [
    id,
    senderId,
    senderName,
    receiverId,
    text,
    type,
    mediaUrl,
    mediaDuration,
    timestamp,
    deletedFor,
  ];
}
