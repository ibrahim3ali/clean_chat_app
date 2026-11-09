import '../../../../features.dart';

class GetAllUsersUseCase {
  final ChatRepository repository;
  const GetAllUsersUseCase(this.repository);

  Stream<List<UserEntity>> call() {
    return repository.getUsersStream();
  }
}
