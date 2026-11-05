import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;
  const SendMessageUseCase(this.repository);

  Future<void> call({
    required String currentUserId,
    required String currentUserName,
    required String receiverId,
    required String text,
  }) {
    return repository.sendMessage(
      currentUserId: currentUserId,
      currentUserName: currentUserName,
      receiverId: receiverId,
      text: text,
    );
  }
}
