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
  });

  bool get isText => type == 'text';
  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
  bool get isAudio => type == 'audio';

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
  ];
}
