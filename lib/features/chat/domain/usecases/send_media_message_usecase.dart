import 'dart:io';

import '../repositories/chat_repository.dart';

class SendMediaMessageUseCase {
  final ChatRepository repository;
  const SendMediaMessageUseCase(this.repository);

  Future<void> call({
    required String currentUserId,
    required String currentUserName,
    required String receiverId,
    required File file,
    required String type,
    String text = '',
    int? duration,
  }) async {
    final chatId = (currentUserId.compareTo(receiverId) < 0)
        ? '${currentUserId}_$receiverId'
        : '${receiverId}_$currentUserId';

    final folder = type == 'image'
        ? 'images'
        : (type == 'video' ? 'videos' : 'audios');

    final mediaUrl = await repository.uploadMediaFile(
      file: file,
      chatId: chatId,
      folder: folder,
    );

    await repository.sendMessage(
      currentUserId: currentUserId,
      currentUserName: currentUserName,
      receiverId: receiverId,
      text: text,
      type: type,
      mediaUrl: mediaUrl,
      mediaDuration: duration,
    );
  }
}
