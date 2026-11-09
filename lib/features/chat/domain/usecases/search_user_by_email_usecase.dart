import '../../../../features.dart';

class SearchUserByEmailUseCase {
  final ChatRepository repository;
  const SearchUserByEmailUseCase(this.repository);

  Future<UserEntity?> call(String email) {
    return repository.getUserByEmail(email);
  }
}
