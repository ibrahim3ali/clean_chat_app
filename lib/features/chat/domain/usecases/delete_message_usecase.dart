import '../repositories/chat_repository.dart';

class DeleteMessageUseCase {
  final ChatRepository repository;

  DeleteMessageUseCase(this.repository);

  Future<void> call({
    required String chatId,
    required String messageId,
    required String currentUserId,
    required bool deleteForEveryone,
  }) {
    return repository.deleteMessage(
      chatId: chatId,
      messageId: messageId,
      currentUserId: currentUserId,
      deleteForEveryone: deleteForEveryone,
    );
  }
}
