import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesStreamUseCase {
  final ChatRepository repository;
  const GetMessagesStreamUseCase(this.repository);

  Stream<List<MessageEntity>> call({
    required String currentUserId,
    required String otherUserId,
  }) {
    return repository.getMessagesStream(
      currentUserId: currentUserId,
      otherUserId: otherUserId,
    );
  }
}
