import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/chat_repository.dart';

class SearchUserByEmailUseCase {
  final ChatRepository repository;
  const SearchUserByEmailUseCase(this.repository);

  Future<UserEntity?> call(String email) {
    return repository.getUserByEmail(email);
  }
}
