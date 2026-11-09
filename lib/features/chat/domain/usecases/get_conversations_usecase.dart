import '../../../../features.dart';

class GetConversationsUseCase {
  final ChatRepository repository;
  const GetConversationsUseCase(this.repository);

  Stream<List<ChatConversationEntity>> call(String currentUserId) {
    return repository.getConversationsStream(currentUserId);
  }
}
