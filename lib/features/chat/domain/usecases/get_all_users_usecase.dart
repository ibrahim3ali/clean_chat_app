import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/chat_repository.dart';

class GetAllUsersUseCase {
  final ChatRepository repository;
  const GetAllUsersUseCase(this.repository);

  Stream<List<UserEntity>> call() {
    return repository.getUsersStream();
  }
}
