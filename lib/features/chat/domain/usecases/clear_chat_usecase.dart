import '../repositories/chat_repository.dart';

class ClearChatUseCase {
  final ChatRepository repository;

  ClearChatUseCase(this.repository);

  Future<void> call({
    required String chatId,
    required String currentUserId,
    required bool deleteForEveryone,
  }) {
    return repository.clearChat(
      chatId: chatId,
      currentUserId: currentUserId,
      deleteForEveryone: deleteForEveryone,
    );
  }
}
