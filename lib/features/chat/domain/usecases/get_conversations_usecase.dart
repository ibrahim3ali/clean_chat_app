import '../entities/chat_conversation_entity.dart';
import '../repositories/chat_repository.dart';

class GetConversationsUseCase {
  final ChatRepository repository;
  const GetConversationsUseCase(this.repository);

  Stream<List<ChatConversationEntity>> call(String currentUserId) {
    return repository.getConversationsStream(currentUserId);
  }
}
